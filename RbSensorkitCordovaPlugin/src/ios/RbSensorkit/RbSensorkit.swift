import SensorKit

@available(iOS 14.0, *)
extension RbSensorkitCordovaPlugin {
    
    func _generateDataExtractor(sensor: SRSensor) -> SensorKitDataExtractor? {
        switch sensor {
        case .accelerometer:
            return AccelerometerDataExtractor(periodMili: ConfigSensor.periods["accelerometer"]!, topicName: ConfigSensor.topics["accelerometer"]!, chunkSize: ConfigSensor.chunkSize["accelerometer"]!)
        case .ambientLightSensor:
            return AmbientLightDataExtractor(periodMili: ConfigSensor.periods["ambientLightSensor"]!, topicName: ConfigSensor.topics["ambientLightSensor"]!, chunkSize: ConfigSensor.chunkSize["ambientLightSensor"]!)
        case .deviceUsageReport:
            return DeviceUsageDataExtractor(periodMili: ConfigSensor.periods["deviceUsageReport"]!, topicName: ConfigSensor.topics["deviceUsageReport"]!, chunkSize: ConfigSensor.chunkSize["deviceUsageReport"]!)
        case .keyboardMetrics:
            return KeyboardMetricsDataExtractor(periodMili: ConfigSensor.periods["keyboardMetrics"]!, topicName: ConfigSensor.topics["keyboardMetrics"]!, chunkSize: ConfigSensor.chunkSize["keyboardMetrics"]!)
        case .messagesUsageReport:
            return MessageUsageReportDataExtractor(periodMili: ConfigSensor.periods["messagesUsageReport"]!, topicName: ConfigSensor.topics["messagesUsageReport"]!, chunkSize: ConfigSensor.chunkSize["messagesUsageReport"]!)
        case .onWristState:
            return OnWristStateDataExtractor(periodMili: ConfigSensor.periods["onWristState"]!, topicName: ConfigSensor.topics["onWristState"]!, chunkSize: ConfigSensor.chunkSize["onWristState"]!)
        case .pedometerData:
            return PedometerDataExtractor(periodMili: ConfigSensor.periods["pedometerData"]!, topicName: ConfigSensor.topics["pedometerData"]!, chunkSize: ConfigSensor.chunkSize["pedometerData"]!)
        case .phoneUsageReport:
            return PhoneUsageReportDataExtractor(periodMili: ConfigSensor.periods["phoneUsageReport"]!, topicName: ConfigSensor.topics["phoneUsageReport"]!, chunkSize: ConfigSensor.chunkSize["phoneUsageReport"]!)
        case .rotationRate:
            return RotationDataExtractor(periodMili: ConfigSensor.periods["rotationRate"]!, topicName: ConfigSensor.topics["rotationRate"]!, chunkSize: ConfigSensor.chunkSize["rotationRate"]!)
        case .visits:
            return VisitsDataExtractor(periodMili: ConfigSensor.periods["visits"]!, topicName: ConfigSensor.topics["visits"]!, chunkSize: ConfigSensor.chunkSize["visits"]!)
        default:
            break
        }
        
        if #available(iOS 15.4, *) {
            switch sensor {
            case .ambientPressure:
                return AmbientPressureDataExtractor(periodMili: ConfigSensor.periods["ambientPressure"]!, topicName: ConfigSensor.topics["ambientPressure"]!, chunkSize: ConfigSensor.chunkSize["ambientPressure"]!)
            default:
                break
            }
        }
        
        if #available(iOS 15.0, *) {
            switch sensor {
            case .telephonySpeechMetrics:
                return TelephonySpeechMetricsDataExtractor(periodMili: ConfigSensor.periods["telephonySpeechMetrics"]!, topicName: ConfigSensor.topics["telephonySpeechMetrics"]!, chunkSize: ConfigSensor.chunkSize["telephonySpeechMetrics"]!)
            default:
                break
            }
        }
        return nil
    }

    func _isAuthorized(_ dataExtractor: SensorKitDataExtractor?) -> Bool {
//        print(" \(dataExtractor?.reader?.authorizationStatus)")
        if dataExtractor?.reader?.authorizationStatus.rawValue == 1 {
            return true
        }
        return false
    }

    func _changeSensor() {
        sensorCounter = sensorCounter + 1
        let sensor = sensors[sensorCounter]
        selectedSensor = _generateDataExtractor(sensor: sensor)
        selectedSensor?.delegate = self
        if selectedSensor?.reader?.authorizationStatus == .authorized {
            selectedSensor?.startRecording()
            selectedSensor?.startFetching()
        } else {
            if sensorCounter < sensors.count - 1 {
                _changeSensor()
            }
        }
    }
    
