import Foundation
import SensorKit

class AmbientLightDataExtractor: SensorKitDataExtractor {
//    override var defaultTopic: String { get { return DefaultTopics.AmbientLight } }
//    override var defaultPriod: Double { get { return DefaultPeriods.AmbientLight } }
    override var sensor: SRSensor? { get { return .ambientLightSensor } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAmbientLighth! } }

    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRAmbientLightSample
         let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
         sensorDataArray.append([
             "time": time,
             "timeReceived": time,
             "placement": sample.placement.description,
             "chromaticityX": sample.chromaticity.x,
             "chromaticityY": sample.chromaticity.y,
             "lux": sample.lux.value
         ])
    }
    
//    override func updateLastFetched(date: Date) {
//        PersistentContainer.shared.lastFetchedAmbientLighth = date
//    }
    
//    func sensorReader(_ reader: SRSensorReader, fetching fetchRequest: SRFetchRequest, didFetchResult result: SRFetchResult<AnyObject>) -> Bool {
//        let currentRecordTS: Double = result.timestamp.rawValue * 1000
//        if currentRecordTS - lastRecordTS >= periodMili {
//            lastRecordTS = currentRecordTS
////            convertSensorData(result: result)
//            convertAmbientLightSensorData(result: result)
//        }
//        return true
//    }
}

extension SRAmbientLightSample.SensorPlacement {
    var description: String {
        get {
            switch self {
                case .frontBottom:
                    return "FRONT_BOTTOM"
                case .frontBottomLeft:
                    return "FRONT_BOTTOM_LEFT"
                case .frontBottomRight:
                    return "FRONT_BOTTOM_RIGHT"
                case .frontLeft:
                    return "FRONT_LEFT"
                case .frontRight:
                    return "FRONT_RIGHT"
                case .frontTop:
                    return "FRONT_TOP"
                case .frontTopLeft:
                    return "FRONT_TOP_LEFT"
                case .frontTopRight:
                    return "FRONT_TOP_RIGHT"
                case .unknown:
                    return "UNKNOWN"
                @unknown default:
                    return "UNKNOWN"
            }
        }
    }
}

