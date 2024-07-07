//
//  OnWristStateDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion
import SwiftAvroCore

@available(iOS 14.0, *)
class OnWristStateDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .onWristState } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedOnWrist! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRWristDetection
        var offWristDate = 0.0
        var onWristDate = 0.0
        if #available(iOS 16.4, *) {
            offWristDate = sample.offWristDate?.timeIntervalSince1970 ?? 0
            onWristDate = sample.onWristDate?.timeIntervalSince1970 ?? 0
        }
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
            let onWristState = OnWristStateModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                crownOrientation: sample.crownOrientation.description,
                onWrist: sample.onWrist,
                wristLocation: sample.wristLocation.description,
                offWristDate: offWristDate,
                onWristDate: onWristDate
            )
            let binaryValue = try avro.encode(onWristState)
            sensorDataArray.append([time: [UInt8](binaryValue)])
        } catch {
            print("Failed to encode OnWrist State data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedOnWrist
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedOnWrist = date
    }
}

@available(iOS 14.0, *)
extension SRWristDetection.CrownOrientation {
    var description: CrownOrientation {
        get {
            switch self {
                case .left:
                  return CrownOrientation.LEFT
                case .right:
                  return CrownOrientation.RIGHT
            }
        }
    }
}

@available(iOS 14.0, *)
extension SRWristDetection.WristLocation {
    var description: WristLocation {
        get {
            switch self {
                case .left:
                return WristLocation.LEFT
                case .right:
                return WristLocation.RIGHT
            }
        }
    }
}


struct OnWristStateModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let crownOrientation: CrownOrientation
    let onWrist: Bool
    let wristLocation: WristLocation
    let offWristDate: Double
    let onWristDate: Double
}

enum CrownOrientation: String, Codable {
    case LEFT, RIGHT
}

enum WristLocation: String, Codable {
    case LEFT, RIGHT
}
