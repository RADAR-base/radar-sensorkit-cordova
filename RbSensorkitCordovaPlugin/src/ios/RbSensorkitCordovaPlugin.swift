import SensorKit
import CoreMotion

@objc(RbSensorkitCordovaPlugin)
@available(iOS 14.0, *)
class RbSensorkitCordovaPlugin : CDVPlugin {

//    var logTopicKeyId = 0
//    var logTopicValueId = 0
    
    var sensorCounter: Int = -1
    var lockStartFetchingAll = false

    var sensors: [SRSensor] = []
    var selectedSensor: SensorKitDataExtractor?
    var selectedStopRecordingSensor: SensorKitDataExtractor?

    
    var stopRecordingsCommand: CDVInvokedUrlCommand?
    var stopRecordingsSensors: [SRSensor] = []
    var stopRecordingsResponse: [[String: Any]] = []
    var stopRecordingCounter = 0
    
    var checkAuthorizationCommand: CDVInvokedUrlCommand?
    var checkAuthorizationSensors: [SRSensor] = []
    var checkAuthorizationResponse: [[String: Any]] = []
    
    var startFetchingAllCommand: CDVInvokedUrlCommand?
    
    var uploadCacheCommand: CDVInvokedUrlCommand?
    var totalFilesToUpload = 0
    var uploadedFileCounter = 0

    var callbackHelper: CallbackHelper?
    
    override func pluginInitialize() {
        log("Initializing Cordova plugin \(Constants.APP_NAME)");
        let firstLoad = PersistentContainer.shared.firstLoad
        if firstLoad == nil || firstLoad == false {
            PersistentContainer.shared.loadInitialData()
            PersistentContainer.shared.firstLoad = true
        }
        super.pluginInitialize()
        sensorCounter = -1
        callbackHelper = CallbackHelper(self.commandDelegate!)
        
        //copyFilesFromTempToDocumentsFolderWith(fileExtension: ".txt.gz")
    }
    
    
    // MARK: isSensorKitAvailable
    @objc(isSensorKitAvailable:) func isSensorKitAvailable(command: CDVInvokedUrlCommand) {
        callbackHelper?.sendBool(command, true)
        return
    }

