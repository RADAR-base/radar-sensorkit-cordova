//
//  RotationRateDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//
//
//import Foundation
//import SensorKit
//import CoreMotion
//
//extension RbSensorkitCordovaPlugin {
//    func convertRotationRateSensorData(result: SRFetchResult<AnyObject>){
//        let sample = result.sample as! [CMRecordedRotationRateData]
//        sample.forEach { a in
//            if(sensorDataArray.count < 10000){
//                sensorDataArray.append([
//                    "time": result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970,
//                    "timeReceived": Date().timeIntervalSince1970,
//                    "startDate": a.startDate.timeIntervalSince1970,
//                    "x": a.rotationRate.x,
//                    "y": a.rotationRate.y,
//                    "z": a.rotationRate.z,
//                ])
//            }
//        }
//    }
//}
