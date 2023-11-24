import SensorKit
import CoreMotion

@objc(RbSensorkitCordovaPlugin)
@available(iOS 14.0, *)
class RbSensorkitCordovaPlugin : CDVPlugin, SensorKitDelegate { //SRSensorReaderDelegate {

    var sensorCounter: Int = -1
    var sensors: [SRSensor] = []
    var selectedSensor: SensorKitDataExtractor?
    
//    var reader: SRSensorReader = SRSensorReader(sensor: .ambientLightSensor)

//    var startRecordingCommand: CDVInvokedUrlCommand?
    
    var stopRecordingsCommand: CDVInvokedUrlCommand?
    var stopRecordingsSensors: [SRSensor] = []
    var stopRecordingsResponse: [[String: Any]] = []
    
    var checkAuthorizationCommand: CDVInvokedUrlCommand?
    var checkAuthorizationSensors: [SRSensor] = []
    var checkAuthorizationResponse: [[String: Any]] = []

    //    var fetchDevicesCommand: CDVInvokedUrlCommand?
//    var fetchDataCommand: CDVInvokedUrlCommand?
//    var authorizationCommand: CDVInvokedUrlCommand?
    
//    var devices: [SRDevice] = []
//    var sensorDataArray: [[String: Any]] = []
    
//    var topicName: String?
//    var periodMili: Double = 0
//    var chunkSize = 10000

//    var topicKeyId = 1
//    var topicValueId = 0
//    var logTopicKeyId = 0
//    var logTopicValueId = 0
//    var lastRecordTS: Double = 0
//    
//    var totalIterations = 0
//    var iterationCounter = -1
//    var results: [[[String : Any]]] = []
//
//    var startTime: Double = 0
//    var endTime: Double = 0
//    
    var callbackHelper: CallbackHelper?
    
    override func pluginInitialize() {
        log("Initializing Cordova plugin \(Constants.APP_NAME)");
        let lastFetched = PersistentContainer.shared.lastFetched
//        if lastFetched == nil {
            PersistentContainer.shared.loadInitialData()
//        }
        super.pluginInitialize()
        sensorCounter = -1
        callbackHelper = CallbackHelper(self.commandDelegate!)
    }
    
    // MARK: isSensorKitAvailable
    @objc(isSensorKitAvailable:) func isSensorKitAvailable(command: CDVInvokedUrlCommand) {
        if #available(iOS 14.0, *) {
            callbackHelper?.sendBool(command, true)
            return
        }
        callbackHelper?.sendBool(command, false)
    }

    // MARK: getAvailableSensors
    @objc(getAvailableSensors:) func getAvailableSensors(command: CDVInvokedUrlCommand) {
        let _sensors = _getAvailableSensors()
        var resultObject: [String] = []
        _sensors?.forEach { sensor in
            let sensorString = _getSensorString(sensor: sensor)
            if (sensorString != nil) {
                resultObject.append(sensorString!)
            }
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["sensors": resultObject], options: JSONSerialization.WritingOptions.prettyPrinted)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
            print("\(String(describing: json))")
            self.callbackHelper?.sendJson(command, json)
        } catch let error {
            self.callbackHelper?.sendError(command, error.localizedDescription)
        }
    }
    
    // MARK: isSensorAvailable
    @objc(isSensorAvailable:) func isSensorAvailable(command: CDVInvokedUrlCommand) {
        guard let sensorString = command.arguments[0] as? String else {
            callbackHelper?.sendError(command, "NO_SENSOR")
            return
        }
        if _isSensorAvailable(sensorString) {
            callbackHelper?.sendBool(command, true)
        } else {
            callbackHelper?.sendBool(command, false)
        }
    }
    
    // MARK: set config
    @objc(setConfig:) func setConfig(command: CDVInvokedUrlCommand) {
        if command.arguments.endIndex < 7 {
            callbackHelper?.sendError(command, "INVALID_CONFIG")
            return
        }
        guard let token = command.arguments[0] as? String,
              let baseUrl = command.arguments[1] as? String,
              let projectId = command.arguments[2] as? String,
              let userId = command.arguments[3] as? String else {
            callbackHelper?.sendError(command, "INVALID_CONFIG")
            return
        }

        let sourceId = command.arguments[4] as? String ?? ""
        let kafkaEndpoint = command.arguments[5] as? String ?? Constants.DefaultKafkaEndpoint
        let schemaEndpoint = command.arguments[6] as? String ?? Constants.DefaultSchemaEndpoint

        RadarbaseConfig.baseUrl = baseUrl
        RadarbaseConfig.kafkaEndpoint = kafkaEndpoint
        RadarbaseConfig.schemaEndpoint = schemaEndpoint
        
        UserConfig.token = token
        UserConfig.userId = userId
        UserConfig.projectId = ["string": projectId]
        UserConfig.sourceId = sourceId

//        Task {
//            self.logTopicKeyId = try await getTopicId(property: TopicKeyValue.KEY, topicName: "connect_data_log") ?? 0
//            self.logTopicValueId = try await getTopicId(property: TopicKeyValue.VALUE, topicName: "connect_data_log") ?? 0
//        }
        
        callbackHelper?.sendEmpty(command)
        return
    }
    
