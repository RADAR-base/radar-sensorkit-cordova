//
//  SKSensor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 07/07/2023.
//
import Foundation
import SensorKit
import CoreMotion
import Gzip

extension RbSensorkitCordovaPlugin {
    
    func fetchSamples(fromDate: NSDate , toDate: NSDate, device: SRDevice?) {
        guard let device = device else {
            log("No device found for this sensor")
            return
        }
        let fetchRequest = SRFetchRequest()
        fetchRequest.device = device
        fetchRequest.from = fromDate.srAbsoluteTime
        fetchRequest.to = toDate.srAbsoluteTime
        reader.fetch(fetchRequest)
    }
    
    func processData(sensorDataArray: [[String : Any]]) {
        getTopic(sensorDataArray: sensorDataArray)
    }
    
    func prepareForPost(sensorDataArray: [[String : Any]]) {
        log("Processing Data started at: \(Date().timeIntervalSince1970)")
        log("Total number of records: \(sensorDataArray.count)")
        if sensorDataArray.isEmpty {
            let data = ["progress": 0, "total": 0, "start": 0, "end": 0, "recordCount": 0]
            let json = convertToJson(data: data)
            self.callbackHelper?.sendJson(self.fetchDataCommand!, json, false)
            return
        }
        totalIterations = sensorDataArray.count / chunkSize
        log("Number of chunks: \(totalIterations + 1) - ChunkSize: \(chunkSize) records")
        results = sensorDataArray.chunked(into: chunkSize)
        iterationCounter = -1
        doNextPost()
    }
    
    func postDataToKafka(payload: [[String : Any]]) {
        startTime = payload[0]["time"] as! Double
        endTime = payload[payload.count-1]["time"] as! Double
        let body = getBody(payload: payload)
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        let compressedData = getCompressedData(data: data)
//        writeToFile(data: compressedData, fileName: "acc_1807_\(iterationCounter)")
        guard let request = getRequest(compressedData: compressedData) else {return}
        send(request: request)
    }
    
    func getBody(payload: [[String: Any]]) -> [String: Any] {
        let key: [String : Any] = [
            "projectId": ["string": Config.projectId],
            "userId": Config.userId,
            "sourceId": Config.sourceId
        ] as [String : Any]
        let records = payload.map {
            return ["key": key, "value": $0]
        }
        
        let body: [String: Any] = [
            "key_schema_id": 1,
            "value_schema_id": topicValueId,
            "records": records
        ]
        return body
    }
    
    
    // GENERAL
    func getCompressedData(data: Data) -> Data {
        let compressedData = try! data.gzipped(level: .bestCompression)
        log("Chunk#: \(iterationCounter) - Compressed Data Size \(compressedData.count / 1024) kb")
        return compressedData
    }
    
    func getTopic(sensorDataArray: [[String : Any]]) {
        if (topicName == nil) {
            return
        }

        guard let url = URL(string: Config.baseUrl + Config.schemaEndpoint + topicName! + "-value/versions/latest") else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { [self]
            (data, response, error) in
            _ = response as? HTTPURLResponse
            
            if let error = error {
                log("An error occured. \(error)")
                return
            }
            
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        topicValueId = json["id"] as! Int
                        
                        prepareForPost(sensorDataArray: sensorDataArray)
                    }

                } catch let error {
                    log("We couldn't parse the data into JSON. \(error)")
                }
            }
        }.resume()
    }
    
    func getRequest(compressedData: Data) -> URLRequest? {
        if (topicName == nil) {
            return nil
        }
        guard let url = URL(string: Config.baseUrl + Config.kafkaEndpoint + topicName!) else { return nil }
        var request = URLRequest(url: url)
        let postLength = String(format: "%lu", UInt(compressedData.count))

        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        //        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
        //        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
        //        request.setValue("application/vnd.kafka.avro.v2+json", forHTTPHeaderField: "Content-Type")
        //        request.setValue("application/vnd.radarbase.avro.v1+binary", forHTTPHeaderField: "Content-Type")

        request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(Config.token)", forHTTPHeaderField: "Authorization")
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
        
        request.httpBody = compressedData
        return request
    }
    
    func send(request: URLRequest) {
        let startTime = Date().timeIntervalSince1970
        URLSession.shared.dataTask(with: request) { [self]
            (data, response, error) in
            let response = response as? HTTPURLResponse

            if let error = error {
                log("An error occured. \(error)")
                return
            }

            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        let time = Date().timeIntervalSince1970 - startTime
                        log("Data sent. \(self.iterationCounter + 1)/\(self.totalIterations + 1) in \(time)s")
                        log("\(json)")
                        handleError(response: response, data: json)
                    }
                } catch let error {
                    log("We couldn't parse the data into JSON. \(error)")
                }
                self.doNextPost()
            }
        }.resume()
    }
    
    func handleError(response: HTTPURLResponse?, data: [String: Any]){
        var recordCount = chunkSize
        if iterationCounter == totalIterations {
            recordCount = sensorDataArray.count - iterationCounter * chunkSize
        }
        if response?.statusCode == 200 {
            let data = ["progress": iterationCounter + 1, "total": totalIterations + 1, "start": startTime, "end": endTime, "recordCount": recordCount] as [String : Any]
            let json = convertToJson(data: data)
            self.callbackHelper?.sendJson(self.fetchDataCommand!, json, true)
        } else {
            let data = ["statusCode": response?.statusCode ?? 0, "progress": iterationCounter + 1, "total": totalIterations + 1, "start": startTime, "end": endTime, "recordCount": recordCount, "error_description": data["error_description"] ?? "No description", "error_message": data["error"] ?? "No error message"]
            let json = convertToJson(data: data)
            self.callbackHelper!.sendErrorJson(self.fetchDataCommand!, json, true)
        }
    }
    
    func doNextPost() {
        if iterationCounter < totalIterations {
            iterationCounter += 1
            postDataToKafka(payload: results[iterationCounter])
        } else {
            // SEND REPORT
            log("Finished at: \(Date().timeIntervalSince1970)")
        }
    }
}
