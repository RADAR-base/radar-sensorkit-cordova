//
//  SensorKitProtocol.swift
//  SensorKitTestIOS
//
//  Created by Peyman Mohtashami on 27/07/2023.
//

import Foundation
import SensorKit

@available(iOS 14.0, *)
protocol SensorKitDelegate {
    func __fetchCompletedForOneSensor(sensor: SRSensor, date: Date)
    func __didStopRecording(sensor: SRSensor)
    func __failedStopRecording(sensor: SRSensor, error: Error)
    func __failedFetchTopic(topicName: String, error: Error)
    func __didUploadFileFailed(error: UploadError)
    func __didUploadFileSuccess()
}
