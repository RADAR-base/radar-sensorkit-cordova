//
//  KeyboardMetricsDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

extension RbSensorkitCordovaPlugin {
    func convertKeyboardMetricsSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRKeyboardMetrics
        var totalPauses = -1, totalTypingEpisodes = -1
        if #available(iOS 15.0, *) {
            totalPauses = sample.totalPauses
            totalTypingEpisodes = sample.totalTypingEpisodes
        }
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "totalWords": sample.totalWords,
            "totalAlteredWords": sample.totalAlteredWords,
            "totalTaps": sample.totalTaps,
            "totalEmojis": sample.totalEmojis,
            "totalTypingDuration": sample.totalTypingDuration,
            "totalPauses": totalPauses,
            "totalTypingEpisodes": totalTypingEpisodes
        ])
    }
}