//    @objc(configureSensors:) func configureSensors(command: CDVInvokedUrlCommand) {
//        let configs = command.arguments
//        print("--- *** \(String(describing: configs))")
//        print("--- *** \(String(describing: configs?.count))")
//        configs?.forEach { config in
//            ConfigSensorPeriods.Accelerometer = (config as! [String: Any])["period"] as! Double
////            print("--- *** \(config)")
////            print("--- *** \(String(describing: (config as! [String: Any])["period"]))")
//        }
////        if command.arguments.endIndex < 7 {
////            callbackHelper?.sendError(command, "INVALID_CONFIG")
////            return
////        }
////        guard let token = command.arguments[0] as? String,
////              let baseUrl = command.arguments[1] as? String,
////              let projectId = command.arguments[2] as? String,
////              let userId = command.arguments[3] as? String else {
////            callbackHelper?.sendError(command, "INVALID_CONFIG")
////            return
////        }
////
////        let sourceId = command.arguments[4] as? String ?? ""
////        let kafkaEndpoint = command.arguments[5] as? String ?? Constants.DefaultKafkaEndpoint
////        let schemaEndpoint = command.arguments[6] as? String ?? Constants.DefaultSchemaEndpoint
////
////        RadarbaseConfig.baseUrl = baseUrl
////        RadarbaseConfig.kafkaEndpoint = kafkaEndpoint
////        RadarbaseConfig.schemaEndpoint = schemaEndpoint
////        
////        UserConfig.token = token
////        UserConfig.userId = userId
////        UserConfig.projectId = ["string": projectId]
////        UserConfig.sourceId = sourceId
////
//////        Task {
//////            self.logTopicKeyId = try await getTopicId(property: TopicKeyValue.KEY, topicName: "connect_data_log") ?? 0
//////            self.logTopicValueId = try await getTopicId(property: TopicKeyValue.VALUE, topicName: "connect_data_log") ?? 0
//////        }
////        
////        callbackHelper?.sendEmpty(command)
////        return
//    }
    
    // MARK: Authorize
    @objc(authorize:) func authorize(command: CDVInvokedUrlCommand) {
        guard let sensorsString: [String] = command.arguments as? [String] else {
            self.callbackHelper?.sendError(command, "NO_SENSOR")
            return
        }
        let sensors: Set<SRSensor> = Set(sensorsString.map { _getSRSensor(sensorString: $0) ?? nil}.compactMap { $0 })
        if sensors.isEmpty {
            self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
            return
        }
        self.commandDelegate.run {
            SRSensorReader.requestAuthorization(
                sensors: sensors, completion: { (error: Error?) in
                    if let error = error {
                        self.callbackHelper?.sendError(command, error.localizedDescription)
                    } else {
                        self.callbackHelper?.sendEmpty(command)
                    }
                })
        }
    }

    
    // MARK: Select the Sensor
    @objc(selectSensors:) func selectSensors(command: CDVInvokedUrlCommand) {
        print("--$$ selectSensors")
        guard let sensorsConfig: [[String: Any]] = command.arguments as? [[String: Any]] else {
            print("--$$ selectSensors NO_SENSOR")

            self.callbackHelper?.sendError(command, "NO_SENSOR")
            return
        }
        print("--$$ selectSensors \(sensorsConfig)")
        var sensors: Set<SRSensor> = Set()
        sensorsConfig.forEach { sensorConfig in
            guard let sensorString: String = sensorConfig["sensor"] as? String else {
                print("--$$ selectSensors NO_SENSOR")
                self.callbackHelper?.sendError(command, "NO_SENSOR")
                return
            }
            guard let sensor: SRSensor = _getSRSensor(sensorString: sensorString) else {
                print("--$$ selectSensors INVALID_SENSOR")
                self.callbackHelper?.sendError(command, "INVALID_SENSOR")
                return
            }
            sensors.insert(sensor)
            if let sensorPeriod = sensorConfig["period"] as? Double {
                print("--$$ selectSensors sensorPeriod = \(sensorPeriod)")
                ConfigSensor.periods[sensorString] = sensorPeriod
            }
            
            if let sensorTopic = sensorConfig["topic"] as? String {
                print("--$$ selectSensors sensorTopic = \(sensorTopic)")

                ConfigSensor.topics[sensorString] = sensorTopic
            }

        }

        if sensors.isEmpty {
            print("--$$ selectSensors NO_VALID_SENSOR")

            self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
            return
        }
        print("--$$ selectSensors \(sensors)")

        
        self.sensors = Array(sensors)
        self.callbackHelper?.sendEmpty(command)
    }

