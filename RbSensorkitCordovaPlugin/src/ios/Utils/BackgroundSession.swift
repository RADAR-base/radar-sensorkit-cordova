import os.log
import Foundation

// Note, below I will use `os_log` to log messages because when testing background URLSession
// you do not want to be attached to a debugger (because doing so changes the lifecycle of an
// app). So, I will use `os_log` rather than `print` debugging statements because I can then
// see these logging statements in my macOS `Console` without using Xcode at all. I'll log these
// messages using this `OSLog` so that I can easily filter the macOS `Console` for just these
// logging statements.

private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: #file)

@available(iOS 14.0, *)
class BackgroundSession: NSObject {
    var delegate: SensorKitDelegate?
    
    var savedCompletionHandler: (() -> Void)?
    
    static var shared = BackgroundSession()
    
    private var session: URLSession!
    
    var fileNamesDictionary =  [Int: String]()
    
    private override init() {
        super.init()

        let identifier = Bundle.main.bundleIdentifier! + ".backgroundSession"
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)

        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)

    }
}

@available(iOS 14.0, *)
extension BackgroundSession {
//    @discardableResult
//    func startUpload(for request: URLRequest, from data: Data) throws -> URLSessionUploadTask {
//        os_log("%{public}@: start", log: log, type: .debug, #function)
//
//        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
//            .appendingPathComponent(UUID().uuidString)
//        try data.write(to: fileURL)
//        let task = session.uploadTask(with: request, fromFile: fileURL)
//        task.resume()
//
//        return task
//    }
    
//    @discardableResult
    func startUploadFile(for request: URLRequest, fromFile fileName: String, identifier identifierSuffix: String) throws -> URLSessionUploadTask {
//        os_log("%{public}@: start", log: log, type: .debug, #function)
        let identifier = Bundle.main.bundleIdentifier! + identifierSuffix //".backgroundSession"
        let configuration = URLSessionConfiguration.background(withIdentifier: identifier)
        session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        let tempDir = getDocumentsDirectory()
        let fileURL = tempDir.appendingPathComponent(fileName)
//        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
//            .appendingPathComponent(UUID().uuidString)
//        try data.write(to: fileURL)
            let task = session.uploadTask(with: request, fromFile: fileURL)
//        print("TaskIdentifier: \(task.taskIdentifier)")
        fileNamesDictionary[task.taskIdentifier] = fileName
        task.resume()
        return task
    }
}

@available(iOS 14.0, *)
extension BackgroundSession: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        os_log(#function, log: log, type: .debug)

        DispatchQueue.main.async {
            self.savedCompletionHandler?()
            self.savedCompletionHandler = nil
        }
    }
}

@available(iOS 14.0, *)
extension BackgroundSession: URLSessionTaskDelegate {
//    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
//        if let error = error {
//            os_log("%{public}@: %{public}@", log: log, type: .error, #function, error.localizedDescription)
//            return
//        }
//        os_log("%{public}@: SUCCESS", log: log, type: .debug, #function)
//    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let err = error {
            print("Error: \(err.localizedDescription)")
        }
    }
}

@available(iOS 14.0, *)
extension BackgroundSession: URLSessionDataDelegate {
    
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didBecome downloadTask: URLSessionDownloadTask) {
        os_log(#function, log: log, type: .debug)
    }
    
//    func urlSession(_ session: URLSession, task: URLSessionTask, didReceiveInformationalResponse: HTTPURLResponse){
//        print("&&&")
//    }
    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
//        os_log("%{public}@: received %d", log: log, type: .debug, #function, data.count)
//    }
//    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping @Sendable (URLSession.ResponseDisposition) -> Void) {
//            print("response")
//
//    }

//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) async -> URLSession.ResponseDisposition {
//        print("response")
//
//    }

//     Response received
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
//        print("response")
//        print("did receive response")
                    //self.response = response
//                    print(response)
                    completionHandler(URLSession.ResponseDisposition.allow)
                }  // end func
//        completionHandler(URLSession.ResponseDisposition.allow)
//        
//        if let httpResponse = response as? HTTPURLResponse {
//            //xFile?.httpResponse = httpResponse.statusCode
//            print("httpResponse \(httpResponse) \(httpResponse.statusCode)")
//            if httpResponse.statusCode == 200 {
//                print("httpResponse 200")
//            }
//        }
//    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if String(data: data, encoding: .utf8) != nil {
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if((json["error"]) != nil){
                        print("0000ERRR \(json["error_description"])")
                        let error = UploadError(message: json["error"] as! String) //"Upload failed \(responseText)") // NSError(domain:"", code:responseText, userInfo:nil)
                        delegate?.__didUploadFileFailed(error: error, fileName: fileNamesDictionary[dataTask.taskIdentifier])
                    } else {
                        let fileManager = FileManager.default
                        let tempPath = getDocumentsDirectory().path
                        let fileName = fileNamesDictionary[dataTask.taskIdentifier]
                        if (fileName != nil) {
                            let filePathName = "\(tempPath)/\(fileName!)"
                            try fileManager.removeItem(atPath: filePathName)
                        }
                        delegate?.__didUploadFileSuccess(fileName: fileName)
                    }
                }
            } catch let error {
                let _error = UploadError(message: "Upload failed \(error.localizedDescription)")
                delegate?.__didUploadFileFailed(error: _error, fileName: fileNamesDictionary[dataTask.taskIdentifier])
            }
        }
   }
    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse) {
//            print("didReceive response")
////            completionHandler(URLSession.ResponseDisposition.allow)
//     }
    
    
    
//    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: (URLSession.ResponseDisposition) -> Void) {
//            print("didReceive response")
//            completionHandler(URLSession.ResponseDisposition.allow)
//     }
}
