//
//  AmbientPressureDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

@available(iOS 15.4, *)
class AmbientPressureDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .ambientPressure } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAmbientPressure! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedPressureData]
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
                lastRecordTS = currentRecordTS
                sensorDataArray.append([
                    "time": currentRecordTS,
                    "timeReceived": currentRecordTS,
                    "device": selectedDevice?.model ?? "UNKNOWN",
                    "pressure": a.pressure.value,
                    "temperature": a.temperature.value,
                ])
            }
        }
    }
    
    override func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        convertSensorData(result: result)
        return true
    }
}
