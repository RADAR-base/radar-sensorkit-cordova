//
//  MediaEventsDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//
//
//import Foundation
//import SensorKit
//
//extension RbSensorkitCordovaPlugin {
//    func convertMediaEventsSensorData(result: SRFetchResult<AnyObject>){
//        if #available(iOS 16.4, *) {
//            let sample = result.sample as! SRMediaEvent
//            let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
//            sensorDataArray.append([
//                "time": time,
//                "timeReceived": time,
//                "eventType": sample.eventType,
//                "mediaIdentifier": sample.mediaIdentifier,
//            ])
//        }
//    }
//}
