//
//  PhoneUsageReportDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

@available(iOS 14.0, *)
class PhoneUsageReportDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .phoneUsageReport } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedPhoneUsage! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRPhoneUsageReport
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "device": selectedDevice?.model ?? "UNKNOWN",
            "duration": sample.duration,
            "totalIncomingCalls": sample.totalIncomingCalls,
            "totalOutgoingCalls": sample.totalOutgoingCalls,
            "totalPhoneCallDuration": sample.totalPhoneCallDuration,
            "totalUniqueContacts": sample.totalUniqueContacts,
        ])
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedPedometer = date
//    }
}