//    // MARK: Select the Sensor
//    @objc(selectSensors:) func selectSensors(command: CDVInvokedUrlCommand) {
//        guard let sensorsString: [String] = command.arguments as? [String] else {
//            self.callbackHelper?.sendError(command, "NO_SENSOR")
//            return
//        }
//        let sensors: Set<SRSensor> = Set(sensorsString.map { _getSRSensor(sensorString: $0) ?? nil}.compactMap { $0 })
//        if sensors.isEmpty {
//            self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
//            return
//        }
//        
//        self.sensors = Array(sensors)
//        self.callbackHelper?.sendEmpty(command)
//    }
    
    @objc(getCacheStatus:) func getCacheStatus(command: CDVInvokedUrlCommand) {
        var counter: Int = 0
        do {
            let fileManager = FileManager.default
            let tempPath = fileManager.temporaryDirectory.path
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(tempPath)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".txt.gz")) {
                    counter = counter + 1
                }
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        callbackHelper?.sendNumber(command, counter)
    }
    
    @objc(clearCache:) func clearCache(command: CDVInvokedUrlCommand) {
        _deleteAllFiles()
        callbackHelper?.sendEmpty(command)
    }
    
    @objc(uploadCache:) func uploadCache(command: CDVInvokedUrlCommand) {
        _uploadAllFiles()
        callbackHelper?.sendEmpty(command)
    }
    
    @objc(startFetchingAll:) func startFetchingAll(command: CDVInvokedUrlCommand) {
        print("plugin startFetchingAll")
        _changeSensor()
    }
    
    // MARK: stopRecording
    @objc(stopRecording:) func stopRecording(command: CDVInvokedUrlCommand) {
        guard let sensorsString: [String] = command.arguments as? [String] else {
            self.callbackHelper?.sendError(command, "NO_SENSOR")
            return
        }
        let sensors: Set<SRSensor> = Set(sensorsString.map { _getSRSensor(sensorString: $0) ?? nil}.compactMap { $0 })
        if sensors.isEmpty {
            self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
            return
        }
        
        stopRecordingsCommand = command
        stopRecordingsResponse = []
        stopRecordingsSensors = Array(sensors)
        stopRecordingsSensors.forEach { sensor in
            let dataExtractor = _generateDataExtractor(sensor: sensor)
            if !_isAuthorized(dataExtractor) {
                // write in response object that it is not authorized
                stopRecordingsResponse.append([sensor.rawValue: "NOT_AUTHORIZED"])
            } else {
                dataExtractor?.stopRecording()
            }
        }
        // listen to delegate and return back the response
        
//        self.commandDelegate.run {
//            if !self._isAuthorized() {
//                self.callbackHelper?.sendError(command, "NOT_AUTHORIZED")
//                return
//            }
//            self.stopRecordingCommand = command
//            self.reader.stopRecording()
//        }
    }
    
    // MARK: checkAuthorization
    @objc(checkAuthorization:) func checkAuthorization(command: CDVInvokedUrlCommand) {
        guard let sensorsString: [String] = command.arguments as? [String] else {
            self.callbackHelper?.sendError(command, "NO_SENSOR")
            return
        }
        let sensors: Set<SRSensor> = Set(sensorsString.map { _getSRSensor(sensorString: $0) ?? nil}.compactMap { $0 })
        if sensors.isEmpty {
            self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
            return
        }
        
        checkAuthorizationCommand = command
        checkAuthorizationResponse = []
        checkAuthorizationSensors = Array(sensors)
        checkAuthorizationSensors.forEach { sensor in
            let dataExtractor = _generateDataExtractor(sensor: sensor)
            let response = _checkAuthorization(dataExtractor: dataExtractor!)
            checkAuthorizationResponse.append([sensor.rawValue: response])
        }
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["results": stopRecordingsResponse], options: JSONSerialization.WritingOptions.prettyPrinted)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
            self.callbackHelper?.sendJson(stopRecordingsCommand!, json)
        } catch let error {
            self.callbackHelper?.sendError(stopRecordingsCommand!, error.localizedDescription)
        }
        
