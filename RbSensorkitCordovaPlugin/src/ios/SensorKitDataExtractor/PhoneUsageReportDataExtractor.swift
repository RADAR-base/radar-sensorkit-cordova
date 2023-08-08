//
//  PhoneUsageReportDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

extension RbSensorkitCordovaPlugin {
    func convertPhoneUsageSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRPhoneUsageReport
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "duration": sample.duration,
            "totalIncomingCalls": sample.totalIncomingCalls,
            "totalOutgoingCalls": sample.totalOutgoingCalls,
            "totalPhoneCallDuration": sample.totalPhoneCallDuration,
            "totalUniqueContacts": sample.totalUniqueContacts,
        ])
    }
}
