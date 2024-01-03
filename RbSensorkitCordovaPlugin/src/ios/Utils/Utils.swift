
//func convertToJson(object: Encodable) -> String? {
//    let jsonEncoder = JSONEncoder()
//    let jsonData = try! jsonEncoder.encode(object)
//    let json = String(data: jsonData, encoding: String.Encoding.utf8)
//    return json
//}

func convertToJson(data: [String: Any]) -> [String: AnyObject]? {
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: data, options: JSONSerialization.WritingOptions.prettyPrinted)

        // if let JSONString = String(data: jsonData, encoding: String.Encoding.utf8) {
        // print(JSONString)
        // }

        let json = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: AnyObject]
        return json
    } catch {
        print("Error converting to JSON")
        return nil
    }
    
}

func log(_ message: String) {
    NSLog("[" + Constants.APP_SHORT_NAME + "] %@", message)
}

func writeToFile(data: Data, fileName: String){
    let filename = getDocumentsDirectory().appendingPathComponent(fileName + ".txt.gz")
    do {
        try data.write(to: filename)
        print("Write successful \(filename)")
        //self.doNextPost()
    } catch {
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
        print("Write failed")
    }
}

func showFirstNResult(n: Int, array: [[String : Any]]) {
    for i in 0...n {
        log("--- \(array[i])")
    }
}

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = paths[0]

    // Check if the directory exists
    if !FileManager.default.fileExists(atPath: documentsDirectory.path) {
        do {
            // If not, create the directory
            try FileManager.default.createDirectory(at: documentsDirectory, withIntermediateDirectories: true, attributes: nil)
        } catch {
            // Handle the error appropriately
            print("Error creating Documents directory: \(error)")
        }
    }

    return documentsDirectory
}

