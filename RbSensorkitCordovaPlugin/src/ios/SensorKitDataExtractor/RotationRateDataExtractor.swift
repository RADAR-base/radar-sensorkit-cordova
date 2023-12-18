//
//  RotationRateDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

@available(iOS 14.0, *)
class RotationDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .rotationRate } }
    override var fetchIntervalInHours: Int { get {return 1 * 6 }} // 1 days = 1 * 24 hours
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAccelerometer! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedRotationRateData]
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
                lastRecordTS = currentRecordTS
                sensorDataArray.append([
                    "time": currentRecordTS,
                    "timeReceived": currentRecordTS,
                    "device": selectedDevice?.model ?? "UNKNOWN",
                    "x": a.rotationRate.x,
                    "y": a.rotationRate.y,
                    "z": a.rotationRate.z,
                ])
            }
        }
    }
    
    override func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        convertSensorData(result: result)
        return true
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedRotationRate
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedRotationRate = date
    }
}
