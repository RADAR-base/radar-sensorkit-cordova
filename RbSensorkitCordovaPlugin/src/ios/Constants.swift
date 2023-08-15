import SensorKit
struct Constants {
    static let TOPIC_NAME: [String : String] = [
        "accelerometer": "sensorkit_acceleration",
        "ambientLightSensor": "sensorkit_ambient_light",
        "ambientPressure": "sensorkit_ambient_pressure",
        "deviceUsageReport": "sensorkit_device_usage",
        "keyboardMetrics": "sensorkit_keyboard_metrics",
        "mediaEvents": "sensorkit_media_events",
        "messagesUsageReport": "sensorkit_message_usage",
        "onWristState": "sensorkit_on_wrist",
        "pedometerData": "sensorkit_pedometer",
        "phoneUsageReport": "sensorkit_phone_usage",
        "rotationRate": "sensorkit_rotation_rate",
        "siriSpeechMetrics": "",
        "telephonySpeechMetrics": "",
        "visits": "sensorkit_visits",
    ]

    static let DEFAULT_PERIOD: [String : Double] = [
        "accelerometer": 20,
        "ambientLightSensor": 60000,
        "deviceUsageReport": 0,
        "keyboardMetrics": 0,
        "messagesUsageReport": 0,
        "onWristState": 0,
        "pedometerData": 0,
        "phoneUsageReport": 0,
        "rotationRate": 20,
        "visits": 0,
        "ambientPressure": 60000,
        "mediaEvents": 0,
        "siriSpeechMetrics": 0,
        "telephonySpeechMetrics": 0,
    ]
    static let DEFAULT_CHUNK_SIZE = 10000
    static let APP_NAME = "RADAR-base Sesnsorkit Plugin"
    static let APP_SHORT_NAME = "RbSensorkitPlugin"
}

struct Config {
    static var token = ""
    static var baseUrl = ""
    static var kafkaEndpoint = ""
    static var schemaEndpoint = ""
    static var projectId = ""
    static var userId = ""
    static var sourceId = ""
}

enum PostToKafkaError: Error {
    case runtimeError(String)
}

enum TopicKeyValue: String {
    case KEY = "key"
    case VALUE = "value"
}

