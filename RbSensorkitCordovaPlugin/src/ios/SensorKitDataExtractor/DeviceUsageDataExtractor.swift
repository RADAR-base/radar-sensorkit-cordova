//
//  DeviceUsageDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

class DeviceUsageDataExtractor: SensorKitDataExtractor {
//    override var defaultTopic: String { get { return DefaultTopics.DeviceUsage } }
//    override var defaultPriod: Double { get { return DefaultPeriods.DeviceUsage } }
    override var sensor: SRSensor? { get { return .deviceUsageReport } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedDeviceUsage! } }

    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRDeviceUsageReport
        var version = ""
        if #available(iOS 16.4, *) {
            version = sample.version
        }
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "duration": sample.duration,
            "totalScreenWakes": sample.totalScreenWakes,
            "totalUnlocks": sample.totalUnlocks,
            "totalUnlockDuration": sample.totalUnlockDuration,
            "applicationUsageByCategory": "\(sample.applicationUsageByCategory)",
            "notificationUsageByCategory": "\(sample.notificationUsageByCategory)",
            "webUsageByCategory": "\(sample.webUsageByCategory)",
            "version": version,
        ])
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedDeviceUsage = date
//    }
}

//extension SensorKitDataExtractor {
//    func convertDeviceUsageSensorData(result: SRFetchResult<AnyObject>){
//        let sample = result.sample as! SRDeviceUsageReport
//        var version = ""
//        if #available(iOS 16.4, *) {
//            version = sample.version
//        }
//        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
//        sensorDataArray.append([
//            "time": time,
//            "timeReceived": time,
//            "duration": sample.duration,
//            "totalScreenWakes": sample.totalScreenWakes,
//            "totalUnlocks": sample.totalUnlocks,
//            "totalUnlockDuration": sample.totalUnlockDuration,
//            "applicationUsageByCategory": "\(sample.applicationUsageByCategory)",
//            "notificationUsageByCategory": "\(sample.notificationUsageByCategory)",
//            "webUsageByCategory": "\(sample.webUsageByCategory)",
//            "version": version,
//        ])
//    }
//}
//
