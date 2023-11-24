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
//    override var defaultTopic: String { get { return DefaultTopics.AmbientPressure } }
//    override var defaultPriod: Double { get { return DefaultPeriods.AmbientPressure } }
    override var sensor: SRSensor? { get { return .ambientPressure } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAmbientPressure! } }

    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedPressureData]
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
                //counter += 1
                lastRecordTS = currentRecordTS
                sensorDataArray.append([
                    "time": currentRecordTS,
                    "timeReceived": currentRecordTS,
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
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedAmbientPressure = date
//    }
}

//extension SensorKitDataExtractor {
//    func convertAmbientPressureSensorData(result: SRFetchResult<AnyObject>){
//        let sample = result.sample as! [CMRecordedPressureData]
//        sample.forEach { a in
//            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
//            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
//                //counter += 1
//                lastRecordTS = currentRecordTS
//                sensorDataArray.append([
//                    "time": currentRecordTS,
//                    "timeReceived": currentRecordTS,
//                    "pressure": a.pressure.value,
//                    "temperature": a.temperature.value,
//                ])
//            }
//        }
//    }
//}
//
