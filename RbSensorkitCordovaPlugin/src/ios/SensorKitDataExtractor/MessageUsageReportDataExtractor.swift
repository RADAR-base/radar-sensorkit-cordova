//
//  MessageUsageReportDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

extension RbSensorkitCordovaPlugin {
    func convertMessageUsageSensorData(result: SRFetchResult<AnyObject>){
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
}
