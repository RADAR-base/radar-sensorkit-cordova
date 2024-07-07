//
//  AmbientPressureDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion
import SwiftAvroCore

@available(iOS 15.4, *)
class AmbientPressureDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .ambientPressure } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAmbientPressure! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! [CMRecordedPressureData]
        let avro = Avro()
        _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
        sample.forEach { a in
            let currentRecordTS: Double = a.startDate.timeIntervalSince1970
            if 1000 * (currentRecordTS - lastRecordTS) >= periodMili {
                lastRecordTS = currentRecordTS
                do {
                    let ambientPressure = AmbientPressureModel(
                        time: currentRecordTS,
                        timeReceived: currentRecordTS,
                        device: selectedDevice?.model ?? "UNKNOWN",
                        pressure: a.pressure.value,
                        temperature: a.temperature.value
                    )
                    let binaryValue = try avro.encode(ambientPressure)
                    sensorDataArray.append([currentRecordTS: [UInt8](binaryValue)])
                } catch {
                    print("Failed to encode Ambient Pressure data: \(error)")
                }
            }
        }
    }
    
    override func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
        convertSensorData(result: result)
        return true
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedAmbientPressure
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedAmbientPressure = date
    }
}

struct AmbientPressureModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let pressure: Double
    let temperature: Double
}
