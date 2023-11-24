//
//  SensorKitProtocol.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 27/07/2023.
//

import Foundation
import SensorKit

//protocol SensorKitDelegate {
//    func startRecodingResponse(_ res: ResponseType, _ err: Error?)
//    func stopRecodingResponse(_ res: ResponseType, _ err: Error?)
//    func fetchDevicesResponse(_ res: ResponseType, _ err: Error?, _ devices: [[String: Any]]?)
//    func fetchDataResponse(_ res: ResponseType, _ err: Error?, _ response: [String: Any]?)
//    func authorizationResponse(_ res: ResponseType, _ err: Error?, _ response: SRAuthorizationStatus)
//}

protocol SensorKitDelegate {
    func __fetchCompletedForOneSensor(date: Date)
    func __didStopRecording(sensor: SRSensor)
    func __failedStopRecording(sensor: SRSensor, error: Error)
//    func __didStartRecording(sensor: SRSensor)
//    func __failedStartRecording(sensor: SRSensor, error: Error)
}
