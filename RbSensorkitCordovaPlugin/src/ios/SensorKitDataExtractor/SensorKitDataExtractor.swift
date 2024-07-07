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
import SwiftAvroCore


@available(iOS 14.0, *)
class SensorKitDataExtractor : NSObject, SRSensorReaderDelegate, URLSessionTaskDelegate {
    
    var sensor: SRSensor? { get { return nil } }
    var fetchIntervalInHours: Int { get {return 7 * 24 }} // 7 days = 7 * 24 hours
    
    var topicName: String = "sensorkit_ambient_light"
    
    var periodMili: Double = 0
    var chunkSize = 10000
    
    var topicKeyId = 0
    var topicValueId = 0
    var topicSchemaStr: String? = nil
    var lastRecordTS: Double = 0
    
    var reader: SRSensorReader?
    
    var counter = 0
    var sensorDataArray: [[Double : [UInt8]]] = [] //[[UInt8]] = [] //[[String: Any]] = []
    
    var totalIterations = 0
    var iterationCounter = -1
    var results: [[[Double : [UInt8]]]] = [] //[[[UInt8]]] = [] // [[[String : Any]]] = []
    
    var startTime: Double = 0
    var endTime: Double = 0
    
    var delegate: SensorKitDelegate?
    
    var devices: [SRDevice] = []
    var selectedDevice: SRDevice?
    
    var deviceCounter = -1
    var fetchCounter = -1

