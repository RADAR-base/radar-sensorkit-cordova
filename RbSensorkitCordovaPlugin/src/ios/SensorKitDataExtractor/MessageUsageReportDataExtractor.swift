//
//  MessageUsageReportDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

class MessageUsageReportDataExtractor: SensorKitDataExtractor {
//    override var defaultTopic: String { get { return DefaultTopics.MessageUsage } }
//    override var defaultPriod: Double { get { return DefaultPeriods.MessageUsage } }
    override var sensor: SRSensor? { get { return .messagesUsageReport } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedMessageUsage! } }

    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRMessagesUsageReport
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "duration": sample.duration,
            "totalIncomingMessages": sample.totalIncomingMessages,
            "totalOutgoingMessages": sample.totalOutgoingMessages,
            "totalUniqueContacts": sample.totalUniqueContacts,
        ])
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedMessageUsage = date
//    }
}

//extension SensorKitDataExtractor {
//    func convertMessageUsageSensorData(result: SRFetchResult<AnyObject>){
//        let sample = result.sample as! SRMessagesUsageReport
//        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
//        sensorDataArray.append([
//            "time": time,
//            "timeReceived": time,
//            "duration": sample.duration,
//            "totalIncomingMessages": sample.totalIncomingMessages,
//            "totalOutgoingMessages": sample.totalOutgoingMessages,
//            "totalUniqueContacts": sample.totalUniqueContacts,
//        ])
//    }
//}
//
