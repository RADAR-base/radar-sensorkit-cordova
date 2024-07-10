//
//  PhoneUsageReportDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import SwiftAvroCore

@available(iOS 14.0, *)
class PhoneUsageReportDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .phoneUsageReport } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedPhoneUsage! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRPhoneUsageReport
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: ConfigSensor.schemaStr["phoneUsageReport"]!)
            let phoneUsage = PhoneUsageReportModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                duration: sample.duration,
                totalIncomingCalls: sample.totalIncomingCalls,
                totalOutgoingCalls: sample.totalOutgoingCalls,
                totalPhoneCallDuration: sample.totalPhoneCallDuration,
                totalUniqueContacts: sample.totalUniqueContacts
            )
            let binaryValue = try avro.encode(phoneUsage)
            sensorDataArray.append([time: [UInt8](binaryValue)])
        } catch {
            print("Failed to encode Phone Usage Report data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedPhoneUsage
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedPhoneUsage = date
    }
}


struct PhoneUsageReportModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let duration: Double
    let totalIncomingCalls: Int
    let totalOutgoingCalls: Int
    let totalPhoneCallDuration: Double
    let totalUniqueContacts: Int
}
