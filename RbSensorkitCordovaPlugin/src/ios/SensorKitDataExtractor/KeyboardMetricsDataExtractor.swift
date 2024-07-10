//
//  KeyboardMetricsDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import SwiftAvroCore

@available(iOS 14.0, *)
class KeyboardMetricsDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .keyboardMetrics } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedDeviceUsage! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRKeyboardMetrics
        var totalPauses = -1, totalTypingEpisodes = -1
        if #available(iOS 15.0, *) {
            totalPauses = sample.totalPauses
            totalTypingEpisodes = sample.totalTypingEpisodes
        }
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: ConfigSensor.schemaStr["keyboardMetrics"]!)
            let keyboardUsageMetrics = KeyboardUsageMetricsModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                totalWords: sample.totalWords,
                totalAlteredWords: sample.totalWords,
                totalTaps: sample.totalTaps,
                totalEmojis: sample.totalEmojis,
                totalTypingDuration: sample.totalTypingDuration,
                totalPauses: totalPauses,
                totalTypingEpisodes: totalTypingEpisodes
            )
            let binaryValue = try avro.encode(keyboardUsageMetrics)
            sensorDataArray.append([time: [UInt8](binaryValue)])
        } catch {
            print("Failed to encode Keyboard Metrics data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedKeyboardMetrics
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedKeyboardMetrics = date
    }
}

struct KeyboardUsageMetricsModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let totalWords: Int
    let totalAlteredWords: Int
    let totalTaps: Int
    let totalEmojis: Int
    let totalTypingDuration: Double
    let totalPauses: Int
    let totalTypingEpisodes: Int
}