    // MARK: getAvailableSensors
    @objc(getAvailableSensors:) func getAvailableSensors(command: CDVInvokedUrlCommand) {
        let _sensors = _getAvailableSensors()
        var resultObject: [String] = []
        _sensors?.forEach { sensor in
            if let sensorString = _getSensorString(sensor: sensor) {
                resultObject.append(sensorString)
            }
        }
        //TODO repetetive pattern
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: ["sensors": resultObject], options: JSONSerialization.WritingOptions.prettyPrinted)
            let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
            self.callbackHelper?.sendJson(command, json)
        } catch let error {
            self.callbackHelper?.sendError(command, error.localizedDescription)
        }
    }
    
    // MARK: set config
    @objc(setConfig:) func setConfig(command: CDVInvokedUrlCommand) {
        guard let configs: [String: Any] = command.arguments[0] as? [String: Any] else {
            self.callbackHelper?.sendError(command, "INVALID_CONFIG")
            return
        }
       
        guard let token = configs["token"] as? String,
              let baseUrl = configs["baseUrl"] as? String,
              let projectId = configs["projectId"] as? String,
              let userId = configs["userId"] as? String else {
            callbackHelper?.sendError(command, "INVALID_CONFIG 'token', 'baseUrl', 'projectId' and 'userId' required.")
            return
        }
        
        let sourceId = configs["sourceId"] as? String ?? ""
        let kafkaEndpoint = configs["kafkaEndpoint"] as? String ?? Constants.DefaultKafkaEndpoint
        let schemaEndpoint = configs["schemaEndpoint"] as? String ?? Constants.DefaultSchemaEndpoint

        RadarbaseConfig.baseUrl = baseUrl
        RadarbaseConfig.kafkaEndpoint = kafkaEndpoint
        RadarbaseConfig.schemaEndpoint = schemaEndpoint
        
        UserConfig.token = token
        UserConfig.userId = userId
        UserConfig.projectId = ["string": projectId]
        UserConfig.sourceId = sourceId

        Task {
            RadarbaseConfig.logTopicKeyId = try await getTopicId(property: TopicKeyValue.KEY, topicName: "connect_data_log") ?? nil
            RadarbaseConfig.logTopicValueId = try await getTopicId(property: TopicKeyValue.VALUE, topicName: "connect_data_log") ?? nil
        }
        
        callbackHelper?.sendEmpty(command)
        return
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

    // MARK: Select the Sensor
    @objc(selectSensors:) func selectSensors(command: CDVInvokedUrlCommand) {
        guard let sensorsConfig: [[String: Any]] = command.arguments as? [[String: Any]] else {
            self.callbackHelper?.sendError(command, "NO_SENSOR")
            return
        }
        var sensors: Set<SRSensor> = Set()
        sensorsConfig.forEach { sensorConfig in
            guard let sensorString: String = sensorConfig["sensor"] as? String else {
                self.callbackHelper?.sendError(command, "NO_SENSOR")
                return
            }
            guard let sensor: SRSensor = _getSRSensor(sensorString: sensorString) else {
                self.callbackHelper?.sendError(command, "INVALID_SENSOR")
                return
            }
            sensors.insert(sensor)
            if let sensorPeriod = sensorConfig["period"] as? Double {
                ConfigSensor.periods[sensorString] = sensorPeriod
            }
            
            if let sensorTopic = sensorConfig["topic"] as? String {
                ConfigSensor.topics[sensorString] = sensorTopic
            }
            
            if let sensorChunkSize = sensorConfig["chunkSize"] as? Int {
                ConfigSensor.chunkSize[sensorString] = sensorChunkSize
            }
            
        }

        if sensors.isEmpty {
            self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
            return
        }

        self.sensors = Array(sensors)
        self.callbackHelper?.sendEmpty(command)
    }
    
    @objc(getCacheStatus:) func getCacheStatus(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            do {
                let total = try self._getCacheStatus()
                self.callbackHelper?.sendNumber(command, total)
            } catch let error {
                self.callbackHelper?.sendError(command, "Could not read temp folder: \(error.localizedDescription)")
            }
        }
    }
    
    @objc(clearCache:) func clearCache(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            self._deleteAllFiles(command: command)
            self.callbackHelper?.sendEmpty(command)
        }
    }
    
    @objc(uploadCache:) func uploadCache(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            self.uploadCacheCommand = command
            self._uploadAllFiles()
        }
    }
    
    @objc(startFetchingAll:) func startFetchingAll(command: CDVInvokedUrlCommand) {
        if lockStartFetchingAll == false {
            lockStartFetchingAll = true
            self.startFetchingAllCommand = command
            sensorCounter = -1
            _changeSensor()
        } else {
            self.callbackHelper?.sendError(startFetchingAllCommand!, "IN_PROGRESS", true)
        }
    }
    
    // MARK: stopRecording
    @objc(stopRecording:) func stopRecording(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            self.stopRecordingCounter = 0
            guard let sensorsString: [String] = command.arguments as? [String] else {
                self.callbackHelper?.sendError(command, "NO_SENSOR")
                return
            }
            let sensors: Set<SRSensor> = Set(sensorsString.map { self._getSRSensor(sensorString: $0) ?? nil}.compactMap { $0 })
            if sensors.isEmpty {
                self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
                return
            }
            
            self.stopRecordingsCommand = command
            self.stopRecordingsResponse = []
            self.stopRecordingsSensors = Array(sensors)
            self._doNextStop()
        }
    }
    
    // MARK: checkAuthorization
    @objc(checkAuthorization:) func checkAuthorization(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            guard let sensorsString: [String] = command.arguments as? [String] else {
                self.callbackHelper?.sendError(command, "NO_SENSOR")
                return
            }
            let sensors: Set<SRSensor> = Set(sensorsString.map { self._getSRSensor(sensorString: $0) ?? nil}.compactMap { $0 })
            if sensors.isEmpty {
                self.callbackHelper?.sendError(command, "NO_VALID_SENSOR")
                return
            }
            
            self.checkAuthorizationCommand = command
            self.checkAuthorizationResponse = []
            self.checkAuthorizationSensors = Array(sensors)
            self.checkAuthorizationSensors.forEach { sensor in
                let dataExtractor = self._generateDataExtractor(sensor: sensor)
                let response = self._checkAuthorization(dataExtractor: dataExtractor!)
                if let sensorString = self._getSensorString(sensor: sensor) {
                    self.checkAuthorizationResponse.append([sensorString: response])
                }
            }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["results": self.checkAuthorizationResponse], options: JSONSerialization.WritingOptions.prettyPrinted)
                let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
                self.callbackHelper?.sendJson(self.checkAuthorizationCommand!, json)
            } catch let error {
                self.callbackHelper?.sendError(self.checkAuthorizationCommand!, error.localizedDescription)
            }
        }
    }
    
