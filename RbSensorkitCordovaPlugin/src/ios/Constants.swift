import SensorKit

struct Constants {
    static let DefaultKafkaEndpoint = "kafka/topics/"
    static let DefaultSchemaEndpoint = "/schema/subjects/"

    static let DEFAULT_CHUNK_SIZE = 10000
    static let APP_NAME = "RADAR-base Sesnsorkit Plugin"
    static let APP_SHORT_NAME = "RbSensorkitPlugin"
}

struct ConfigSensor {
    static var periods: Dictionary<String, Double> = [
        "accelerometer": 1000,
        "ambientLightSensor": 6000,
        "ambientPressure": 6000,
        "deviceUsageReport": 0,
        "faceMetrics": 0,
        "heartRate": 1000,
        "keyboardMetrics": 0,
        "mediaEvents": 0,
        "messagesUsageReport": 0,
        "odometer": 0,
        "onWristState": 0,
        "pedometerData": 0,
        "phoneUsageReport": 0,
        "rotationRate": 1000,
        "siriSpeechMetrics": 0,
        "telephonySpeechMetrics": 0,
        "visits": 0,
        "wristTemperature": 0,
        "magneticField": 0,
    ]
    static var topics: Dictionary<String, String> = [
        "accelerometer": "sensorkit_acceleration",
        "ambientLightSensor": "sensorkit_ambient_light",
        "ambientPressure": "sensorkit_ambient_pressure",
        "deviceUsageReport": "sensorkit_device_usage",
        "faceMetrics": "sensorkit_face_metrics",
        "heartRate": "sensorkit_heart_rate",
        "keyboardMetrics": "sensorkit_keyboard_metrics",
        "mediaEvents": "sensorkit_media_events",
        "messagesUsageReport": "sensorkit_message_usage",
        "odometer": "sensorkit_odometer",
        "onWristState": "sensorkit_on_wrist",
        "pedometerData": "sensorkit_pedometer",
        "phoneUsageReport": "sensorkit_phone_usage",
        "rotationRate": "sensorkit_rotation_rate",
        "siriSpeechMetrics": "sensorkit_siri_speech_metrics",
        "telephonySpeechMetrics": "sensorkit_telephony_speech_metrics",
        "visits": "sensorkit_visits",
        "wristTemperature": "sensorkit_wrist_temperature",
        "magneticField": "apple_ios_magnetic_field"
    ]
    static var chunkSize: Dictionary<String, Int> = [
        "accelerometer": Constants.DEFAULT_CHUNK_SIZE,
        "ambientLightSensor": Constants.DEFAULT_CHUNK_SIZE,
        "ambientPressure": Constants.DEFAULT_CHUNK_SIZE,
        "deviceUsageReport": Constants.DEFAULT_CHUNK_SIZE,
        "faceMetrics": Constants.DEFAULT_CHUNK_SIZE,
        "heartRate": Constants.DEFAULT_CHUNK_SIZE,
        "keyboardMetrics": Constants.DEFAULT_CHUNK_SIZE,
        "mediaEvents": Constants.DEFAULT_CHUNK_SIZE,
        "messagesUsageReport": Constants.DEFAULT_CHUNK_SIZE,
        "odometer": Constants.DEFAULT_CHUNK_SIZE,
        "onWristState": Constants.DEFAULT_CHUNK_SIZE,
        "pedometerData": Constants.DEFAULT_CHUNK_SIZE,
        "phoneUsageReport": Constants.DEFAULT_CHUNK_SIZE,
        "rotationRate": Constants.DEFAULT_CHUNK_SIZE,
        "siriSpeechMetrics": Constants.DEFAULT_CHUNK_SIZE,
        "telephonySpeechMetrics": Constants.DEFAULT_CHUNK_SIZE,
        "visits": Constants.DEFAULT_CHUNK_SIZE,
        "wristTemperature": Constants.DEFAULT_CHUNK_SIZE,
        "magneticField": Constants.DEFAULT_CHUNK_SIZE,
    ]
}

struct RadarbaseConfig {
    static var baseUrl: String? = nil //"https://radar-dev.connectdigitalstudy.com/"
    static var kafkaEndpoint = "kafka/topics/"
    static var schemaEndpoint = "/schema/subjects/"
    static var logTopicKeyId: Int? = nil
    static var logTopicValueId: Int? = nil
}

struct UserConfig {
    static var token: String? = nil //"eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOlsicmVzX2FwcGNvbmZpZyIsInJlc19BcHBTZXJ2ZXIiLCJyZXNfZ2F0ZXdheSIsInJlc19NYW5hZ2VtZW50UG9ydGFsIl0sInN1YiI6Ijk2OWI5OTI5LTExNTktNDMyMS04YzM1LTFjZDM0ZjkzNGU4NyIsInNvdXJjZXMiOlsiOWMxMmI5MzItNDI5ZC00OWI2LWE0OTQtNDUzZGFlZjc0NDRmIl0sImdyYW50X3R5cGUiOiJhdXRob3JpemF0aW9uX2NvZGUiLCJ1c2VyX25hbWUiOiI5NjliOTkyOS0xMTU5LTQzMjEtOGMzNS0xY2QzNGY5MzRlODciLCJyb2xlcyI6WyJTVEFHSU5HX1BST0pFQ1Q6Uk9MRV9QQVJUSUNJUEFOVCJdLCJzY29wZSI6WyJNRUFTVVJFTUVOVC5DUkVBVEUiLCJTVUJKRUNULlJFQUQiLCJTVUJKRUNULlVQREFURSJdLCJpc3MiOiJNYW5hZ2VtZW50UG9ydGFsIiwiZXhwIjoxNzAwNDUzNDQ2LCJpYXQiOjE3MDA0MTAyNDYsImF1dGhvcml0aWVzIjpbIlJPTEVfUEFSVElDSVBBTlQiXSwiY2xpZW50X2lkIjoiYVJNVCJ9.Kjcl1WtqmnZc6cQcCFjR81tr8XUhm8EBKKt_w5ftxeOxxV2fpdRpkORkkj_a7qeIovUR_QGg5z9-S57UpdWjFw"
    static var projectId: [String : String?] = ["string": nil]  //"STAGING_PROJECT"]
    static var userId: String? = nil //"969b9929-1159-4321-8c35-1cd34f934e87"
    static var sourceId: String? = nil //"c032209c-b44a-45d5-b5a8-d45fef68a63e"
}

enum PostToKafkaError: Error {
    case runtimeError(String)
}

enum TopicKeyValue: String {
    case KEY = "key"
    case VALUE = "value"
}

struct UploadError: Error {
    let message: String

    init(message: String) {
        self.message = message
    }
}
