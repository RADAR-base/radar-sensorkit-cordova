//
//  OnWristStateDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

@available(iOS 14.0, *)
class OnWristStateDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .onWristState } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedOnWrist! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRWristDetection
        var offWristDate = 0.0
        var onWristDate = 0.0
        if #available(iOS 16.4, *) {
            offWristDate = sample.offWristDate?.timeIntervalSince1970 ?? 0
            onWristDate = sample.onWristDate?.timeIntervalSince1970 ?? 0
        }
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "device": selectedDevice?.model ?? "UNKNOWN",
            "crownOrientation": sample.crownOrientation.description,
            "onWrist": sample.onWrist,
            "wristLocation": sample.wristLocation.description,
            "offWristDate": offWristDate,
            "onWristDate": onWristDate,
        ])
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedOnWrist
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedOnWrist = date
    }
}

@available(iOS 14.0, *)
extension SRWristDetection.CrownOrientation {
    var description: String {
        get {
            switch self {
                case .left:
                  return "LEFT"
                case .right:
                  return "RIGHT"
            }
        }
    }
}

@available(iOS 14.0, *)
extension SRWristDetection.WristLocation {
    var description: String {
        get {
            switch self {
                case .left:
                  return "LEFT"
                case .right:
                  return "RIGHT"
            }
        }
    }
}
