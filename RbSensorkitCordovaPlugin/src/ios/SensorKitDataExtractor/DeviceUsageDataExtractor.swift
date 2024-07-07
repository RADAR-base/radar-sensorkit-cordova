//
//  DeviceUsageDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import SwiftAvroCore

@available(iOS 14.0, *)
class DeviceUsageDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .deviceUsageReport } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedDeviceUsage! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRDeviceUsageReport
        var version = ""
        if #available(iOS 16.4, *) {
            version = sample.version
        }
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
            let deviceUsage = DeviceUsageModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                duration: sample.duration,
                totalScreenWakes: sample.totalScreenWakes,
                totalUnlocks: sample.totalUnlocks,
                totalUnlockDuration: sample.totalUnlockDuration,
                version: version,
                applicationUsageByCategory: "\(sample.applicationUsageByCategory)",
                notificationUsageByCategory: "\(sample.notificationUsageByCategory)",
                webUsageByCategory: "\(sample.webUsageByCategory)"
            )
            let binaryValue = try avro.encode(deviceUsage)
            sensorDataArray.append([time: [UInt8](binaryValue)])
        } catch {
            print("Failed to encode Device Usage data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedDeviceUsage
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedDeviceUsage = date
    }
}

struct DeviceUsageModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let duration: Double
    let totalScreenWakes: Int
    let totalUnlocks: Int
    let totalUnlockDuration: Double
    let version: String
    let applicationUsageByCategory: String
    let notificationUsageByCategory: String
    let webUsageByCategory: String
}
