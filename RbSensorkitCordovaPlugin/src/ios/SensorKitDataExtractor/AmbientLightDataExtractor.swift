import Foundation
import SensorKit
import SwiftAvroCore

@available(iOS 14.0, *)
class AmbientLightDataExtractor: SensorKitDataExtractor {
    override var sensor: SRSensor? { get { return .ambientLightSensor } }
//    override var beginDate: Date? { get { return PersistentContainer.shared.lastFetchedAmbientLighth! } }
    
    override func convertSensorData(result: SRFetchResult<AnyObject>){
        let sample = result.sample as! SRAmbientLightSample
        let time = result.timestamp.toCFAbsoluteTime() + kCFAbsoluteTimeIntervalSince1970
        let avro = Avro()
        do {
            _ = avro.decodeSchema(schema: self.topicSchemaStr!)!
            let ambientLight = AmbientLightModel(
                time: time,
                timeReceived: time,
                device: selectedDevice?.model ?? "UNKNOWN",
                chromaticityX: sample.chromaticity.x,
                chromaticityY: sample.chromaticity.y,
                lux: Float(sample.lux.value),
                placement: sample.placement.description
            )
            let binaryValue = try avro.encode(ambientLight)
            sensorDataArray.append([time: [UInt8](binaryValue)])
        } catch {
            print("Failed to encode AmbientLight data: \(error)")
        }
    }
    
    override func getBeginDate() -> Double? {
        return PersistentContainer.shared.lastFetchedAmbientLighth
    }
    
    override func _updateLastFetch(date: Double) {
        PersistentContainer.shared.lastFetchedAmbientLighth = date
    }
    
}

@available(iOS 14.0, *)
extension SRAmbientLightSample.SensorPlacement {
    var description: SensorPlacement {
        get {
            switch self {
                case .frontBottom:
                return SensorPlacement.FRONT_BOTTOM
                case .frontBottomLeft:
                return SensorPlacement.FRONT_BOTTOM_LEFT
                case .frontBottomRight:
                return SensorPlacement.FRONT_BOTTOM_RIGHT
                case .frontLeft:
                return SensorPlacement.FRONT_LEFT
                case .frontRight:
                return SensorPlacement.FRONT_RIGHT
                case .frontTop:
                return SensorPlacement.FRONT_TOP
                case .frontTopLeft:
                return SensorPlacement.FRONT_TOP_LEFT
                case .frontTopRight:
                return SensorPlacement.FRONT_TOP_RIGHT
                case .unknown:
                return SensorPlacement.UNKNOWN
                @unknown default:
                return SensorPlacement.UNKNOWN
            }
        }
    }
}

struct AmbientLightModel: Encodable, Decodable {
    let time: Double
    let timeReceived: Double
    let device: String
    let chromaticityX: Float
    let chromaticityY: Float
    let lux: Float
    let placement: SensorPlacement
}

enum SensorPlacement: String, Codable {
    case FRONT_BOTTOM, FRONT_BOTTOM_LEFT, FRONT_BOTTOM_RIGHT, FRONT_LEFT, FRONT_RIGHT, FRONT_TOP, FRONT_TOP_LEFT, FRONT_TOP_RIGHT, UNKNOWN
}