    var beginDate: Double?
    var endDate: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: Date(), options: [])! //Date()
    var numberOfFetches: Int = 0
    
    init(periodMili: Double, topicName: String, chunkSize: Int) {
        
          //beginDate = PersistentContainer.shared.lastFetched!

        super.init()
        beginDate = getBeginDate()
        let fetchIntrevalInSeconds: Double = Double(fetchIntervalInHours * 60 * 60)
//        numberOfFetches = Int(ceil((endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970)/fetchIntrevalInSeconds))
        numberOfFetches = Int(ceil((endDate.timeIntervalSince1970 - beginDate!)/fetchIntrevalInSeconds))

        self.topicName = topicName
        self.periodMili = periodMili
        self.chunkSize = chunkSize
        self.reader = SRSensorReader(sensor: sensor!)
        self.reader = .init(sensor: sensor!)
        self.reader!.delegate = self
    }
    
    func getBeginDate() -> Double? {
        return nil
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
    
    func processData(sensorDataArray: [[Double : [UInt8]]]) async { //}[[UInt8]]) async { //}[[String : Any]]) async {
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
            if self.topicSchemaStr == nil {
                self.topicSchemaStr = try await getTopicSchemaString(topicName: topicName) ?? nil
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
            if self.devices.count > 0 && deviceCounter < self.devices.count - 1 {
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
        if self.devices.count > 0 && deviceCounter < self.devices.count - 1 {
            changeDevice()
        } else {
            delegate?.__fetchCompletedForOneSensor(sensor: sensor!, date: endDate)
        }
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
        
        let _beginDate = Date(timeIntervalSince1970: TimeInterval(beginDate!))
        let fromDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: fetchCounter * fetchIntervalInHours, to: _beginDate, options: [])!
        let toDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: (fetchCounter + 1) * fetchIntervalInHours, to: _beginDate, options: [])!
        
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
            Task {
                do {
                    if self.topicSchemaStr == nil {
                        self.topicSchemaStr = try await getTopicSchemaString(topicName: topicName) ?? nil
                        convertSensorData(result: result)
                                }
                } catch let error {
                    delegate?.__failedFetchTopic(topicName: topicName, error: error)
                }
            }
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
    
    func prepareForPost(sensorDataArray: [[Double : [UInt8]]]) async {
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
    
    func getTopicSchemaString(topicName: String) async throws -> String? {
        guard let baseUrl = RadarbaseConfig.baseUrl else {
            // send error to JS and return
            return nil
        }
        guard let url = URL(string: baseUrl + RadarbaseConfig.schemaEndpoint + topicName + "-value/versions/latest") else {
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
        
        var schemaStr: String? = nil
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                schemaStr = json["schema"] as? String
            }
        } catch let error {
            print("We couldn't parse the data into JSON. \(error)")
        }
        return schemaStr
    }
    
    func postDataToKafka(payload: [[Double : [UInt8]]]) async {//}[[UInt8]]) async { //}[[String : Any]]) async {
        guard let lastDictionary = payload.last else {
            return
        }
        
        guard let lastKey = lastDictionary.keys.sorted().last else {
            return
        }
        
        var allPayloadValues: [[UInt8]] = []
        for dictionary in payload {
            for value in dictionary.values {
                allPayloadValues.append(value)
            }
        }
            
        let body = getBody(payload: allPayloadValues, keySchemaId: self.topicKeyId, valueSchemaId: self.topicValueId)
        let compressedData = getCompressedData(data: body)
        await writeToFile(data: compressedData, fileName: "\(topicName)___\(Date().timeIntervalSince1970)_\(iterationCounter)", endTime: lastKey)
    }
    
    
    
//    var ccounter = 0
   
    func getBody(payload: [[UInt8]], keySchemaId: Int, valueSchemaId: Int) -> Data { //}[String: Any] {
//    func getBody(payload: [[String: Any]], keySchemaId: Int, valueSchemaId: Int) -> [String: Any] {
        let recordSetSchemaStr = """
        {
          "namespace": "org.radarcns.kafka",
          "name": "RecordSet",
          "type": "record",
          "doc": "Abbreviated record set, meant for binary data transfers of larger sets of data. It can contain just a source ID and the record values. The record keys are deduced from authentication parameters. This method of data transfer requires that the data actually adheres to the schemas identified by the schema version.",
          "fields": [
            {"name": "keySchemaVersion", "type": "int", "doc": "Key schema version for the given topic."},
            {"name": "valueSchemaVersion", "type": "int", "doc": "Value schema version for the given topic."},
            {"name": "projectId", "type": ["null", "string"], "doc": "Project ID of the sent data. If null, it is attempted to be deduced from the credentials.", "default": null},
            {"name": "userId", "type": ["null", "string"], "doc": "User ID of the sent data. If null, it is attempted to be deduced from the credentials.", "default": null},
            {"name": "sourceId", "type": "string", "doc": "Source ID of the sent data."},
            {"name": "data", "type": {"type": "array", "items": "bytes", "doc": "Binary serialized Avro records."}, "doc": "Collected data. This should just contain the value records."}
          ]
        }
        """

        let avro = Avro()
        _ = avro.decodeSchema(schema: recordSetSchemaStr)!
        let recordSet = RecordSetModel(
            keySchemaVersion: 1, valueSchemaVersion: 1,
            projectId: UserConfig.projectId["string"]!!, userId:UserConfig.userId!, sourceId: UserConfig.sourceId ?? "",
            data: payload
        )
        let recordSetBinaryValue = try!avro.encode(recordSet)
        let hexString = dataToHexString(recordSetBinaryValue)
        return recordSetBinaryValue
    }
    
    func dataToHexString(_ data: Data) -> String {
        return data.map { String(format: "%02x", $0) }.joined()
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
    
    func _updateLastFetch(date: Double) {
        //PersistentContainer.shared.lastFetched = date
    }
}


@available(iOS 14.0, *)
extension SensorKitDataExtractor {
    // UTIL
    func writeToFile(data: Data, fileName: String, endTime: Double) async {
        guard let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
            return
        }
        let fileurl =  directory.appendingPathComponent("\(fileName).txt.gz")
        if FileManager.default.fileExists(atPath: fileurl.path) {
            if let fileHandle = FileHandle(forWritingAtPath: fileurl.path) {
                // seekToEndOfFile, writes data at the last of file(appends not override)
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
            else {
                print("Can't open file to write.")
            }
        }
        else {
            // if file does not exist write data for the first time
            do{
                try data.write(to: fileurl, options: .atomic)
                _updateLastFetch(date: endTime)
                await self.doNextPost()

            }catch {
                print("Unable to write in new file.")
            }
        }

    }
}

struct RecordSetModel: Encodable, Decodable {
    let keySchemaVersion: Int32
    let valueSchemaVersion: Int32
    let projectId: String?
    let userId: String?
    let sourceId: String
    let data: [[UInt8]]
};


