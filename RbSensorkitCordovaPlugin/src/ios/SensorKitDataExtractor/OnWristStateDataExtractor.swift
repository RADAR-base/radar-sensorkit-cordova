//
//  OnWristStateDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

extension RbSensorkitCordovaPlugin {
    func convertOnWristSensorData(result: SRFetchResult<AnyObject>){
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
            "crownOrientation": sample.crownOrientation.description,
            "onWrist": sample.onWrist,
            "wristLocation": sample.wristLocation.description,
            "offWristDate": offWristDate,
            "onWristDate": onWristDate,
        ])
    }
}

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

