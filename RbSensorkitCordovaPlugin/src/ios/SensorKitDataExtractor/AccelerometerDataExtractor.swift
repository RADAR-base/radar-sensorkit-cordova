//
//  AccelerometerDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

class AccelerometerDataExtractor: SensorKitDataExtractor {
//    override var defaultTopic: String { get { return DefaultTopics.Accelerometer } }
//    override var defaultPriod: Double { get { return DefaultPeriods.Accelerometer } }
    override var sensor: SRSensor? { get { return .accelerometer } }
    override var fetchIntervalInHours: Int { get {return 1 * 24 }} // 1 days = 1 * 24 hours
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAccelerometer! } }

    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedAccelerometerData]
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
//            print("&&& P=\(periodMili) L=\(lastRecordTS) C=\(currentRecordTS)")
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
    
    override func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        convertSensorData(result: result)
        return true
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedAccelerometer = date
//    }
}
//extension SensorKitDataExtractor {
//    func convertAccelerometerSensorData(result: SRFetchResult<AnyObject>){
//        let sample = result.sample as! [CMRecordedAccelerometerData]
//        sample.forEach { a in
//            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
////            print("&&& P=\(periodMili) L=\(lastRecordTS) C=\(currentRecordTS)")
//            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
//                //counter += 1
//                lastRecordTS = currentRecordTS
//                sensorDataArray.append([
//                    "time": currentRecordTS,
//                    "timeReceived": currentRecordTS,
//                    "x": a.acceleration.x,
//                    "y": a.acceleration.y,
//                    "z": a.acceleration.z,
//                ])
//            }
//        }
//    }
//}
//
