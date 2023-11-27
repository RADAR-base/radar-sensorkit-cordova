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
    
//    var defaultTopic: String? { get { return nil } }
//    var defaultPriod: Double { get { return 0 } }
    var sensor: SRSensor? { get { return nil } }
    var fetchIntervalInHours: Int { get {return 7 * 24 }} // 7 days = 7 * 24 hours
//    var beginDate: Date? { get { return nil } }
    
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

//    let DAY: Double = 24 * 60 * 60
//    var beginDate: Double = 0
    var beginDate: Date
    var endDate: Date = (Calendar.current as NSCalendar).date(byAdding: .day, value: -1, to: Date(), options: [])! //Date()
    var numberOfFetches: Int = 0
    
    init(periodMili: Double, topicName: String) {
          beginDate = PersistentContainer.shared.lastFetched!
//        storedBeginDate = beginDate!

        super.init()
//        beginDate = -4 * DAY + 6 * 60 * 60 // - 3d and 18h
//        print("beginDate = \(String(describing: beginDate)) \(beginDate.timeIntervalSince1970) \(fetchIntervalInHours) \(endDate.timeIntervalSince1970)")
//        print("beginDate = \(beginDate) \(DAY)")
//        numberOfFetches = Int(ceil((-DAY - beginDate)/DAY))
//        numberOfFetches = Int(ceil((-DAY - beginDate.timeIntervalSince1970)/DAY))
        let fetchIntrevalInSeconds: Double = Double(fetchIntervalInHours * 60 * 60)
        numberOfFetches = Int(ceil((endDate.timeIntervalSince1970 - beginDate.timeIntervalSince1970)/fetchIntrevalInSeconds))

//        print("\(Date().timeIntervalSince1970) numberOfFetches = \(numberOfFetches)")

        self.topicName = topicName // defaultTopic ?? "" // topicName
        self.periodMili = periodMili // defaultPriod //period
        self.reader = SRSensorReader(sensor: sensor!)
        self.reader = .init(sensor: sensor!)
        self.reader!.delegate = self
        
//        super.init()
        //getTopic()
    }
    
    var storedTime: Double = 0
    
    func startFetching() {
        fetchCounter = -1
        deviceCounter = -1
        fetchDevices()
    }
    
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        print("\(Date().timeIntervalSince1970) Fetch completed \(reader.sensor.rawValue) (\(sensorDataArray.count))")

//        print("\(Date().timeIntervalSince1970) sensorReader didCompleteFetch \(reader.sensor.rawValue) (\(counter))")
//        print("\(sensorDataArray[0])")
//        counter = 0
        Task {
            await processData(sensorDataArray: sensorDataArray)
        }
