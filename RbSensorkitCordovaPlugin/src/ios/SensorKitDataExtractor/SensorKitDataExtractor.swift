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
    
    func processData(sensorDataArray: [[String : Any]]) async {
        if topicName == nil {
            return
        }
        do {
            self.topicKeyId = try await getTopicId(property: TopicKeyValue.KEY, topicName: topicName!) ?? 0
            self.topicValueId = try await getTopicId(property: TopicKeyValue.VALUE, topicName: topicName!) ?? 0
            await self.prepareForPost(sensorDataArray: sensorDataArray)
        } catch {
        }
    }
    
    func prepareForPost(sensorDataArray: [[String : Any]]) async {
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
        await doNextPost()
    }
    
    func postDataToKafka(payload: [[String : Any]]) async {
        startTime = payload[0]["time"] as! Double
        endTime = payload[payload.count-1]["time"] as! Double
        let body = getBody(payload: payload, keySchemaId: self.topicKeyId, valueSchemaId: self.topicValueId)
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        let compressedData = getCompressedData(data: data)
//        writeToFile(data: compressedData, fileName: "acc_1807_\(iterationCounter)")
        guard let request = getRequest(compressedData: compressedData, topicName: self.topicName!) else {return}
        await send(request: request)
    }
    
    func getBody(payload: [[String: Any]], keySchemaId: Int, valueSchemaId: Int) -> [String: Any] {
        let key: [String : Any] = [
            "projectId": ["string": Config.projectId],
            "userId": Config.userId,
            "sourceId": Config.sourceId
        ] as [String : Any]
        let records = payload.map {
            return ["key": key, "value": $0]
        }
        
        let body: [String: Any] = [
            "key_schema_id": keySchemaId,
            "value_schema_id": valueSchemaId,
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
    
    func getTopicId(property: TopicKeyValue, topicName: String) async throws -> Int? {
        guard let url = URL(string: Config.baseUrl + Config.schemaEndpoint + topicName + "-" + property.rawValue + "/versions/latest") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw PostToKafkaError.runtimeError("Failed")
        }
        var id: Int? = nil
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                id = json["id"] as? Int
            }
        } catch let error {
            log("We couldn't parse the data into JSON. \(error)")
        }
        return id
    }
    
    func getRequest(compressedData: Data, topicName: String) -> URLRequest? {
        guard let url = URL(string: Config.baseUrl + Config.kafkaEndpoint + topicName) else { return nil }
        var request = URLRequest(url: url)
        let postLength = String(format: "%lu", UInt(compressedData.count))

        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(Config.token)", forHTTPHeaderField: "Authorization")
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
        
        request.httpBody = compressedData
        return request
    }
    
    func send(request: URLRequest) async {
        let startTime = Date().timeIntervalSince1970
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let time = Date().timeIntervalSince1970 - startTime
                    log("Data sent. \(self.iterationCounter + 1)/\(self.totalIterations + 1) in \(time)s")
                    log("\(json)")
                    await handleSuccessError(response: response as? HTTPURLResponse, data: json)
                }
            } catch let error {
                log("We couldn't parse the data into JSON. \(error)")
            }
            await self.doNextPost()
        } catch {
            
        }
    }
    
    func sendMagneticFieldData(request: URLRequest) async {
        let startTime = Date().timeIntervalSince1970
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let time = Date().timeIntervalSince1970 - startTime
                    //log("Data sent. \(self.iterationCounter + 1)/\(self.totalIterations + 1) in \(time)s")
                    log("\(json)")
                    await handleMagneticFieldSuccessError(response: response as? HTTPURLResponse, data: json)
                }
            } catch let error {
                log("We couldn't parse the data into JSON. \(error)")
            }
            //await self.doNextPost()
        } catch {
            
        }
    }
    
    func handleSuccessError(response: HTTPURLResponse?, data: [String: Any]) async{
        var recordCount = chunkSize
        if iterationCounter == totalIterations {
            recordCount = sensorDataArray.count - iterationCounter * chunkSize
        }
        if response?.statusCode == 200 {
            let data = ["progress": iterationCounter + 1, "total": totalIterations + 1, "start": startTime, "end": endTime, "recordCount": recordCount] as [String : Any]
            let json = convertToJson(data: data)
            self.callbackHelper?.sendJson(self.fetchDataCommand!, json, true)
            // send log
            await self.postLogToKafka()
        } else {
            let data = ["statusCode": response?.statusCode ?? 0, "progress": iterationCounter + 1, "total": totalIterations + 1, "start": startTime, "end": endTime, "recordCount": recordCount, "error_description": data["error_description"] ?? "No error description", "error_message": data["error"] ?? "No error message"]
            let json = convertToJson(data: data)
            self.callbackHelper!.sendErrorJson(self.fetchDataCommand!, json, true)
        }
    }
    
    func handleMagneticFieldSuccessError(response: HTTPURLResponse?, data: [String: Any]) async{
        if response?.statusCode == 200 {
            self.callbackHelper?.sendEmpty(self.fetchMagneticFieldCommand!, true)
            // send log
            await self.postLogToKafka()
        } else {
            self.callbackHelper!.sendError(self.fetchMagneticFieldCommand!, data["error_description"] as? String ?? "UNKNOWN_ERROR", true)
        }
    }
    
    func doNextPost() async {
        if iterationCounter < totalIterations {
            iterationCounter += 1
            await postDataToKafka(payload: results[iterationCounter])
        } else {
            // SEND REPORT
            log("Finished at: \(Date().timeIntervalSince1970)")
        }
    }
    
    func postLogToKafka() async{
        let data = [["time": Date().timeIntervalSince1970, "dataGroupingType": "PASSIVE_SENSOR_KIT"] as [String : Any]]
        let key: [String : Any] = [
            "projectId": ["string": Config.projectId],
            "userId": Config.userId,
            "sourceId": Config.sourceId
        ] as [String : Any]
        let records = data.map {
            return ["key": key, "value": $0] as [String : Any]
        }
        
        let body: [String: Any] = [
            "key_schema_id": logTopicKeyId,
            "value_schema_id": logTopicValueId,
            "records": records
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        guard let url = URL(string: Config.baseUrl + Config.kafkaEndpoint + "connect_data_log") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(Config.token)", forHTTPHeaderField: "Authorization")
        request.httpBody = data
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
        } catch let error {
            log("Error on sending connect log. \(error)")
        }
    }
}

