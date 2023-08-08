//
//  AmbientLightDataExtractor.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 10/07/2023.
//

import Foundation
import SensorKit

extension RbSensorkitCordovaPlugin {
    func convertAmbientLightData(result: SRFetchResult<AnyObject>) {
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
            }
        }
    }
}

