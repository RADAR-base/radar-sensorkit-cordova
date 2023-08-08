//
//  SiriSpeechMetricsDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//
//
//  TelephonySpeechMetricsDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
//
//class SiriSpeechMetricsDataExtractor : SensorKitDataExtractor {
//    override var topicName: String {
//        return "android_phone_siri_speech_metrics"
//    }
//    
//    func sensorReader(_ reader: SRSensorReader, didCompleteFetch fetchRequest: SRFetchRequest) {
//        print("sensorReader didCompleteFetch \(reader.sensor.rawValue) (\(counter))")
//        counter = 0
//        processData(sensorDataArray: sensorDataArray)
//        sensorDataArray = []
//    }
//    /*
//     No Schema
//     */
//    /*
//     Getting session information
//     var sessionIdentifier: String
//        An identifier for the audio session.
//     var sessionFlags: SRSpeechMetrics.SessionFlags
//        Details about the audio processing.
//     
//     struct SRSpeechMetrics.SessionFlags
//        Possible details about processing an audio stream.
//     
//     var timestamp: Date
//        The date and time when the speech occurs.
//     
//     Getting speech metrics and analytics
//     var audioLevel: SRAudioLevel?
//        The audio level of the speech.
//     
//     class SRAudioLevel
//        An object that represents the audio level for a range of speech.
//     
//     var speechRecognition: SFSpeechRecognitionResult?
//        The partial or final results of the speech recognition request.
//     var soundClassification: SNClassificationResult?
//        The highest-ranking classifications in the time range.
//     var speechExpression: SRSpeechExpression?
//        The metrics and voice analytics for the range of speech.
//     */
//    
//    // main
//    override func convertSensorData(result: SRFetchResult<AnyObject>){
//        let sample = result.sample as! SRSpeechMetrics
//            sensorDataArray.append([
//                "time": result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970,
//                "timeReceived": Date().timeIntervalSince1970,
//            ])
//    }
//}
