//
//  AccelerometerDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

extension RbSensorkitCordovaPlugin {
    func convertAccelerometerSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedAccelerometerData]
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
                //counter += 1
                lastRecordTS = currentRecordTS
                sensorDataArray.append([
                    "time": currentRecordTS,
                    "timeReceived": currentRecordTS,
                    "x": a.acceleration.x,
                    "y": a.acceleration.y,
                    "z": a.acceleration.z,
                ])
            }
        }
    }
}
