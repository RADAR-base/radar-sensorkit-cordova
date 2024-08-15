//
//  TelephonySpeechMetricsDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import SwiftAvroCore

@available(iOS 15.0, *)
class TelephonySpeechMetricsDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .telephonySpeechMetrics } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedTelephonySpeechMetrics! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        if #available(iOS 17.0, *) {
            let sample = result.sample as! SRSpeechMetrics

            let classifications: [SNClassification]? = sample.soundClassification?.classifications
            
            let classificationsString = classifications?.compactMap { word in
                word.identifier + ": " + word.confidence.description
            }.joined(separator: ", ")

            let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
            let avro = Avro()
            do {
                _ = avro.decodeSchema(schema: ConfigSensor.schemaStr["telephonySpeechMetrics"]!)
                let telephoneSpeechMetrics = TelephonySpeechMetricsModel(
                    time: time,
                    timeReceived: time,
                    device: selectedDevice?.model ?? "UNKNOWN",
                    audioLevelStart: sample.audioLevel?.timeRange.start.seconds as Any as? Double,
                    audioLevelDuration: sample.audioLevel?.timeRange.duration.seconds as Any as? Double,
                    audioLevelLoudness: sample.audioLevel?.loudness as Any as? Double,
                    
                    soundClassificationStart: sample.soundClassification?.timeRange.start.seconds as Any as? Double,
                    soundClassificationDuration: sample.soundClassification?.timeRange.duration.seconds as Any as? Double,
                    soundClassification: (classificationsString ?? nil) as Any as? String,
                    
                    speechExpressionStart: sample.speechExpression?.timeRange.start.seconds as Any as? Double,
                    speechExpressionDuration: sample.speechExpression?.timeRange.duration.seconds as Any as? Double,
                    speechExpressionActivation: sample.speechExpression?.activation as Any as? Double,
                    speechExpressionConfidence: sample.speechExpression?.confidence as Any as? Double,
                    speechExpressionDominance: sample.speechExpression?.dominance as Any as? Double,
                    speechExpressionMood: sample.speechExpression?.mood as Any as? Double,
                    speechExpressionValence: sample.speechExpression?.valence as Any as? Double
                )
                let binaryValue = try avro.encode(telephoneSpeechMetrics)
                sensorDataArray.append([time: [UInt8](binaryValue)])
            } catch {
                print("Failed to encode Telephony Speech Metrics data: \(error)")
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedTelephonySpeechMetrics
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedTelephonySpeechMetrics = date
    }
}


struct TelephonySpeechMetricsModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let audioLevelStart: Double?
    let audioLevelDuration: Double?
    let audioLevelLoudness: Double?
    let soundClassificationStart: Double?
    let soundClassificationDuration: Double?
    let soundClassification: String?
    let speechExpressionStart: Double?
    let speechExpressionDuration: Double?
    let speechExpressionActivation: Double?
    let speechExpressionConfidence: Double?
    let speechExpressionDominance: Double?
    let speechExpressionMood: Double?
    let speechExpressionValence: Double?
}
