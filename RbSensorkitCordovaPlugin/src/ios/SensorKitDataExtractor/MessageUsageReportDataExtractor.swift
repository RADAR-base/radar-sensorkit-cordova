//
//  MessageUsageReportDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import SwiftAvroCore

@available(iOS 14.0, *)
class MessageUsageReportDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .messagesUsageReport } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedMessageUsage! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRMessagesUsageReport
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
            let messageUsage = MessageUsageModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                totalIncomingMessages: sample.totalIncomingMessages,
                totalOutgoingMessages: sample.totalOutgoingMessages,
                totalUniqueContacts: sample.totalUniqueContacts
            )
            let binaryValue = try avro.encode(messageUsage)
            sensorDataArray.append([UInt8](binaryValue))
        } catch {
            print("Failed to encode Message Usage Report data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedMessageUsage
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedMessageUsage = date
    }
}

struct MessageUsageModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let totalIncomingMessages: Int
    let totalOutgoingMessages: Int
    let totalUniqueContacts: Int
}
