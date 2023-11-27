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

@available(iOS 14.0, *)
class SensorKitDataExtractor : NSObject, SRSensorReaderDelegate, URLSessionTaskDelegate {
    
    var sensor: SRSensor? { get { return nil } }
    var fetchIntervalInHours: Int { get {return 7 * 24 }} // 7 days = 7 * 24 hours
    
    var topicName: String = "sensorkit_ambient_light"
    
    var periodMili: Double = 0
    let chunkSize = 10000
    
    var topicKeyId = 0
    var topicValueId = 0
    var lastRecordTS: Double = 0
    
    var reader: SRSensorReader?
    
    var counter = 0
    var sensorDataArray: [[String: Any]] = []
    
    var totalIterations = 0
    var iterationCounter = -1
    var results: [[[String : Any]]] = []
    
    var startTime: Double = 0
    var endTime: Double = 0
    
    var delegate: SensorKitDelegate?
    
    var devices: [SRDevice] = []
    var selectedDevice: SRDevice?
    
    var deviceCounter = -1
    var fetchCounter = -1

    var beginDate: Date
    var endDate: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: Date(), options: [])! //Date()
    var numberOfFetches: Int = 0
    
    init(periodMili: Double, topicName: String) {
          beginDate = PersistentContainer.shared.lastFetched!

        super.init()
        let fetchIntrevalInSeconds: Double = Double(fetchIntervalInHours * 60 * 60)
        numberOfFetches = Int(ceil((endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970)/fetchIntrevalInSeconds))

        self.topicName = topicName
        self.periodMili = periodMili
        self.reader = SRSensorReader(sensor: sensor!)
        self.reader = .init(sensor: sensor!)
        self.reader!.delegate = self
    }
    
    var storedTime: Double = 0
    
    func startFetching() {
        fetchCounter = -1
        deviceCounter = -1
        fetchDevices()
    }
    
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        Task {
            await processData(sensorDataArray: sensorDataArray)
        }
    }
    
    func processData(sensorDataArray: [[String : Any]]) async {
        do {
            if sensorDataArray.isEmpty {
                processNextFetch()
                return
            }
            if self.topicKeyId == 0 {
                self.topicKeyId = try await getTopicId(property: TopicKeyValue.KEY, topicName: topicName) ?? 0
            }
            if self.topicValueId == 0 {
                self.topicValueId = try await getTopicId(property: TopicKeyValue.VALUE, topicName: topicName) ?? 0
            }
            await self.prepareForPost(sensorDataArray: sensorDataArray)
        } catch let error {
            delegate?.__failedFetchTopic(topicName: topicName, error: error)
            processNextFetch()
        }
    }
    
    func processNextFetch() {
        if fetchCounter < numberOfFetches - 1 {
            doNextFetch()
        } else {
            if deviceCounter < self.devices.count - 1 {
                changeDevice()
            } else {
                delegate?.__fetchCompletedForOneSensor(sensor: sensor!, date: endDate)
            }
        }
    }
    
    func convertSensorData(result: SRFetchResult<AnyObject>) {}
    
    
    func fetchSamples(fromDate: NSDate , toDate: NSDate, device: SRDevice?) {
        guard let device = device else {
            return
        }
        let fetchRequest = SRFetchRequest()
        fetchRequest.device = device
        fetchRequest.from = fromDate.srAbsoluteTime
        fetchRequest.to = toDate.srAbsoluteTime
        reader!.fetch(fetchRequest)
    }

    // MARK: StartRecording
    func startRecording() {
        self.reader!.startRecording()
    }
    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {}
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {}
    
    // MARK: StopRecording
    func stopRecording() {
        self.reader!.stopRecording()
    }
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        delegate?.__didStopRecording(sensor: reader.sensor)
    }
    func sensorReader(_ reader: SRSensorReader, stopRecordingFailedWithError error: Error) {
        delegate?.__failedStopRecording(sensor: reader.sensor, error: error)
    }
    
    // MARK: FetchDevices
    func fetchDevices() {
        self.reader!.fetchDevices()
    }

    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        self.devices = devices
        changeDevice()
    }

    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {}
    
    func changeDevice() {
        fetchCounter = -1
        deviceCounter = deviceCounter + 1
        selectedDevice = devices[deviceCounter]
        doNextFetch()
    }
    
    func doNextFetch() {
        fetchCounter = fetchCounter + 1
        
        let fromDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: fetchCounter * fetchIntervalInHours, to: beginDate, options: [])!
        let toDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: (fetchCounter + 1) * fetchIntervalInHours, to: beginDate, options: [])!
        
        fetch(from: fromDate as NSDate, to: toDate as NSDate, device: selectedDevice)
    }
    
    func fetch(from: NSDate, to: NSDate, device: SRDevice?) {
        fetchData(fromDate: from, toDate: to, device: device)
    }
    
    // MARK: FetchData
    func fetchData(fromDate: NSDate , toDate: NSDate, device: SRDevice?) { // CFAbsoluteTime
        fetchSamples(fromDate: fromDate, toDate: toDate, device: device ?? SRDevice.current)
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {}

    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        let currentRecordTS: Double = result.timestamp.rawValue * 1000
        if currentRecordTS - lastRecordTS >= periodMili {
            lastRecordTS = currentRecordTS
            convertSensorData(result: result)
        }
        return true
    }
    
    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {}
    
    // MARK: Check authorization
    func checkAuthorization() -> SRAuthorizationStatus {
        return self.reader!.authorizationStatus
    }
    
    // MARK: Helpers
    func convertToJson(object: Encodable) -> String? {
        let jsonEncoder = JSONEncoder()
        let jsonData = try! jsonEncoder.encode(object)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
        return json
    }
    
    func prepareForPost(sensorDataArray: [[String : Any]]) async {
        totalIterations = sensorDataArray.count / chunkSize
        results = sensorDataArray.chunked(into: chunkSize)
        iterationCounter = -1
        await doNextPost()
    }
    
    func getTopicId(property: TopicKeyValue, topicName: String) async throws -> Int? {
        guard let baseUrl = RadarbaseConfig.baseUrl else {
            // send error to JS and return
            return nil
        }
        guard let url = URL(string: baseUrl + RadarbaseConfig.schemaEndpoint + topicName + "-" + property.rawValue + "/versions/latest") else {
            // send error to JS and return
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
            print("We couldn't parse the data into JSON. \(error)")
        }
        return id
    }
    
    func postDataToKafka(payload: [[String : Any]]) async {
        startTime = payload[0]["time"] as! Double
        endTime = payload[payload.count-1]["time"] as! Double
        let body = getBody(payload: payload, keySchemaId: self.topicKeyId, valueSchemaId: self.topicValueId)
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        let compressedData = getCompressedData(data: data)
        await writeToFile(data: compressedData, fileName: "\(topicName)___\(Date().timeIntervalSince1970)_\(iterationCounter)")
    }
   
    func getBody(payload: [[String: Any]], keySchemaId: Int, valueSchemaId: Int) -> [String: Any] {
        let key: [String : Any] = [
            "projectId": UserConfig.projectId,
            "userId": UserConfig.userId!,
            "sourceId": UserConfig.sourceId ?? ""
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
        return compressedData
    }
    
    func getRequest(compressedData: Data) -> URLRequest? {
        guard let baseUrl = RadarbaseConfig.baseUrl else {
          return nil
        }
        guard let url = URL(string: baseUrl + RadarbaseConfig.kafkaEndpoint + topicName) else {
            return nil
        }
        var request = URLRequest(url: url)
        let postLength = String(format: "%lu", UInt(compressedData.count))
        request.httpMethod = "POST"
       
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(UserConfig.token!)", forHTTPHeaderField: "Authorization")
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
        
        request.httpBody = compressedData
        return request
    }
    
    func handleError(response: HTTPURLResponse?, data: Data?){
        switch(response?.statusCode){
        case 200:
            return
        case 400:
            return
        case 401:
            return
        case 415:
            return
        case 500:
            return
        default:
            return
        }
    }
    
    func doNextPost() async {
        if iterationCounter < totalIterations {
            iterationCounter += 1
            await postDataToKafka(payload: results[iterationCounter])
        } else {
            sensorDataArray = []
            processNextFetch()
        }
    }
}


@available(iOS 14.0, *)
extension SensorKitDataExtractor {
    // UTIL
    func writeToFile(data: Data, fileName: String) async {
        let tempDir = FileManager.default.temporaryDirectory
        let localURL = tempDir.appendingPathComponent(fileName + ".txt.gz")
        do {
            try data.write(to: localURL)
            await self.doNextPost()
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("\(Date().timeIntervalSince1970) Write failed")
        }
    }
}