//        let response = _checkAuthorization()
////        self.authorizationCommand = command
//        self.callbackHelper?.sendString(command, response, true)
    }
    
    // MARK: echo
    @objc(echo:) func echo(command: CDVInvokedUrlCommand) {
        var pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR)

        let msg = command.arguments[0] as? String ?? ""

        if msg.count > 0 {
          let toastController: UIAlertController =
            UIAlertController(
              title: "",
              message: msg,
              preferredStyle: .alert
            )

          self.viewController?.present(
            toastController,
            animated: true,
            completion: nil
          )

          DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            toastController.dismiss(
              animated: true,
              completion: nil
            )
          }

          pluginResult = CDVPluginResult(
            status: CDVCommandStatus_OK,
            messageAs: msg
          )
        }

        self.commandDelegate!.send(
          pluginResult,
          callbackId: command.callbackId
        )
    }
    
    
    func _generateDataExtractor(sensor: SRSensor) -> SensorKitDataExtractor? {
        switch sensor {
        case .accelerometer:
            return AccelerometerDataExtractor(periodMili: ConfigSensor.periods["accelerometer"]!, topicName: ConfigSensor.topics["accelerometer"]!)
        case .ambientLightSensor:
            return AmbientLightDataExtractor(periodMili: ConfigSensor.periods["ambientLightSensor"]!, topicName: ConfigSensor.topics["ambientLightSensor"]!)
        case .deviceUsageReport:
            return DeviceUsageDataExtractor(periodMili: ConfigSensor.periods["deviceUsageReport"]!, topicName: ConfigSensor.topics["deviceUsageReport"]!)
        case .keyboardMetrics:
            return KeyboardMetricsDataExtractor(periodMili: ConfigSensor.periods["keyboardMetrics"]!, topicName: ConfigSensor.topics["keyboardMetrics"]!)
        case .messagesUsageReport:
            return MessageUsageReportDataExtractor(periodMili: ConfigSensor.periods["messagesUsageReport"]!, topicName: ConfigSensor.topics["messagesUsageReport"]!)
        case .onWristState:
            return OnWristStateDataExtractor(periodMili: ConfigSensor.periods["onWristState"]!, topicName: ConfigSensor.topics["onWristState"]!)
        case .pedometerData:
            return PedometerDataExtractor(periodMili: ConfigSensor.periods["pedometerData"]!, topicName: ConfigSensor.topics["pedometerData"]!)
        case .phoneUsageReport:
            return PhoneUsageReportDataExtractor(periodMili: ConfigSensor.periods["phoneUsageReport"]!, topicName: ConfigSensor.topics["phoneUsageReport"]!)
        case .visits:
            return VisitsDataExtractor(periodMili: ConfigSensor.periods["visits"]!, topicName: ConfigSensor.topics["visits"]!)
        default:
            break
        }
        
        if #available(iOS 15.4, *) {
            switch sensor {
            case .ambientPressure:
                return AmbientPressureDataExtractor(periodMili: ConfigSensor.periods["ambientPressure"]!, topicName: ConfigSensor.topics["ambientPressure"]!)
            default:
                break
            }
        }
        
        if #available(iOS 15.0, *) {
            switch sensor {
            case .telephonySpeechMetrics:
                return TelephonySpeechMetricsDataExtractor(periodMili: ConfigSensor.periods["telephonySpeechMetrics"]!, topicName: ConfigSensor.topics["telephonySpeechMetrics"]!)
            default:
                break
            }
        }
        return nil
    }

    func _isAuthorized(_ dataExtractor: SensorKitDataExtractor?) -> Bool {
        if dataExtractor?.reader?.authorizationStatus.rawValue == 1 {
            return true
        }
        return false
    }

    func _changeSensor() {
        print("changeSensor")
        print("\(sensors)")
        print("\(self.sensorCounter)")

        sensorCounter = sensorCounter + 1
        print("\(self.sensorCounter)")
        let sensor = sensors[sensorCounter]
        selectedSensor = _generateDataExtractor(sensor: sensor)
        selectedSensor?.delegate = self
        // start sensor
        selectedSensor?.startRecording()
        selectedSensor?.startFetching()
    }
    
    func __didStopRecording(sensor: SRSensor) {
        stopRecordingsResponse.append([sensor.rawValue: "STOPPED"])
        if stopRecordingsSensors.count == stopRecordingsResponse.count {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["results": stopRecordingsResponse], options: JSONSerialization.WritingOptions.prettyPrinted)
                let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
                self.callbackHelper?.sendJson(stopRecordingsCommand!, json)
            } catch let error {
                self.callbackHelper?.sendError(stopRecordingsCommand!, error.localizedDescription)
            }
        }
    }
    
    func __failedStopRecording(sensor: SRSensor, error: Error) {
        stopRecordingsResponse.append([sensor.rawValue: error])
        if stopRecordingsSensors.count == stopRecordingsResponse.count {
            self.callbackHelper?.sendError(stopRecordingsCommand!, error.localizedDescription)
        }
    }
    
    func __fetchCompletedForOneSensor(date: Date) {
        print("fetchCompletedForOneSensor \(sensors)")
        print("\(Date().timeIntervalSince1970) writeToFileFinished from DELEGATE")
        if sensorCounter < sensors.count - 1 {
            _changeSensor()
        } else {
            _updateLastFetch(date: date)
            _uploadAllFiles()
        }
    }
    
    func _updateLastFetch(date: Date) {
        PersistentContainer.shared.lastFetched = date
    }
    
    func _getSensorString(sensor: SRSensor) -> String? {
        var sensorString: String? = nil
        switch sensor {
        case .accelerometer:
            sensorString = "accelerometer"
            break
        case .ambientLightSensor:
            sensorString = "ambientLightSensor"
            break
        case  .deviceUsageReport:
            sensorString = "deviceUsageReport"
            break
        case .keyboardMetrics:
            sensorString = "keyboardMetrics"
            break
        case .messagesUsageReport:
            sensorString = "messagesUsageReport"
            break
        case .onWristState:
            sensorString = "onWristState"
            break
        case .pedometerData:
            sensorString = "pedometerData"
            break
        case .phoneUsageReport:
            sensorString = "phoneUsageReport"
            break
         case .rotationRate:
            sensorString = "rotationRate"
            break
        case .visits:
            sensorString = "visits"
            break
        default:
            break
        }
        
        if #available(iOS 15.4, *) {
            switch sensor {
            case .ambientPressure:
            sensorString = "ambientPressure"
            default:
                break
            }
        }
        
        if #available(iOS 15.0, *) {
            switch sensor {
            case .siriSpeechMetrics:
               sensorString = "siriSpeechMetrics"
                break
            default:
                break
            }
        }
        
        if #available(iOS 16.4, *) {
            switch sensor {
            case .mediaEvents:
                sensorString = "mediaEvents"
                break
            default:
                break
            }
        }
        
        if #available(iOS 17.0, *) {
            switch sensor {
            case .telephonySpeechMetrics:
                sensorString = "telephonySpeechMetrics"
                break
            default:
                break
            }
        }
        
        
        return sensorString
    }
    
    func _getAvailableSensors() -> [SRSensor]? {
        var sensors: [SRSensor] = [.accelerometer, .ambientLightSensor, .deviceUsageReport, .keyboardMetrics,  .messagesUsageReport, .onWristState, .pedometerData, .phoneUsageReport, .rotationRate, .visits]
        if #available(iOS 15.0, *) {
            sensors.append(.siriSpeechMetrics)
            sensors.append(.telephonySpeechMetrics)
        }
        if #available(iOS 15.4, *) {
            sensors.append(.ambientPressure)
        }
        if #available(iOS 16.4, *) {
            sensors.append(.mediaEvents)
        }
        if #available(iOS 17.0, *) {
            sensors.append(.faceMetrics)
            sensors.append(.heartRate)
            sensors.append(.odometer)
            sensors.append(.wristTemperature)
        }
        return sensors
    }
    
    func _isSensorAvailable(_ sensor: String) -> Bool {
        switch (sensor) {
            case "accelerometer", "ambientLightSensor", "deviceUsageReport", "keyboardMetrics", "messagesUsageReport", "onWristState", "pedometerData", "phoneUsageReport", "rotationRate", "visits":
                return true
            case "ambientPressure":
                if #available(iOS 15.4, *) {
                    return true
                }
                break
            case "mediaEvents":
                if #available(iOS 16.4, *) {
                    return true
                }
                break
            case "siriSpeechMetrics", "telephonySpeechMetrics":
                if #available(iOS 15.0, *) {
                    return true
                }
                break
            default:
                return false
        }
        return false
    }
    
    func __isSensorAvailable(sensor: SRSensor) -> Bool {
        return ((_getAvailableSensors()?.contains(sensor)) != nil)
    }

    func _getSRSensor(sensorString: String) -> SRSensor? {
        var sensor: SRSensor? = nil
        switch sensorString {
            case "accelerometer":
                sensor = .accelerometer
                break
            case "ambientLightSensor":
                sensor = .ambientLightSensor
                break
            case "ambientPressure":
                if #available(iOS 15.4, *) {
                    sensor = .ambientPressure
                }
                break
            case "deviceUsageReport":
                sensor = .deviceUsageReport
                break
            case "keyboardMetrics":
                sensor = .keyboardMetrics
                break
            // case "mediaEvents":
            //    if #available(iOS 16.4, *) {
            //        sensor = .mediaEvents
            //    }
            //    break
            case "messagesUsageReport":
                sensor = .messagesUsageReport
                break
            case "onWristState":
                sensor = .onWristState
                break
            case "pedometerData":
                sensor = .pedometerData
                break
            case "phoneUsageReport":
                sensor = .phoneUsageReport
                break
            // case "rotationRate":
            //    sensor = .rotationRate
            //    break
            // case "siriSpeechMetrics":
            //    if #available(iOS 15.0, *) {
            //        sensor = .siriSpeechMetrics
            //    }
            //    break
             case "telephonySpeechMetrics":
                if #available(iOS 17.0, *) {
                    sensor = .telephonySpeechMetrics
                }
                break
            case "visits":
                sensor = .visits
                break
            default:
                break
        }
        return sensor
    }
    
    // MARK: Cache / Temp Folder and files
    func _uploadAllFiles() {
        print("UPLOAD ALL FILES")
        do {
            let fileManager = FileManager.default
            let tempPath = fileManager.temporaryDirectory.path
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(tempPath)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".txt.gz")) {
                    //let filePathName = "\(tempPath)/\(fileName)"
                    print("\(Date().timeIntervalSince1970) File: \(fileName)")
                    _uploadFile(fileName: fileName)
                }
            }

        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func _uploadFile(fileName: String) {
        do {
            // get topic name from the file
            let topicName = fileName.components(separatedBy: "___")[0]
            guard let url = URL(string: RadarbaseConfig.baseUrl + RadarbaseConfig.kafkaEndpoint + topicName) else { return }
            var request = URLRequest(url: url)
    //        let postLength = String(format: "%lu", UInt(compressedData.count))
    //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    //        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
            request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
           
            request.httpMethod = "POST"
    //        request.setValue("application/vnd.radarbase.avro.v1+binary", forHTTPHeaderField: "Content-Type")
            
    //        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/vnd.kafka.avro.v2+json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
            request.setValue( "Bearer \(UserConfig.token)", forHTTPHeaderField: "Authorization")
    //        request.addValue(postLength, forHTTPHeaderField: "Content-Length")
    //        request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
            
    //        request.httpBody = compressedData
//            let tempDir = FileManager.default.temporaryDirectory
//            let fileURL = tempDir.appendingPathComponent(fileName)
            let identifierSuffix = "uniqueId"
//        do {
//            let request = URLRequest(url: URL(string: "your_upload_url_here")!)
//            let fileURL = URL(fileURLWithPath: "/path/to/your/file.txt") // Provide the actual file path

            let backgroundSession = BackgroundSession.shared
            _ = try backgroundSession.startUploadFile(for: request, fromFile: fileName, identifier: identifierSuffix)
            
            // You can optionally observe the progress or handle other aspects of the task here

            // Save the completion handler for later use (if needed)
            backgroundSession.savedCompletionHandler = {
                // Handle completion, if necessary
                print("777 Success")

            }
        } catch {
            // Handle the error thrown by startUploadFile
            print("444 Error: \(error.localizedDescription)")
        }
    }
    
    func _deleteAllFiles() {
        do {
            let fileManager = FileManager.default
            let tempPath = fileManager.temporaryDirectory.path
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(tempPath)")
            print("ALL AVAILABLE FILES TO BE DELETED: \(fileNames.count)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".txt.gz")) {
                    let filePathName = "\(tempPath)/\(fileName)"
                    print("File: \(fileName)")
                    try fileManager.removeItem(atPath: filePathName)
                }
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    func startSensors(sensor: [SRSensor]) {
        
    }
    
    
    

    
//
//    fetchFromSensors(){
//
//    }
//
//    fetchFromSingleSensor(){
//
//
//    }
//
//    getDevicesOfSingleSensor(){}
    
//    @objc(selectSensor:) func selectSensor(command: CDVInvokedUrlCommand) {
//        self.commandDelegate.run {
//            guard let sensorString = command.arguments[0] as? String else {
//                self.callbackHelper?.sendError(command, "NO_SENSOR")
//                return
//            }
//
//            guard let sensor = self._getSRSensor(sensorString: sensorString) else {
//                self.callbackHelper?.sendError(command, "INVALID_SENSOR")
//                return
//            }
//            
//            // self.reader = SRSensorReader(sensor: sensor)
//            self.reader = .init(sensor: sensor)
//            self.reader.delegate = self
//
//            self.topicName = command.arguments[1] as? String ?? Constants.TOPIC_NAME[sensorString]
//            self.periodMili = command.arguments[2] as? Double ?? Constants.DEFAULT_PERIOD[sensorString]!
//            self.chunkSize = command.arguments[3] as? Int ?? Constants.DEFAULT_CHUNK_SIZE
//            
//            self.startRecordingCommand = nil
//            self.stopRecordingCommand = nil
//            self.fetchDevicesCommand = nil
//            self.fetchDataCommand = nil
//            self.authorizationCommand = nil
//            
//            self.devices = []
//            self.sensorDataArray = []
//            
//            self.topicKeyId = 0
//            self.topicValueId = 0
//            self.logTopicKeyId = 0
//            self.logTopicValueId = 0
//            self.lastRecordTS = 0
//            
//            self.totalIterations = 0
//            self.iterationCounter = -1
//            self.results = []
//
//            self.startTime = 0
//            self.endTime = 0
//            let authorizationState = self._checkAuthorization()
//            if authorizationState == "AUTHORIZED" {
//                self.callbackHelper?.sendEmpty(command)
//                return
//            }
//            self.callbackHelper?.sendError(command, authorizationState)
//        }
//    }

    
    
//    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {
//        log("authorizationStatus didChange \(authorizationStatus) - \(reader.sensor)")
//        var response = "NOT_DETERMIND"
//        switch authorizationStatus {
//        case .authorized:
//            response = "AUTHORIZED"
//            break
//        case .denied:
//            response = "DENIED"
//            break
//        case .notDetermined:
//            response = "NOT_DETERMINED"
//            break
//        }
//        self.callbackHelper?.sendString(self.authorizationCommand!, response, true)
//    }
    
    // MARK: checkAuthorization
//    @objc(checkAuthorization:) func checkAuthorization(command: CDVInvokedUrlCommand) {
//        let response = _checkAuthorization()
//        self.authorizationCommand = command
//        self.callbackHelper?.sendString(command, response, true)
//    }
    
    func _checkAuthorization(dataExtractor: SensorKitDataExtractor) -> String {
        var response = "NOT_DETERMIND"
        switch dataExtractor.reader?.authorizationStatus {
        case .authorized:
            response = "AUTHORIZED"
            break
        case .denied:
            response = "DENIED"
            break
        case .notDetermined:
            response = "NOT_DETERMINED"
            break
        default:
            break
        }
        return response
    }
    
//
//    func _isAuthorized() -> Bool {
//        if self.reader.authorizationStatus.rawValue == 1 {
//            return true
//        }
//        return false
//    }

    // MARK: startRecording
//    @objc(startRecording:) func startRecording(command: CDVInvokedUrlCommand) {
//        if !_isAuthorized() {
//            callbackHelper?.sendError(command, "NOT_AUTHORIZED")
//            return
//        }
//        self.startRecordingCommand = command
//        reader.startRecording()
//    }
//    
//    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
//        callbackHelper?.sendEmpty(self.startRecordingCommand!)
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
//        callbackHelper?.sendError(self.startRecordingCommand!, error.localizedDescription)
//    }

 
//    
//    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
//        callbackHelper?.sendEmpty(self.stopRecordingCommand!)
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, stopRecordingFailedWithError error: Error) {
//        callbackHelper?.sendError(self.stopRecordingCommand!, error.localizedDescription)
//    }

    // MARK: fetchDevices
//    @objc(fetchDevices:) func fetchDevices(command: CDVInvokedUrlCommand) {
//        self.commandDelegate.run {
//            if !self._isAuthorized() {
//                self.callbackHelper?.sendError(command, "NOT_AUTHORIZED")
//                return
//            }
//            self.devices = []
//            self.fetchDevicesCommand = command
//            self.commandDelegate.run {
//                self.reader.fetchDevices()
//            }
//        }
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
//        self.devices = devices
//        var resultObject: [[String: Any]] = []
//        devices.forEach { device in
//            resultObject.append([
//                "name": device.name, // e.g. "My iPhone"
//                "model": device.model, // e.g. @"iPhone"
//                "systemName": device.systemName, // e.g. @"iOS"
//                "systemVersion": device.systemVersion
//            ])
//        }
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: ["devices": resultObject], options: JSONSerialization.WritingOptions.prettyPrinted)
//            let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
//            self.callbackHelper!.sendJson(self.fetchDevicesCommand!, json)
//        } catch let error {
//            self.callbackHelper?.sendError(self.fetchDevicesCommand!, error.localizedDescription)
//        }
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
//        self.callbackHelper?.sendError(self.fetchDevicesCommand!, error.localizedDescription)
//    }

    // MARK: fetchData
//    @objc(fetchData:) func fetchData(command: CDVInvokedUrlCommand) {
//        if !_isAuthorized() {
//            callbackHelper?.sendError(command, "NOT_AUTHORIZED")
//            return
//        }
//        if (Config.token.isEmpty || Config.baseUrl.isEmpty || Config.projectId.isEmpty || Config.userId.isEmpty ) {
//            callbackHelper?.sendError(command, "INVALID_CONFIG")
//            return
//        }
//
//        guard let fromDateString = command.arguments[0] as? String, let toDateString = command.arguments[1] as? String else {
//            callbackHelper?.sendError(command, "INVALID_DATES")
//            return
//        }
//
//        guard let fromDate = fromDateString.toDate() as? NSDate, let toDate = toDateString.toDate() as? NSDate else {
//            callbackHelper?.sendError(command, "INVALID_DATES")
//            return
//        }
//        var deviceName: String? = nil
//        if command.arguments.endIndex > 2 {
//            deviceName = command.arguments[2] as? String ?? nil
//        }
//        
//        self.fetchDataCommand = command
//        self.commandDelegate.run {
//            self.sensorDataArray = []
//            self.totalIterations = 0
//            self.iterationCounter = -1
//            self.results = []
//
//            self.startTime = 0
//            self.endTime = 0
//            self.lastRecordTS = 0
//            let device: SRDevice? = self.devices.first(where: {$0.name == deviceName}) ?? SRDevice.current
//            self.fetchSamples(fromDate: fromDate, toDate: toDate, device: device)
//        }
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
//        self.callbackHelper!.sendError(self.fetchDataCommand!, error.localizedDescription)
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
//        switch reader.sensor.rawValue {
//        case "com.apple.SensorKit.motion.accelerometer":
//            convertAccelerometerSensorData(result: result)
//            break
//        case "com.apple.SensorKit.als":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertAmbientLightData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.ambientPressure":
//            convertAmbientPressureSensorData(result: result)
//            break
//        case "com.apple.SensorKit.deviceUsageReport":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertDeviceUsageSensorData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.keyboardMetrics":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertKeyboardMetricsSensorData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.messagesUsageReport":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertMessageUsageSensorData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.onWristState":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertOnWristSensorData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.pedometer.data":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertPedometerSensorData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.phoneUsageReport":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertPhoneUsageSensorData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.speechMetrics.telephony":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertTelephonySpeechMetricsData(result: result)
//            }
//            break
//        case "com.apple.SensorKit.visits":
//            let currentRecordTS: Double = result.timestamp.rawValue * 1000
//            if currentRecordTS - lastRecordTS >= periodMili {
//                lastRecordTS = currentRecordTS
//                convertVisitsSensorData(result: result)
//            }
//            break
//        default:
//            log("Unhandled sample type: \(result.sample)")
//            return true
//        }
//        return true
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        log("Fetch completed \(reader.sensor.rawValue) (\(sensorDataArray.count))")
//        // showFirstNResult(n: 10, array: sensorDataArray)
//        Task {
//            await processData(sensorDataArray: sensorDataArray)
//        }
//    }


    
    
//    var deviceQueue = OperationQueue()
    
    var magneticFieldTopicName: String?
    var magneticFieldPeriodMili: Double = 0
    var magneticFieldChunkSize = 10000
    
    var magneticFieldTopicKeyId: Int?
    var magneticFieldTopicValueId: Int?
    
    var fetchMagneticFieldCommand: CDVInvokedUrlCommand?
    
    // MARK: Select Magnetic Field Sensor
    @objc(selectMagneticFieldSensor:) func selectMagneticFieldSensor(command: CDVInvokedUrlCommand) {
//        self.commandDelegate.run {
//            self.magneticFieldTopicName = command.arguments[0] as? String ?? Constants.TOPIC_NAME["magneticField"]
//            self.magneticFieldPeriodMili = command.arguments[1] as? Double ?? Constants.DEFAULT_PERIOD["magneticField"]!
//            self.magneticFieldChunkSize = command.arguments[2] as? Int ?? Constants.DEFAULT_CHUNK_SIZE
//            
//            self.magneticFieldTopicKeyId = nil
//            self.magneticFieldTopicValueId = nil
//            Task {
//                do {
//                    self.magneticFieldTopicKeyId = try await self.getTopicId(property: TopicKeyValue.KEY, topicName: self.magneticFieldTopicName!) ?? 0
//                    self.magneticFieldTopicValueId = try await self.getTopicId(property: TopicKeyValue.VALUE, topicName: self.magneticFieldTopicName!) ?? 0
//                    if self.magneticFieldTopicKeyId == nil || self.magneticFieldTopicValueId == nil {
//                        self.callbackHelper?.sendError(command, "INVALID_TOPIC")
//                        return
//                    }
//                    self.callbackHelper?.sendEmpty(command)
//                } catch {
//                    self.callbackHelper?.sendError(command, "FAIELD_GET_TOPIC")
//                    return
//                }
//            }
//            
//        }
    }
    
    var motionManager: CMMotionManager!

    // MARK: MagneticFiled Sensor
    @objc(stopMagneticFieldUpdate:) func stopMagneticFieldUpdate(command: CDVInvokedUrlCommand) {
        motionManager.stopMagnetometerUpdates()
        self.callbackHelper?.sendEmpty(command)
    }
    
    // MARK: MagneticFiled Sensor
    @objc(startMagneticFieldUpdate:) func startMagneticFieldUpdate(command: CDVInvokedUrlCommand) {
        if self.magneticFieldTopicKeyId == nil || magneticFieldTopicValueId == nil {
            self.callbackHelper?.sendError(command, "INVALID_TOPIC")
            return
        }

        self.fetchMagneticFieldCommand = command
        motionManager = CMMotionManager()
        var mfSensorDataArray: [[String: Any]] = []

        if motionManager.isMagnetometerAvailable {
            motionManager.magnetometerUpdateInterval = self.magneticFieldPeriodMili / 1000
            motionManager.startMagnetometerUpdates(to: OperationQueue.main) { (data, error) in
                let time = Date().timeIntervalSince1970
                mfSensorDataArray.append([
                    "time": time,
                    "timeReceived": time,
                    "x": data!.magneticField.x as Double,
                    "y": data!.magneticField.y as Double,
                    "z": data!.magneticField.z as Double,
                ])
                if mfSensorDataArray.count > (self.magneticFieldChunkSize - 1) {
//                    log("Processing Data started at: \(Date().timeIntervalSince1970)")
//                    log("Total number of records: \(mfSensorDataArray.count)")
//                    let body = self.getBody(payload: mfSensorDataArray, keySchemaId: self.magneticFieldTopicKeyId!, valueSchemaId: self.magneticFieldTopicValueId!)
//
//                    mfSensorDataArray = []
//                    guard let data = try? JSONSerialization.data(withJSONObject: body) else {
//                        return
//                    }
//                    let compressedData = self.getCompressedData(data: data)
//                    guard let request = self.getRequest(compressedData: compressedData, topicName: self.magneticFieldTopicName!) else {return}
//                    
//                    Task {
//                        await self.sendMagneticFieldData(request: request)
//                    }
                }
            }
        }
    }
}