//        processData(sensorDataArray: sensorDataArray)
//        sensorDataArray = []
        
        //fetchDataFoorNextDates()
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
//            fetchCounter = 0
            if deviceCounter < self.devices.count - 1 {
                changeDevice()
//                selectedDevice = devices[deviceCounter]
//                print("\(Date().timeIntervalSince1970) deviceChanged \(String(describing: selectedDevice?.name))")
//                deviceCounter = deviceCounter + 1
//                doNextFetch(device: selectedDevice)
            } else {
                delegate?.__fetchCompletedForOneSensor(sensor: sensor!, date: endDate)
////                deviceCounter = 0
//                if sensorCounter < sensors.count - 1 {
//                    changeSensor()
////                    let sensor = sensors[sensorCounter]
////                    selectedSensor = SensorKitDataExtractor(sensor: sensor, topicName: Constants.TOPIC_NAME[sensor]!, period: Constants.DEFAULT_PERIOD[sensor] ?? 0)
////                    print("\(Date().timeIntervalSince1970) sensorChanged \(String(describing: selectedSensor?.reader.sensor.rawValue)))")
////                    selectedSensor?.delegate = self
////                    selectedSensor?.fetchDevices()
////                    // get numberOfDevices
////                    //numberOfDevices = ?
////                    // select the first device
////                    //device = ?
////                    sensorCounter = sensorCounter + 1
////                    doNextFetch(device: selectedDevice)
//                } else {
//                    uploadAllFiles()
//                }
            }
        }
    }
    
    func convertSensorData(result: SRFetchResult<AnyObject>) {
//        switch (self.sensor) {
//            case .accelerometer:
//                convertAccelerometerSensorData(result: result)
//                break
//            case .ambientLightSensor:
//                convertAmbientLightData(result: result)
//                break
//            case .deviceUsageReport:
//                convertDeviceUsageSensorData(result: result)
//                break
//            case .keyboardMetrics:
//                convertKeyboardMetricsSensorData(result: result)
//                break
//            case .messagesUsageReport:
//                convertMessageUsageSensorData(result: result)
//                break
//            case .onWristState:
//                convertOnWristSensorData(result: result)
//                break
//            case .pedometerData:
//                convertPedometerSensorData(result: result)
//                break
//            case .phoneUsageReport:
//                convertPhoneUsageSensorData(result: result)
//                break
//            case .visits:
//                convertVisitsSensorData(result: result)
//                break
//            default:
//                print("Sensor invalid")
//        }
    }
    
    
    func fetchSamples(fromDate: NSDate , toDate: NSDate, device: SRDevice?) { //CFAbsoluteTime
        guard let device = device else {
//            print("\(Date().timeIntervalSince1970) No device found for this sensor")
            return
        }
        let fetchRequest = SRFetchRequest()
        fetchRequest.device = device
        fetchRequest.from = fromDate.srAbsoluteTime // SRAbsoluteTime.fromCFAbsoluteTime(_cf: fromDate)
        fetchRequest.to = toDate.srAbsoluteTime // SRAbsoluteTime.fromCFAbsoluteTime(_cf: toDate)
        reader!.fetch(fetchRequest)
    }
//}

//extension SensorKitDataExtractor : SRSensorReaderDelegate {
    // MARK: StartRecording
    func startRecording() {
//        print("\(Date().timeIntervalSince1970) -startRecording")
        self.reader!.startRecording()
    }
    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
//        delegate?.startRecodingResponse(0)
//        print("\(Date().timeIntervalSince1970) -sensorReader startRecordingFailedWithError \(error)")
    }
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
//        print("\(Date().timeIntervalSince1970) -sensorReaderWillStartRecording")
    }
    
    // MARK: StopRecording
    func stopRecording() {
//        print("\(Date().timeIntervalSince1970) -stopRecording")
        self.reader!.stopRecording()
    }
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
//        print("\(Date().timeIntervalSince1970) -sensorReaderDidStopRecording \(reader)")
        // delegate
        delegate?.__didStopRecording(sensor: reader.sensor)
    }
    func sensorReader(_ reader: SRSensorReader, stopRecordingFailedWithError error: Error) {
//        print("\(Date().timeIntervalSince1970) -sensorReader stopRecordingFailedWithError \(error)")
        // delegate
        delegate?.__failedStopRecording(sensor: reader.sensor, error: error)
    }
    
    // MARK: FetchDevices
    func fetchDevices() {
//        print("\(Date().timeIntervalSince1970) fetchDevices \(reader!.sensor.rawValue)")
        self.reader!.fetchDevices()
    }

    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
//        print("\(Date().timeIntervalSince1970) fetchDevices devices: \(devices)")
        //self.devices = devices
        // call parent and send back the devices
        self.devices = devices
//        print("\(Date().timeIntervalSince1970) number of devices = \(devices.count)")
        changeDevice()
        
//        self.delegate?.devicesFetched(devices)
//        var resultObject: [[String: Any]] = []
//        devices.forEach { device in
//            resultObject.append([
//                "name": device.name, // e.g. "My iPhone"
//                "model": device.model, // e.g. @"iPhone"
//                "systemName": device.systemName, // e.g. @"iOS"
//                "systemVersion": device.systemVersion
//            ])
////            resultObject.append(DeviceRecord(name: device.name, model: device.model, systemName: device.systemName, systemVersion: device.systemVersion))
//        }
//        let result = convertToJson(object: resultObject)
//        print("\(Date().timeIntervalSince1970) fetchDevices devices: \(String(describing: resultObject))")
    }

    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