//    var deviceQueue = OperationQueue()
    
    var magneticFieldTopicName: String?
    var magneticFieldPeriodMili: Double = 0
    var magneticFieldChunkSize = 10000
    
    var magneticFieldTopicKeyId: Int?
    var magneticFieldTopicValueId: Int?
    
    var fetchMagneticFieldCommand: CDVInvokedUrlCommand?
    
    // MARK: Select Magnetic Field Sensor
    @objc(selectMagneticFieldSensor:) func selectMagneticFieldSensor(command: CDVInvokedUrlCommand) {
        self.commandDelegate.run {
            self.magneticFieldTopicName = command.arguments[0] as? String ?? ConfigSensor.topics["magneticField"]
            self.magneticFieldPeriodMili = command.arguments[1] as? Double ?? ConfigSensor.periods["magneticField"]!
            self.magneticFieldChunkSize = command.arguments[2] as? Int ?? Constants.DEFAULT_CHUNK_SIZE
            
            self.magneticFieldTopicKeyId = nil
            self.magneticFieldTopicValueId = nil
            Task {
                do {
                    self.magneticFieldTopicKeyId = try await self.getTopicId(property: TopicKeyValue.KEY, topicName: self.magneticFieldTopicName!) ?? 0
                    self.magneticFieldTopicValueId = try await self.getTopicId(property: TopicKeyValue.VALUE, topicName: self.magneticFieldTopicName!) ?? 0
                    if self.magneticFieldTopicKeyId == nil || self.magneticFieldTopicValueId == nil {
                        self.callbackHelper?.sendError(command, "INVALID_TOPIC")
                        return
                    }
                    self.callbackHelper?.sendEmpty(command)
                } catch {
                    self.callbackHelper?.sendError(command, "FAIELD_GET_TOPIC")
                    return
                }
            }
            
        }
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
        do {
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
                        log("Processing Data started at: \(Date().timeIntervalSince1970)")
                        log("Total number of records: \(mfSensorDataArray.count)")
                        let body = self.getBody(payload: mfSensorDataArray, keySchemaId: self.magneticFieldTopicKeyId!, valueSchemaId: self.magneticFieldTopicValueId!)
                        
                        mfSensorDataArray = []
                        guard let data = try? JSONSerialization.data(withJSONObject: body) else {
                            return
                        }
                        let compressedData = self.getCompressedData(data: data)
                        guard let request = self.getRequest(compressedData: compressedData, topicName: self.magneticFieldTopicName!) else {return}
                        
                        Task {
                            await self.sendMagneticFieldData(request: request)
                        }
                    }
                }
            }
        } catch let error {
            log("Error in get magnetic field: \(error)")
        }
    }
}
