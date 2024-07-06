//
//  PedometerDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion
import SwiftAvroCore

@available(iOS 14.0, *)
class PedometerDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .pedometerData } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedPedometer! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! CMPedometerData
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
            let pedometer = PedometerModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                startDate: sample.startDate.timeIntervalSince1970,
                endDate: sample.endDate.timeIntervalSince1970,
                numberOfSteps: Int(truncating: sample.numberOfSteps),
                distance: Double(truncating: sample.distance ?? 0),
                averageActivePace: Double(truncating: sample.averageActivePace ?? 0),
                currentPace: Double(truncating: sample.currentPace ?? 0),
                currentCadence: Double(truncating: sample.currentCadence ?? 0),
                floorsAscended: Int(truncating: sample.floorsAscended ?? 0),
                floorsDescended: Int(truncating: sample.floorsDescended ?? 0)
            )
            let binaryValue = try avro.encode(pedometer)
            sensorDataArray.append([UInt8](binaryValue))
        } catch {
            print("Failed to encode Pedometer data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedPedometer
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedPedometer = date
    }
}

struct PedometerModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let startDate: Double
    let endDate: Double
    let numberOfSteps: Int
    let distance: Double
    let averageActivePace: Double
    let currentPace: Double
    let currentCadence: Double
    let floorsAscended: Int
    let floorsDescended: Int
}
