//
//  AccelerometerDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion
import SwiftAvroCore

@available(iOS 14.0, *)
class AccelerometerDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .accelerometer } }
    override var fetchIntervalInHours: Int { get {return 1 * 6 }}
//    override var beginDate: Double { get { return PersistentContainer.shared.lastFetchedAccelerometer! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedAccelerometerData]
        let avro = Avro()
        _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
                lastRecordTS = currentRecordTS
                do {
                    let acceleration = AccelerationModel(
                        time: currentRecordTS,
                        timeReceived: currentRecordTS,
                        device: selectedDevice?.model ?? "UNKNOWN",
                        x: Float(a.acceleration.x),
                        y: Float(a.acceleration.y),
                        z: Float(a.acceleration.z)
                    )
                    let binaryValue = try avro.encode(acceleration)
                    sensorDataArray.append([currentRecordTS: [UInt8](binaryValue)])
                } catch {
                    print("Failed to encode Accelerometer data: \(error)")
                }
            }
        }
    }
    
    override func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        convertSensorData(result: result)
        return true
    }
    
    override func getBeginDate() -> Double? {
//        print("getBeginDate \(PersistentContainer.shared.lastFetchedAccelerometer)")
        return PersistentContainer.shared.lastFetchedAccelerometer
    }
    
    override func _updateLastFetch(date: Double) {
//        print("_updateLastFetch \(date)")
        PersistentContainer.shared.lastFetchedAccelerometer = date
    }
}

struct AccelerationModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let x: Float
    let y: Float
    let z: Float
}