//        print("\(Date().timeIntervalSince1970) fetchDevices Error: \(error)")
    }
    
    func changeDevice() {
        fetchCounter = -1
        deviceCounter = deviceCounter + 1
        selectedDevice = devices[deviceCounter]
//        print("selectedDevice \(selectedDevice?.name) - \(selectedDevice?.model) - \(selectedDevice?.systemName) - \(selectedDevice?.systemVersion) - \(selectedDevice?.description)")
        doNextFetch()
    }
    
    func doNextFetch() {
        fetchCounter = fetchCounter + 1
//        print("\(Date().timeIntervalSince1970) doNextFetch \(fetchCounter)")
//        print("fetchCounter \(fetchCounter)")
//        let fromSeconds: Double = beginDate + DAY * Double(fetchCounter) // * -7 * 24 * 60 * 60
//        print("fromSeconds \(fromSeconds)")
//        let toSeconds: Double = beginDate + DAY * Double(fetchCounter + 1) // -24 * 60 * 60
        
//        guard let fromDate = beginDate as? NSDate, let toDate = endDate as? NSDate else {
////            callbackHelper?.sendError(command, "INVALID_DATES")
//            return
//        }
        
        let fromDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: fetchCounter * fetchIntervalInHours, to: beginDate, options: [])!
        let toDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: (fetchCounter + 1) * fetchIntervalInHours, to: beginDate, options: [])!
        
//        let fromDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: 0, to: beginDate, options: [])!
//        let toDate = (Calendar.current as NSCalendar).date(byAdding: .hour, value: fetchIntervalInHours, to: beginDate, options: [])!
//        print("toSeconds \(toSeconds)")
//        let now = Date()
//        let from = Date(timeInterval: fromSeconds, since: now) as NSDate
//        let to = Date(timeInterval: toSeconds, since: now) as NSDate
        
        fetch(from: fromDate as NSDate, to: toDate as NSDate, device: selectedDevice)
//        fetch(from: from, to: to, device: selectedDevice)
    }
    
    func fetch(from: NSDate, to: NSDate, device: SRDevice?) {
//        print("\(Date().timeIntervalSince1970) fetch")
//        if (selectedSensor == nil) {
//            print("\(Date().timeIntervalSince1970) fetch selectedSensor is nil")
//            return
//        }
        
        //date should be split for high frequency data
//        let fromSeconds: Double = -7 * 24 * 60 * 60
//        let toSeconds: Double = -24 * 60 * 60
//        let now = Date()
//        let from = Date(timeInterval: fromSeconds, since: now) as NSDate
//        let to = Date(timeInterval: toSeconds, since: now) as NSDate
        fetchData(fromDate: from, toDate: to, device: device)
    }
    
    // MARK: FetchData
    func fetchData(fromDate: NSDate , toDate: NSDate, device: SRDevice?) { // CFAbsoluteTime
//        print("\(Date().timeIntervalSince1970) FetchData started at: \(Date().timeIntervalSince1970)")
        fetchSamples(fromDate: fromDate, toDate: toDate, device: device ?? SRDevice.current)
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
//        print("\(Date().timeIntervalSince1970) Reader fetch failed: \(error)")
    }

    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
//        switch sensor {
//        case .accelerometer:
            //, .ambientPressure:
            
//            break
//        default:
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertSensorData(result: result)
            }
//            break
//        }
//        convertSensorData(result: result)
        return true
    }
    
    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {
//        print("\(Date().timeIntervalSince1970) -sensorReader didChange \(authorizationStatus)")
    }
    
//    func initialiseSensor() {
//        print("\(Date().timeIntervalSince1970) -initialiseSensor")
//        self.reader = .init(sensor: sensor)
//    }
    
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
//}

