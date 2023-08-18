import SensorKit

@objc(RbSensorkitCordovaPlugin)
@available(iOS 14.0, *)
class RbSensorkitCordovaPlugin : CDVPlugin, SRSensorReaderDelegate {
    
    var reader: SRSensorReader = SRSensorReader(sensor: .ambientLightSensor)

    var startRecordingCommand: CDVInvokedUrlCommand?
    var stopRecordingCommand: CDVInvokedUrlCommand?
    var fetchDevicesCommand: CDVInvokedUrlCommand?
    var fetchDataCommand: CDVInvokedUrlCommand?
    var authorizationCommand: CDVInvokedUrlCommand?
    
    var devices: [SRDevice] = []
    var sensorDataArray: [[String: Any]] = []
    
    var topicName: String?
    var periodMili: Double = 0
    var chunkSize = 10000

    var topicKeyId = 1
    var topicValueId = 0
    var logTopicKeyId = 0
    var logTopicValueId = 0
    var lastRecordTS: Double = 0
    
    var totalIterations = 0
    var iterationCounter = -1
    var results: [[[String : Any]]] = []

    var startTime: Double = 0
    var endTime: Double = 0
    
    var callbackHelper: CallbackHelper?

    override func pluginInitialize() {
        log("Initializing Cordova plugin \(Constants.APP_NAME)");
        super.pluginInitialize()
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

    // MARK: isSensorAvailable
    @objc(isSensorAvailable:) func isSensorAvailable(command: CDVInvokedUrlCommand) {
        guard let sensor = command.arguments[0] as? String else {
            callbackHelper?.sendError(command, "NO_SENSOR")
            return
        }
        if _isSensorAvailable(sensor) {
            callbackHelper?.sendBool(command, true)
        } else {
            callbackHelper?.sendBool(command, false)
        }
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
        let kafkaEndpoint = command.arguments[5] as? String ?? "/kafka/topics/"
        let schemaEndpoint = command.arguments[6] as? String ?? "/schema/subjects/"

        Config.token = token
        Config.baseUrl = baseUrl
        Config.kafkaEndpoint = kafkaEndpoint
        Config.schemaEndpoint = schemaEndpoint
        Config.projectId = projectId
        Config.userId = userId
        Config.sourceId = sourceId
        
        callbackHelper?.sendEmpty(command)
        return
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
            // case "telephonySpeechMetrics":
            //    if #available(iOS 15.0, *) {
            //        sensor = .telephonySpeechMetrics
            //    }
            //    break
            case "visits":
                sensor = .visits
                break
            default:
                break
        }
        return sensor
    }
    