//    func _updateLastFetch(date: Date) {
//        PersistentContainer.shared.lastFetched = date
//    }
    
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
        var sensors: [SRSensor] = [.accelerometer, .ambientLightSensor, .deviceUsageReport, .keyboardMetrics,  .messagesUsageReport, .onWristState, .pedometerData, .phoneUsageReport, .visits]
        if #available(iOS 15.0, *) {
            sensors.append(.telephonySpeechMetrics)
        }
        if #available(iOS 15.4, *) {
            sensors.append(.ambientPressure)
        }
        return sensors
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
             case "rotationRate":
                sensor = .rotationRate
                break
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
    func _getCacheStatus() throws -> Int {
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
            return counter
        } catch let error {
            throw error
        }
    }
    
    func _uploadAllFiles() {
        totalFilesToUpload = 0
        uploadedFileCounter = 0
        do {
            totalFilesToUpload = try _getCacheStatus()
        } catch {}
        do {
            let fileManager = FileManager.default
            let tempPath = fileManager.temporaryDirectory.path
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(tempPath)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".txt.gz")) {
                    //let filePathName = "\(tempPath)/\(fileName)"
//                    print("\(Date().timeIntervalSince1970) File: \(fileName)")
                    _uploadFile(fileName: fileName)
                }
            }
            

        } catch {
            callbackHelper?.sendError(uploadCacheCommand!, "Could not upload all files: \(error)")
//            print("Could not clear temp folder: \(error)")
        }
    }
    
    func _uploadFile(fileName: String) {
        do {
            // get topic name from the file
            let topicName = fileName.components(separatedBy: "___")[0]

            guard let baseUrl = RadarbaseConfig.baseUrl else {
                // send error message to JS and return
                return
            }

            guard let url = URL(string: baseUrl + RadarbaseConfig.kafkaEndpoint + topicName) else {
                // send error message to JS and return
                return
            }

            var request = URLRequest(url: url)
            request.addValue("gzip", forHTTPHeaderField: "Content-Encoding")
            request.httpMethod = "POST"

            request.setValue("application/vnd.kafka.avro.v2+json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
            guard let token = UserConfig.token else {
                return
            }

            request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")

            let identifierSuffix = "uniqueId"

            let backgroundSession = BackgroundSession.shared
            backgroundSession.delegate = self
            let fileManager = FileManager.default
            let path = fileManager.temporaryDirectory.path + "/" + fileName
            let fileExists = fileManager.fileExists(atPath: path)
            if fileExists {
//                print("fileExists : \(fileExists)")
                _ = try backgroundSession.startUploadFile(for: request, fromFile: fileName, identifier: identifierSuffix)
                // Save the completion handler for later use (if needed)
                backgroundSession.savedCompletionHandler = {
                    // Handle completion, if necessary
                }
            }
        } catch {
            // Handle the error thrown by startUploadFile
            print("\(error.localizedDescription)")
        }
    }
    
    func _deleteAllFiles(command: CDVInvokedUrlCommand) {
        do {
            let fileManager = FileManager.default
            let tempPath = fileManager.temporaryDirectory.path
            let fileNames = try fileManager.contentsOfDirectory(atPath: "\(tempPath)")
            for fileName in fileNames {
                if (fileName.hasSuffix(".txt.gz")) {
                    let filePathName = "\(tempPath)/\(fileName)"
                    try fileManager.removeItem(atPath: filePathName)
                }
            }
        } catch let error {
            callbackHelper?.sendError(command, "Could not clear temp folder: \(error.localizedDescription)")
        }
    }
    
    func copyFilesFromTempToDocumentsFolderWith(fileExtension: String) {
        if let resPath = Bundle.main.resourcePath {
            do {
                let fileManager = FileManager.default
                let tempPath = fileManager.temporaryDirectory.path
                let dirContents = try FileManager.default.contentsOfDirectory(atPath: tempPath)
                let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first
                let filteredFiles = dirContents.filter{ $0.contains(fileExtension)}
                
                for fileName in filteredFiles {
                    if let documentsURL = documentsURL {
                        let tempURL = fileManager.temporaryDirectory
                        let sourceURL = tempURL.appendingPathComponent(fileName)
                        let destURL = documentsURL.appendingPathComponent(fileName)
                        do {
                            try fileManager.copyItem(at: sourceURL, to: destURL)
                        }
                    }
                }
            } catch { }
        }
    }
    
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
    
    func getTopicId(property: TopicKeyValue, topicName: String) async throws -> Int? {
        guard let baseUrl = RadarbaseConfig.baseUrl else {
            return nil
        }
        guard let url = URL(string: baseUrl + RadarbaseConfig.schemaEndpoint + topicName + "-" + property.rawValue + "/versions/latest") else {
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
    
    func _postLogToKafka(dataGroupingType: String?) async {
//        print("_postLogToKafka")
        let data = [["time": Date().timeIntervalSince1970, "dataGroupingType": dataGroupingType ?? "PASSIVE_SENSOR_KIT"] as [String : Any]]
        guard let userId = UserConfig.userId, let logTopicKeyId = RadarbaseConfig.logTopicKeyId, let logTopicValueId = RadarbaseConfig.logTopicValueId  else {
            return
        }
        let key: [String : Any] = [
            "projectId": UserConfig.projectId, //["string": projectId],
            "userId": userId,
            "sourceId": UserConfig.sourceId ?? ""
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
        guard let baseUrl = RadarbaseConfig.baseUrl else { return }
        guard let url = URL(string: baseUrl + RadarbaseConfig.kafkaEndpoint + "connect_data_log") else { return }
       var request = URLRequest(url: url)
       request.httpMethod = "POST"
       request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       request.setValue("application/vnd.kafka.v2+json, application/vnd.kafka+json; q=0.9, application/json; q=0.8", forHTTPHeaderField: "Accept")
       request.setValue( "Bearer \(UserConfig.token!)", forHTTPHeaderField: "Authorization")
       request.httpBody = data
       do {
           let (_, _) = try await URLSession.shared.data(for: request)
       } catch let error {
           log("Error on sending connect log. \(error)")
       }
   }
    
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
    
    func getCompressedData(data: Data) -> Data {
        let compressedData = try! data.gzipped(level: .bestCompression)
//        print("\(Date().timeIntervalSince1970) Chunk#: \(iterationCounter) - Compressed Data Size \(compressedData.count / 1024) kb")
        return compressedData
    }
    
    func getRequest(compressedData: Data, topicName: String) -> URLRequest? {
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
    
    func sendMagneticFieldData(request: URLRequest) async {
            let startTime = Date().timeIntervalSince1970
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                        let time = Date().timeIntervalSince1970 - startTime
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
        
//        func handleSuccessError(response: HTTPURLResponse?, data: [String: Any]) async{
//            var recordCount = chunkSize
//            if iterationCounter == totalIterations {
//                recordCount = sensorDataArray.count - iterationCounter * chunkSize
//            }
//            if response?.statusCode == 200 {
//                let data = ["progress": iterationCounter + 1, "total": totalIterations + 1, "start": startTime, "end": endTime, "recordCount": recordCount] as [String : Any]
//                let json = convertToJson(data: data)
//                self.callbackHelper?.sendJson(self.fetchDataCommand!, json, true)
//                // send log
//                await self.postLogToKafka()
//            } else {
//                let data = ["statusCode": response?.statusCode ?? 0, "progress": iterationCounter + 1, "total": totalIterations + 1, "start": startTime, "end": endTime, "recordCount": recordCount, "error_description": data["error_description"] ?? "No error description", "error_message": data["error"] ?? "No error message"]
//                let json = convertToJson(data: data)
//                self.callbackHelper!.sendErrorJson(self.fetchDataCommand!, json, true)
//            }
//        }
//        
        func handleMagneticFieldSuccessError(response: HTTPURLResponse?, data: [String: Any]) async{
            if response?.statusCode == 200 {
                self.callbackHelper?.sendEmpty(self.fetchMagneticFieldCommand!, true)
                // send log
                await _postLogToKafka(dataGroupingType: "PASSIVE_IOS_PHONE”")
            } else {
                self.callbackHelper!.sendError(self.fetchMagneticFieldCommand!, data["error_description"] as? String ?? "UNKNOWN_ERROR", true)
            }
        }
    
    func _doNextStop() {
        if stopRecordingsSensors.count == stopRecordingsResponse.count {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: ["results": stopRecordingsResponse], options: JSONSerialization.WritingOptions.prettyPrinted)
                let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
                self.callbackHelper?.sendJson(stopRecordingsCommand!, json)
            } catch let error {
                self.callbackHelper?.sendError(stopRecordingsCommand!, error.localizedDescription)
            }
        } else {
            let sensor = stopRecordingsSensors[stopRecordingCounter]
            selectedStopRecordingSensor = _generateDataExtractor(sensor: sensor)
            selectedStopRecordingSensor?.delegate = self
            if !_isAuthorized(selectedStopRecordingSensor) {
                // write in response object that it is not authorized
                stopRecordingsResponse.append([sensor.rawValue: "NOT_AUTHORIZED"])
                stopRecordingCounter = stopRecordingCounter + 1
                _doNextStop()
            } else {
                selectedStopRecordingSensor?.stopRecording()
                stopRecordingCounter = stopRecordingCounter + 1
            }
        }
    }
}


@available(iOS 14.0, *)
extension RbSensorkitCordovaPlugin: SensorKitDelegate {
    func __didStopRecording(sensor: SRSensor) {
        stopRecordingsResponse.append([sensor.rawValue: "STOPPED"])
        _doNextStop()
    }
    
    func __failedStopRecording(sensor: SRSensor, error: Error) {
        stopRecordingsResponse.append([sensor.rawValue: error])
        _doNextStop()
    }
    
    func __fetchCompletedForOneSensor(sensor: SRSensor, date: Date) {
        let result = ["sensor": sensor.rawValue, "startDate": date.timeIntervalSince1970] as [String : AnyObject]
        self.callbackHelper?.sendJson(startFetchingAllCommand!, result, true)
        if sensorCounter < sensors.count - 1 {
            _changeSensor()
        } else {
            self.callbackHelper?.sendString(startFetchingAllCommand!, "Data fetched completed.", true)
            //_updateLastFetch(date: date)
            lockStartFetchingAll = false
            uploadCacheCommand = startFetchingAllCommand
            _uploadAllFiles()
        }
    }
    
    func __failedFetchTopic(topicName: String, error: Error) {
        self.callbackHelper?.sendError(startFetchingAllCommand!, "Topic '\(topicName)' doesn't exist.", true)
    }
    
    func __didUploadFileSuccess(fileName: String?) {
        uploadedFileCounter = uploadedFileCounter + 1
        Task {
            await _postLogToKafka(dataGroupingType: "PASSIVE_SENSOR_KIT")
        }
        let result: [String: AnyObject] = ["total": totalFilesToUpload, "UploadNumber": uploadedFileCounter, "topic": fileName ?? ""] as [String : AnyObject]
        self.callbackHelper?.sendJson(uploadCacheCommand!, result, true)
    }
    
    func __didUploadFileFailed(error: UploadError, fileName: String?) {
        uploadedFileCounter = uploadedFileCounter + 1
        let result: [String: AnyObject] = ["total": totalFilesToUpload, "UploadNumber": uploadedFileCounter, "error": error.message, "topic": fileName ?? ""] as [String : AnyObject]
        self.callbackHelper?.sendErrorJson(uploadCacheCommand!, result, true)
    }
}