//extension SensorKitDataExtractor {
    
   
    
    func prepareForPost(sensorDataArray: [[String : Any]]) async {
//        print("\(Date().timeIntervalSince1970) Processing Data started at: \(Date().timeIntervalSince1970)")
//        print("\(Date().timeIntervalSince1970) Total number of records: \(sensorDataArray.count)")
//        if sensorDataArray.isEmpty {
////            let data = ["progress": 0, "total": 0, "start": 0, "end": 0, "recordCount": 0]
////            let json = convertToJson(data: data)
////            self.callbackHelper?.sendJson(self.fetchDataCommand!, json, false)
//
//            return
//        }
        totalIterations = sensorDataArray.count / chunkSize
//        print("\(Date().timeIntervalSince1970) Number of chunks: \(totalIterations + 1) - ChunkSize: \(chunkSize) records")
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
//    func processData(sensorDataArray: [[String : Any]]) {
//        print("\(Date().timeIntervalSince1970) Processing Data started at: \(Date().timeIntervalSince1970)")
//        print("\(Date().timeIntervalSince1970) Total number of records:", sensorDataArray.count)
//        if sensorDataArray.isEmpty {
//            delegate?.writeToFileFinished("")
//            return
//        }
//        totalIterations = sensorDataArray.count / chunkSize
//        print("\(Date().timeIntervalSince1970) Number of chunks: \(totalIterations + 1) - ChunkSize: \(chunkSize) records")
//        results = sensorDataArray.chunked(into: chunkSize)
//        iterationCounter = -1
//        doNextPost()
//    }
    
    func postDataToKafka(payload: [[String : Any]]) async {
        startTime = payload[0]["time"] as! Double
        endTime = payload[payload.count-1]["time"] as! Double
        let body = getBody(payload: payload, keySchemaId: self.topicKeyId, valueSchemaId: self.topicValueId)
        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
            return
        }
        let compressedData = getCompressedData(data: data)
        await writeToFile(data: compressedData, fileName: "\(topicName)___\(Date().timeIntervalSince1970)_\(iterationCounter)")
//
////        writeToFile(data: compressedData, fileName: "acc_1807_\(iterationCounter)")
//        guard let request = getRequest(compressedData: compressedData, topicName: self.topicName!) else {return}
//        await send(request: request)
    }
    
