//
//  VisitDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit
import CoreMotion

class VisitsDataExtractor: SensorKitDataExtractor {
//    override var defaultTopic: String { get { return DefaultTopics.Visit } }
//    override var defaultPriod: Double { get { return DefaultPeriods.Visit } }
    override var sensor: SRSensor? { get { return .visits } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedVisit! } }

    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRVisit
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        sensorDataArray.append([
            "time": time,
            "timeReceived": time,
            "identifier": sample.identifier.uuidString,
            "arrivalDateIntervalStart": sample.arrivalDateInterval.start.timeIntervalSince1970,
            "arrivalDateIntervalEnd": sample.arrivalDateInterval.end.timeIntervalSince1970,
            "arrivalDateIntervalDuration": sample.arrivalDateInterval.duration,
            "departureDateIntervalStart": sample.departureDateInterval.start.timeIntervalSince1970,
            "departureDateIntervalEnd": sample.departureDateInterval.end.timeIntervalSince1970,
            "departureDateIntervalDuration": sample.departureDateInterval.duration,
            "distanceFromHome": sample.distanceFromHome,
            "locationCategory": sample.locationCategory.description,
        ])
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedVisit = date
//    }
}

//extension SensorKitDataExtractor {
//    func convertVisitsSensorData(result: SRFetchResult<AnyObject>){
//        let sample = result.sample as! SRVisit
//        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
//        sensorDataArray.append([
//            "time": time,
//            "timeReceived": time,
//            "identifier": sample.identifier.uuidString,
//            "arrivalDateIntervalStart": sample.arrivalDateInterval.start.timeIntervalSince1970,
//            "arrivalDateIntervalEnd": sample.arrivalDateInterval.end.timeIntervalSince1970,
//            "arrivalDateIntervalDuration": sample.arrivalDateInterval.duration,
//            "departureDateIntervalStart": sample.departureDateInterval.start.timeIntervalSince1970,
//            "departureDateIntervalEnd": sample.departureDateInterval.end.timeIntervalSince1970,
//            "departureDateIntervalDuration": sample.departureDateInterval.duration,
//            "distanceFromHome": sample.distanceFromHome,
//            "locationCategory": sample.locationCategory.description,
//        ])
//    }
//}

extension SRVisit.LocationCategory {
    var description: String {
        get {
            switch self {
                case .gym:
                  return "GYM"
                case .home:
                  return "HOME"
                case .school:
                  return "SCHOOL"
                case .work:
                  return "WORK"
                case .unknown:
                  return "UNKNOWN"
            }
        }
    }
}

