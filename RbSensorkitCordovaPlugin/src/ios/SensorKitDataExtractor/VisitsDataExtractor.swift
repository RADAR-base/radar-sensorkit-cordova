//
//  VisitDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion
import SwiftAvroCore

@available(iOS 14.0, *)
class VisitsDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .visits } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedVisit! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRVisit
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
            let visit = VisitModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                identifier: sample.identifier.uuidString,
                arrivalDateIntervalStart: sample.arrivalDateInterval.start.timeIntervalSince1970,
                arrivalDateIntervalEnd: sample.arrivalDateInterval.end.timeIntervalSince1970,
                arrivalDateIntervalDuration: sample.arrivalDateInterval.duration,
                departureDateIntervalStart: sample.departureDateInterval.start.timeIntervalSince1970,
                departureDateIntervalEnd: sample.departureDateInterval.end.timeIntervalSince1970,
                departureDateIntervalDuration: sample.departureDateInterval.duration,
                distanceFromHome: sample.distanceFromHome,
                locationCategory: sample.locationCategory.description
            )
            let binaryValue = try avro.encode(visit)
            sensorDataArray.append([time: [UInt8](binaryValue)])
        } catch {
            print("Failed to encode Visits data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedVisit
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedVisit = date
    }
}

@available(iOS 14.0, *)
extension SRVisit.LocationCategory {
    var description: LocationCategory {
        get {
            switch self {
                case .gym:
                return LocationCategory.GYM
                case .home:
                  return LocationCategory.HOME
                case .school:
                return LocationCategory.SCHOOL
                case .work:
                return LocationCategory.WORK
                case .unknown:
                return LocationCategory.UNKNOWN
            }
        }
    }
}

struct VisitModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let identifier: String
    let arrivalDateIntervalStart: Double
    let arrivalDateIntervalEnd: Double
    let arrivalDateIntervalDuration: Double
    let departureDateIntervalStart: Double
    let departureDateIntervalEnd: Double
    let departureDateIntervalDuration: Double
    let distanceFromHome: Double
    let locationCategory: LocationCategory
}

enum LocationCategory: String, Codable {
    case GYM, HOME, SCHOOL, WORK, UNKNOWN
}