//    func postDataToKafka(payload: [[String : Any]]) {
//        let body = getBody(payload: payload)
//        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
//            return
//        }
//        let compressedData = getCompressedData(data: data)
//
////        uploadData(data: data)
//        writeToFile(data: compressedData, fileName: "\(topicName)___\(Date().timeIntervalSince1970)_\(iterationCounter)")
////        guard let request = getRequest(compressedData: compressedData) else {return}
////        send(request: request)
//    }
    
    func getBody(payload: [[String: Any]], keySchemaId: Int, valueSchemaId: Int) -> [String: Any] {
        let key: [String : Any] = [
            "projectId": UserConfig.projectId, //["string": projectId],
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
    
//    func getBody(payload: [[String: Any]]) -> [String: Any] {
//        let key: [String : Any] = [
//            "projectId": projectId,
//            "userId": userId,
//            "sourceId": sourceId
//        ] as [String : Any]
//        let records = payload.map {
//            return ["key": key, "value": $0]
//        }
//
//        let body: [String: Any] = [
//            "key_schema_id": 1,
//            "value_schema_id": topicValueId,
//            "records": records
//        ]
//        return body
//    }
    
    
    // GENERAL
    func getCompressedData(data: Data) -> Data {
        let compressedData = try! data.gzipped(level: .bestCompression)
//        print("\(Date().timeIntervalSince1970) Chunk#: \(iterationCounter) - Compressed Data Size \(compressedData.count / 1024) kb")
        return compressedData
    }
    
//    func getTopic() {
////        if (topicName == nil) {
////            return
////        }
//        guard let url = URL(string: baseUrl + schemaEndpoint + topicName + "-value/versions/latest") else {
//            return
//        }
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        URLSession.shared.dataTask(with: request) { [self]
//            (data, response, error) in
//            let response = response as? HTTPURLResponse
//            handleError(response: response, data: data)
//
//            if let error = error {
//                print("\(Date().timeIntervalSince1970) An error occured.", error)
//                return
//            }
//
//            if let data = data {
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        print("\(Date().timeIntervalSince1970) TopicValueID = \(String(describing: json["id"]))")
//                        topicValueId = json["id"] as! Int
//                    }
//
//                } catch let error {
//                    print("\(Date().timeIntervalSince1970) We couldn't parse the data into JSON.", error)
//                }
//            }
//        }.resume()
//    }
    
    func getRequest(compressedData: Data) -> URLRequest? {
//        if (topicName == nil) {
//            return nil
//        }
        guard let baseUrl = RadarbaseConfig.baseUrl else {
          return nil
        }
        guard let url = URL(string: baseUrl + RadarbaseConfig.kafkaEndpoint + topicName) else {
            return nil
        }
        var request = URLRequest(url: url)
        let postLength = String(format: "%lu", UInt(compressedData.count))
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
//        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
       
        request.httpMethod = "POST"
//        request.setValue("application/vnd.radarbase.avro.v1+binary", forHTTPHeaderField: "Content-Type")
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/vnd.kafka.avro.v2+json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
        request.setValue( "Bearer \(UserConfig.token!)", forHTTPHeaderField: "Authorization")
        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
        
        request.httpBody = compressedData
        return request
    }
    
//    func send(request: URLRequest) {
//        let startTime = Date().timeIntervalSince1970
//        URLSession.shared.dataTask(with: request) { [self]
//            (data, response, error) in
//            let response = response as? HTTPURLResponse
////            print("Response Status Code: \(String(describing: response?.statusCode))")
//            handleError(response: response, data: data)
//
//            if let error = error {
//                print("\(Date().timeIntervalSince1970) An error occured.", error)
//                return
//            }
//
//            if let data = data {
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        let time = Date().timeIntervalSince1970 - startTime
//                        print("Data sent. \(self.iterationCounter)/\(self.totalIterations) in \(time)s")
//                        print("\(json)")
//                    }
//                } catch let error {
//                    print("\(Date().timeIntervalSince1970) We couldn't parse the data into JSON.", error)
//                }
//                self.doNextPost()
//            }
//        }.resume()
//    }
    
    func handleError(response: HTTPURLResponse?, data: Data?){
//        print("\(Date().timeIntervalSince1970) Response: \(String(describing: response?.statusCode))")
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
    
//    func doNextPost() {
////        print("doNextPost - \(iterationCounter) - \(totalIterations)")
////        if totalIterations == 0 {
////            return
////        }
//        if iterationCounter < totalIterations {
//            iterationCounter += 1
//            postDataToKafka(payload: results[iterationCounter])
//        } else {
//            print("\(Date().timeIntervalSince1970) Finished at: \(Date().timeIntervalSince1970)")
//            delegate?.writeToFileFinished(topicName)
//
////            uploadAllFiles()
////            uploadFile()
//        }
//    }
    
    func doNextPost() async {
        if iterationCounter < totalIterations {
            iterationCounter += 1
            await postDataToKafka(payload: results[iterationCounter])
        } else {
//            print("Finished at: \(Date().timeIntervalSince1970) # \(iterationCounter)")
            sensorDataArray = []
            processNextFetch()
//            delegate?.writeToFileFinished(topicName)
        }
    }
    
    
    
    
    
    
    
    
    
    
    
//    func sendFilesToServer() {
////        guard let request = getRequest(compressedData: compressedData) else {return}
////        send(request: request)
//        guard let url = URL(string: baseUrl + kafkaEndpoint + topicName) else { return }
//        var request = URLRequest(url: url)
////        let postLength = String(format: "%lu", UInt(compressedData.count))
////        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
////        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
//        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
//
//        request.httpMethod = "POST"
////        request.setValue("application/vnd.radarbase.avro.v1+binary", forHTTPHeaderField: "Content-Type")
//
////        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/vnd.kafka.avro.v2+json", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
////        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
////        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
////        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
//
////        request.httpBody = compressedData
//        let tempDir = FileManager.default.temporaryDirectory
//        let fileURL = tempDir.appendingPathComponent("acc_1807_0.txt.gz")
//        let identifierSuffix = "uniqueId"
////        let request = URLRequest(url: url)
////        let config = URLSessionConfiguration.background(withIdentifier: "uniqueId")
////        let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
//        new BackgroundSession().startUploadFile(for: request, fromFile: fileURL, identifier: identifierSuffix )
////        let task = session.uploadTask(with: request, fromFile: localURL)
////        task.resume()
//    }
    
//         func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
//             DispatchQueue.main.async {
//                 self.savedCompletionHandler?()
//                 self.savedCompletionHandler = nil
//             }
//         }

//         func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//             if let error = error {
//                 print(error)
//                 return
//             }
//             print("success")
//         }
//    func uploadData(data: Data) {
//
//        do {
//            guard let url = URL(string: baseUrl + kafkaEndpoint + topicName) else { return }
//            var request = URLRequest(url: url)
//    //        let postLength = String(format: "%lu", UInt(compressedData.count))
//    //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//    //        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
//            request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
//
//            request.httpMethod = "POST"
//    //        request.setValue("application/vnd.radarbase.avro.v1+binary", forHTTPHeaderField: "Content-Type")
//
//    //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/vnd.kafka.avro.v2+json", forHTTPHeaderField: "Content-Type")
//            request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
//    //        request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
//    //        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
//    //        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
//
//    //        request.httpBody = compressedData
////            let tempDir = FileManager.default.temporaryDirectory
////            let fileURL = tempDir.appendingPathComponent("acc_1807_0.txt.gz")
////            let identifierSuffix = "uniqueId"
////        do {
////            let request = URLRequest(url: URL(string: "your_upload_url_here")!)
////            let fileURL = URL(fileURLWithPath: "/path/to/your/file.txt") // Provide the actual file path
//
//            let backgroundSession = BackgroundSession.shared
//
//            let task = try backgroundSession.startUpload(for: request, from: data)
//
//            // You can optionally observe the progress or handle other aspects of the task here
//
//            // Save the completion handler for later use (if needed)
//            backgroundSession.savedCompletionHandler = {
//                // Handle completion, if necessary
//                print("777 Success")
//
//            }
//        } catch {
//            // Handle the error thrown by startUploadFile
//            print("444 Error: \(error.localizedDescription)")
//        }
//    }
//
    
    
    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        print("We're done here \(String(describing: error)) \(session) \(task)")
//    }
//    func updateLastFetched(date: Date) {}
}



@available(iOS 14.0, *)
extension SensorKitDataExtractor {
    // UTIL
    func writeToFile(data: Data, fileName: String) async {
        let tempDir = FileManager.default.temporaryDirectory
        let localURL = tempDir.appendingPathComponent(fileName + ".txt.gz")
        do {
            try data.write(to: localURL)
//            print("\(Date().timeIntervalSince1970) Write successful \(fileName)")
//            print("\(Date().timeIntervalSince1970) BeginDate \(String(describing: beginDate))")
            

            await self.doNextPost()
        } catch {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("\(Date().timeIntervalSince1970) Write failed")
        }
//        try? data.write(to: localURL)
        
    }
    
//    func writeToFile(data: Data, fileName: String){
//        let filename = getDocumentsDirectory().appendingPathComponent(fileName + ".txt.gz")
//        do {
//            try data.write(to: filename)
//            print("\(Date().timeIntervalSince1970) Write successful \(filename)")
//            self.doNextPost()
//        } catch {
//            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
//            print("\(Date().timeIntervalSince1970) Write failed")
//        }
//    }
//
//    func getDocumentsDirectory() -> URL {
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return paths[0]
//    }
}


