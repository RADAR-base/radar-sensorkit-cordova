//
//  MessageUsageReportDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

@available(iOS 14.0, *)
class MessageUsageReportDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .messagesUsageReport } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedMessageUsage! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRMessagesUsageReport
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "device": selectedDevice?.model ?? "UNKNOWN",
            "duration": sample.duration,
            "totalIncomingMessages": sample.totalIncomingMessages,
            "totalOutgoingMessages": sample.totalOutgoingMessages,
            "totalUniqueContacts": sample.totalUniqueContacts,
        ])
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedMessageUsage
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedMessageUsage = date
    }
}
