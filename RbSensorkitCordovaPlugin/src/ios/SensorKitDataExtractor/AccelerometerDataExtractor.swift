//
//  AccelerometerDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

@available(iOS 14.0, *)
class AccelerometerDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .accelerometer } }
    override var fetchIntervalInHours: Int { get {return 1 * 24 }} // 1 days = 1 * 24 hours
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAccelerometer! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedAccelerometerData]
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
                lastRecordTS = currentRecordTS
                sensorDataArray.append([
                    "time": currentRecordTS,
                    "timeReceived": currentRecordTS,
                    "device": selectedDevice?.model ?? "UNKNOWN",
                    "x": a.acceleration.x,
                    "y": a.acceleration.y,
                    "z": a.acceleration.z,
                ])
            }
        }
    }
    
    override func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        convertSensorData(result: result)
        return true
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedAccelerometer = date
//    }
}
