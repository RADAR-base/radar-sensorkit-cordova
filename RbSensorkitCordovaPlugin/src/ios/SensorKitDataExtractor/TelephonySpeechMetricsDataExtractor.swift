//
//  TelephonySpeechMetricsDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

@available(iOS 15.0, *)
class TelephonySpeechMetricsDataExtractor: SensorKitDataExtractor {
//    override var defaultTopic: String { get { return DefaultTopics.TelephonySpeechMetrics } }
//    override var defaultPriod: Double { get { return DefaultPeriods.TelephonySpeechMetrics } }
    override var sensor: SRSensor? { get { return .telephonySpeechMetrics } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedTelephonySpeechMetrics! } }

    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        if #available(iOS 17.0, *) {
            let sample = result.sample as! SRSpeechMetrics

            var classifications: [SNClassification]? = sample.soundClassification?.classifications
            
            var classificationsString = classifications?.compactMap { word in
                word.identifier + ": " + word.confidence.description
            }.joined(separator: ", ")

            sensorDataArray.append([
                "time": sample.timestamp.timeIntervalSince1970,
                "timeReceived": sample.timestamp.timeIntervalSince1970,
                "audioLevelLoudness": sample.audioLevel?.loudness as Any,
                "audioLevelStart": sample.audioLevel?.timeRange.start.seconds as Any,
                "audioLevelDuration": sample.audioLevel?.timeRange.duration.seconds as Any,
                
                "speechExpressionStart": sample.speechExpression?.timeRange.start.seconds as Any,
                "speechExpressionDuration": sample.speechExpression?.timeRange.duration.seconds as Any,
                "speechExpressionVersion": sample.speechExpression?.version as Any,
                "speechExpressionConfidence": sample.speechExpression?.confidence as Any,
                "speechExpressionMood": sample.speechExpression?.mood as Any,
                "speechExpressionValence": sample.speechExpression?.valence as Any,
                "speechExpressionActivation": sample.speechExpression?.activation as Any,
                "speechExpressionDominance": sample.speechExpression?.dominance as Any,
                
                "soundClassificationStart": sample.soundClassification?.timeRange.start.seconds as Any,
                "soundClassificationDuration": sample.soundClassification?.timeRange.duration.seconds as Any,
                "soundClassification": (classificationsString ?? nil) as Any
            ])
        } else {
            // Fallback on earlier versions
        }
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedTelephonySpeechMetrics = date
//    }
}
//
//extension SensorKitDataExtractor {
//    func convertTelephonySpeechMetricsData(result: SRFetchResult<AnyObject>) {
//        if #available(iOS 17.0, *) {
//            let sample = result.sample as! SRSpeechMetrics
//
//            var classifications: [SNClassification]? = sample.soundClassification?.classifications
//
//            var classificationsString = classifications?.compactMap { word in
//                word.identifier + ": " + word.confidence.description
//            }.joined(separator: ", ")
//
//            sensorDataArray.append([
//                "time": sample.timestamp.timeIntervalSince1970,
//                "timeReceived": sample.timestamp.timeIntervalSince1970,
//                "audioLevelLoudness": sample.audioLevel?.loudness as Any,
//                "audioLevelStart": sample.audioLevel?.timeRange.start.seconds as Any,
//                "audioLevelDuration": sample.audioLevel?.timeRange.duration.seconds as Any,
//
//                "speechExpressionStart": sample.speechExpression?.timeRange.start.seconds as Any,
//                "speechExpressionDuration": sample.speechExpression?.timeRange.duration.seconds as Any,
//                "speechExpressionVersion": sample.speechExpression?.version as Any,
//                "speechExpressionConfidence": sample.speechExpression?.confidence as Any,
//                "speechExpressionMood": sample.speechExpression?.mood as Any,
//                "speechExpressionValence": sample.speechExpression?.valence as Any,
//                "speechExpressionActivation": sample.speechExpression?.activation as Any,
//                "speechExpressionDominance": sample.speechExpression?.dominance as Any,
//
//                "soundClassificationStart": sample.soundClassification?.timeRange.start.seconds as Any,
//                "soundClassificationDuration": sample.soundClassification?.timeRange.duration.seconds as Any,
//                "soundClassification": (classificationsString ?? nil) as Any
//            ])
//        } else {
//            // Fallback on earlier versions
//        }
//
//    }
//}
//
