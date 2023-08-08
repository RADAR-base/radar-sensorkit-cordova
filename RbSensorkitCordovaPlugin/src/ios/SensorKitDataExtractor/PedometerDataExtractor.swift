//
//  PedometerDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

extension RbSensorkitCordovaPlugin {
    func convertPedometerSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! CMPedometerData
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "startDate": sample.startDate.timeIntervalSince1970,
            "endDate": sample.endDate.timeIntervalSince1970,
            "numberOfSteps": sample.numberOfSteps,
            "distance": sample.distance ?? 0,
            "averageActivePace": sample.averageActivePace ?? 0,
            "currentPace": sample.currentPace ?? 0,
            "currentCadence": sample.currentCadence ?? 0,
            "floorsAscended": sample.floorsAscended ?? 0,
            "floorsDescended": sample.floorsDescended ?? 0,
        ])
    }
}