    // MARK: Select the Sensor
    @objc(selectSensor:) func selectSensor(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            guard let sensorString = command.arguments[0] as? String else {
                self.callbackHelper?.sendError(command, "NO_SENSOR")
                return
            }

            guard let sensor = self._getSRSensor(sensorString: sensorString) else {
                self.callbackHelper?.sendError(command, "INVALID_SENSOR")
                return
            }
            
            // self.reader = SRSensorReader(sensor: sensor)
            self.reader = .init(sensor: sensor)
            self.reader.delegate = self

            self.topicName = command.arguments[1] as? String ?? Constants.TOPIC_NAME[sensorString]
            self.periodMili = command.arguments[2] as? Double ?? Constants.DEFAULT_PERIOD[sensorString]!
            self.chunkSize = command.arguments[3] as? Int ?? Constants.DEFAULT_CHUNK_SIZE
            
            self.startRecordingCommand = nil
            self.stopRecordingCommand = nil
            self.fetchDevicesCommand = nil
            self.fetchDataCommand = nil
            self.authorizationCommand = nil
            
            self.devices = []
            self.sensorDataArray = []
            
            self.topicKeyId = 0
            self.topicValueId = 0
            self.logTopicKeyId = 0
            self.logTopicValueId = 0
            self.lastRecordTS = 0
            
            self.totalIterations = 0
            self.iterationCounter = -1
            self.results = []

            self.startTime = 0
            self.endTime = 0
            let authorizationState = self._checkAuthorization()
            if authorizationState == "AUTHORIZED" {
                self.callbackHelper?.sendEmpty(command)
                return
            }
            self.callbackHelper?.sendError(command, authorizationState)
        }
    }

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
    
    func sensorReader(_ reader: SRSensorReader, didChange authorizationStatus: SRAuthorizationStatus) {
        log("authorizationStatus didChange \(authorizationStatus) - \(reader.sensor)")
        var response = "NOT_DETERMIND"
        switch authorizationStatus {
        case .authorized:
            response = "AUTHORIZED"
            break
        case .denied:
            response = "DENIED"
            break
        case .notDetermined:
            response = "NOT_DETERMINED"
            break
        }
        self.callbackHelper?.sendString(self.authorizationCommand!, response, true)
    }
    
    // MARK: checkAuthorization
    @objc(checkAuthorization:) func checkAuthorization(command: CDVInvokedUrlCommand) {
        let response = _checkAuthorization()
        self.authorizationCommand = command
        self.callbackHelper?.sendString(command, response, true)
    }
    
    func _checkAuthorization() -> String {
        var response = "NOT_DETERMIND"
        switch self.reader.authorizationStatus {
        case .authorized:
            response = "AUTHORIZED"
            break
        case .denied:
            response = "DENIED"
            break
        case .notDetermined:
            response = "NOT_DETERMINED"
            break
        }
        return response
    }
    
    func _isAuthorized() -> Bool {
        if self.reader.authorizationStatus.rawValue == 1 {
            return true
        }
        return false
    }

    // MARK: startRecording
    @objc(startRecording:) func startRecording(command: CDVInvokedUrlCommand) {
        if !_isAuthorized() {
            callbackHelper?.sendError(command, "NOT_AUTHORIZED")
            return
        }
        self.startRecordingCommand = command
        reader.startRecording()
    }
    
    func sensorReaderWillStartRecording(_ reader: SRSensorReader) {
        callbackHelper?.sendEmpty(self.startRecordingCommand!)
    }
    
    func sensorReader(_ reader: SRSensorReader, startRecordingFailedWithError error: Error) {
        callbackHelper?.sendError(self.startRecordingCommand!, error.localizedDescription)
    }

    // MARK: stopRecording
    @objc(stopRecording:) func stopRecording(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            if !self._isAuthorized() {
                self.callbackHelper?.sendError(command, "NOT_AUTHORIZED")
                return
            }
            self.stopRecordingCommand = command
            self.reader.stopRecording()
        }
    }
    
    func sensorReaderDidStopRecording(_ reader: SRSensorReader) {
        callbackHelper?.sendEmpty(self.stopRecordingCommand!)
    }
    
    func sensorReader(_ reader: SRSensorReader, stopRecordingFailedWithError error: Error) {
        callbackHelper?.sendError(self.stopRecordingCommand!, error.localizedDescription)
    }

    // MARK: fetchDevices
    @objc(fetchDevices:) func fetchDevices(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            if !self._isAuthorized() {
                self.callbackHelper?.sendError(command, "NOT_AUTHORIZED")
                return
            }
            self.devices = []
            self.fetchDevicesCommand = command
            self.commandDelegate.run {
                self.reader.fetchDevices()
            }
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, didFetch devices: [SRDevice]) {
        self.devices = devices
        var resultObject: [[String: Any]] = []
        devices.forEach { device in
            resultObject.append([
                "name": device.name, // e.g. "My iPhone"
                "model": device.model, // e.g. @"iPhone"
                "systemName": device.systemName, // e.g. @"iOS"
                "systemVersion": device.systemVersion
            ])
        }
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["devices": resultObject], options: JSONSerialization.WritingOptions.prettyPrinted)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
            self.callbackHelper!.sendJson(self.fetchDevicesCommand!, json)
        } catch let error {
            self.callbackHelper?.sendError(self.fetchDevicesCommand!, error.localizedDescription)
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetchDevicesDidFailWithError error: Error) {
        self.callbackHelper?.sendError(self.fetchDevicesCommand!, error.localizedDescription)
    }

    // MARK: fetchData
    @objc(fetchData:) func fetchData(command: CDVInvokedUrlCommand) {
        if !_isAuthorized() {
            callbackHelper?.sendError(command, "NOT_AUTHORIZED")
            return
        }
        if (Config.token.isEmpty || Config.baseUrl.isEmpty || Config.projectId.isEmpty || Config.userId.isEmpty ) {
            callbackHelper?.sendError(command, "INVALID_CONFIG")
            return
        }

        guard let fromDateString = command.arguments[0] as? String, let toDateString = command.arguments[1] as? String else {
            callbackHelper?.sendError(command, "INVALID_DATES")
            return
        }

        guard let fromDate = fromDateString.toDate() as? NSDate, let toDate = toDateString.toDate() as? NSDate else {
            callbackHelper?.sendError(command, "INVALID_DATES")
            return
        }
        var deviceName: String? = nil
        if command.arguments.endIndex > 2 {
            deviceName = command.arguments[2] as? String ?? nil
        }
        
        self.fetchDataCommand = command
        self.commandDelegate.run {
            self.sensorDataArray = []
            self.totalIterations = 0
            self.iterationCounter = -1
            self.results = []

            self.startTime = 0
            self.endTime = 0
            let device: SRDevice? = self.devices.first(where: {$0.name == deviceName}) ?? SRDevice.current
            self.fetchSamples(fromDate: fromDate, toDate: toDate, device: device)
        }
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, failedWithError error: Error) {
        self.callbackHelper!.sendError(self.fetchDataCommand!, error.localizedDescription)
    }
    
    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        switch reader.sensor.rawValue {
        case "com.apple.SensorKit.motion.accelerometer":
            convertAccelerometerSensorData(result: result)
            break
        case "com.apple.SensorKit.als":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertAmbientLightData(result: result)
            }
            break
        case "com.apple.SensorKit.ambientPressure":
            break
        case "com.apple.SensorKit.deviceUsageReport":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertDeviceUsageSensorData(result: result)
            }
            break
        case "com.apple.SensorKit.keyboardMetrics":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertKeyboardMetricsSensorData(result: result)
            }
            break
        case "com.apple.SensorKit.messagesUsageReport":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertMessageUsageSensorData(result: result)
            }
            break
        case "com.apple.SensorKit.onWristState":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertOnWristSensorData(result: result)
            }
            break
        case "com.apple.SensorKit.pedometer.data":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertPedometerSensorData(result: result)
            }
            break
        case "com.apple.SensorKit.phoneUsageReport":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertPhoneUsageSensorData(result: result)
            }
            break
        case "com.apple.SensorKit.visits":
            let currentRecordTS: Double = result.timestamp.rawValue * 1000
            if currentRecordTS - lastRecordTS >= periodMili {
                lastRecordTS = currentRecordTS
                convertVisitsSensorData(result: result)
            }
            break
        default:
            log("Unhandled sample type: \(result.sample)")
            return true
        }
        return true
    }
    
    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
        log("Fetch completed \(reader.sensor.rawValue) (\(sensorDataArray.count))")
        // showFirstNResult(n: 10, array: sensorDataArray)
        Task {
            await processData(sensorDataArray: sensorDataArray)
        }
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
}
