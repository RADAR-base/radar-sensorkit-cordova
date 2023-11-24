import SensorKit

struct Constants {
    static let DefaultKafkaEndpoint = "kafka/topics/"
    static let DefaultSchemaEndpoint = "/schema/subjects/"

    static let DEFAULT_CHUNK_SIZE = 10000
    static let APP_NAME = "RADAR-base Sesnsorkit Plugin"
    static let APP_SHORT_NAME = "RbSensorkitPlugin"
}

//struct ConfigSensorTopics {
//    static let Accelerometer = "sensorkit_acceleration"
//    static let AmbientLight = "sensorkit_ambient_light"
//    static let AmbientPressure = "sensorkit_ambient_pressure"
//    static let DeviceUsage = "sensorkit_device_usage"
//    static let KeyboardMetrics = "sensorkit_keyboard_metrics"
//    static let MedaiEvents = "sensorkit_media_events"
//    static let MessageUsage = "sensorkit_message_usage"
//    static let OnWrist = "sensorkit_on_wrist"
//    static let Pedometer = "sensorkit_pedometer"
//    static let PhoneUsage = "sensorkit_phone_usage"
//    static let RotationRate = "sensorkit_rotation_rate"
//    static let TelephonySpeechMetrics = "sensorkit_telephony_speech_metrics"
//    static let Visit = "sensorkit_visits"
//    static let SiriSpeechMetrics = "sensorkit_siri_speech_metrics"
//    static let FaceMetrics = "sensorkit_face_metrics"
//    static let HeartRate = "sensorkit_heart_rate"
//    static let WristTemperature = "sensorkit_wrist_temperature"
//    static let Odometer = "sensorkit_odometer"
//}

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
        "wristTemperature": 0
        
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
        "wristTemperature": "sensorkit_wrist_temperature"
    ]
}

//struct ConfigSensorPeriods {
//    static var Accelerometer: Double = 1000
//    static var AmbientLight: Double = 6000
//    static var AmbientPressure: Double = 6000
//    static var DeviceUsage: Double = 0
//    static var KeyboardMetrics: Double = 0
//    static var MedaiEvents: Double = 0
//    static var MessageUsage: Double = 0
//    static var OnWrist: Double = 0
//    static var Pedometer: Double = 0
//    static var PhoneUsage: Double = 0
//    static var RotationRate: Double = 1000
//    static var TelephonySpeechMetrics: Double = 0
//    static var Visit: Double = 0
//    static var SiriSpeechMetrics: Double = 0
//    static var FaceMetrics: Double = 0
//    static var HeartRate: Double = 1000
//    static var WristTemperature: Double = 0
//    static let Odometer: Double = 0
//}


//struct PeriodsConfig {
//    static let Accelerometer: Double = 1000
//    static let AmbientLight: Double = 6000
//    static let AmbientPressure: Double = 6000
//    static let DeviceUsage: Double = 0
//    static let KeyboardMetrics: Double = 0
//    static let MedaiEvents: Double = 0
//    static let MessageUsage: Double = 0
//    static let OnWrist: Double = 0
//    static let Pedometer: Double = 0
//    static let PhoneUsage: Double = 0
//    static let RotationRate: Double = 1000
//    static let TelephonySpeechMetrics: Double = 0
//    static let Visit: Double = 0
//    static let SiriSpeechMetrics: Double = 0
//    static let FaceMetrics: Double = 0
//    static let HeartRate: Double = 1000
//    static let WristTemperature: Double = 0
//    static let Odometer: Double = 0
//}



// TODO remove default settings
struct RadarbaseConfig {
    static var baseUrl = "https://radar-dev.connectdigitalstudy.com/"
    static var kafkaEndpoint = "kafka/topics/"
    static var schemaEndpoint = "/schema/subjects/"
}

struct UserConfig {
    static var token = "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOlsicmVzX2FwcGNvbmZpZyIsInJlc19BcHBTZXJ2ZXIiLCJyZXNfZ2F0ZXdheSIsInJlc19NYW5hZ2VtZW50UG9ydGFsIl0sInN1YiI6Ijk2OWI5OTI5LTExNTktNDMyMS04YzM1LTFjZDM0ZjkzNGU4NyIsInNvdXJjZXMiOlsiOWMxMmI5MzItNDI5ZC00OWI2LWE0OTQtNDUzZGFlZjc0NDRmIl0sImdyYW50X3R5cGUiOiJhdXRob3JpemF0aW9uX2NvZGUiLCJ1c2VyX25hbWUiOiI5NjliOTkyOS0xMTU5LTQzMjEtOGMzNS0xY2QzNGY5MzRlODciLCJyb2xlcyI6WyJTVEFHSU5HX1BST0pFQ1Q6Uk9MRV9QQVJUSUNJUEFOVCJdLCJzY29wZSI6WyJNRUFTVVJFTUVOVC5DUkVBVEUiLCJTVUJKRUNULlJFQUQiLCJTVUJKRUNULlVQREFURSJdLCJpc3MiOiJNYW5hZ2VtZW50UG9ydGFsIiwiZXhwIjoxNzAwNDUzNDQ2LCJpYXQiOjE3MDA0MTAyNDYsImF1dGhvcml0aWVzIjpbIlJPTEVfUEFSVElDSVBBTlQiXSwiY2xpZW50X2lkIjoiYVJNVCJ9.Kjcl1WtqmnZc6cQcCFjR81tr8XUhm8EBKKt_w5ftxeOxxV2fpdRpkORkkj_a7qeIovUR_QGg5z9-S57UpdWjFw"
    static var projectId = ["string": "STAGING_PROJECT"]
    static var userId = "969b9929-1159-4321-8c35-1cd34f934e87"
    static var sourceId: String? = "c032209c-b44a-45d5-b5a8-d45fef68a63e"
}

//struct Constants {
//    static let TOPIC_NAME: [String : String] = [
//        "accelerometer": "sensorkit_acceleration",
//        "ambientLightSensor": "sensorkit_ambient_light",
//        "ambientPressure": "sensorkit_ambient_pressure",
//        "deviceUsageReport": "sensorkit_device_usage",
//        "keyboardMetrics": "sensorkit_keyboard_metrics",
//        "mediaEvents": "sensorkit_media_events",
//        "messagesUsageReport": "sensorkit_message_usage",
//        "onWristState": "sensorkit_on_wrist",
//        "pedometerData": "sensorkit_pedometer",
//        "phoneUsageReport": "sensorkit_phone_usage",
//        "rotationRate": "sensorkit_rotation_rate",
//        "siriSpeechMetrics": "",
//        "telephonySpeechMetrics": "sensorkit_telephony_speech_metrics",
//        "visits": "sensorkit_visits",
//        "magneticField": "apple_ios_magnetic_field",
//    ]
//
//    static let DEFAULT_PERIOD: [String : Double] = [
//        "accelerometer": 20,
//        "ambientLightSensor": 60000,
//        "deviceUsageReport": 0,
//        "keyboardMetrics": 0,
//        "messagesUsageReport": 0,
//        "onWristState": 0,
//        "pedometerData": 0,
//        "phoneUsageReport": 0,
//        "rotationRate": 20,
//        "visits": 0,
//        "ambientPressure": 60000,
//        "mediaEvents": 0,
//        "siriSpeechMetrics": 0,
//        "telephonySpeechMetrics": 0,
//        "magneticField": 100,
//    ]
//    static let DEFAULT_CHUNK_SIZE = 10000
//    static let APP_NAME = "RADAR-base Sesnsorkit Plugin"
//    static let APP_SHORT_NAME = "RbSensorkitPlugin"
//}
//
//struct Config {
//    static var token = ""
//    static var baseUrl = ""
//    static var kafkaEndpoint = ""
//    static var schemaEndpoint = ""
//    static var projectId = ""
//    static var userId = ""
//    static var sourceId = ""
//}

enum PostToKafkaError: Error {
    case runtimeError(String)
}

enum TopicKeyValue: String {
    case KEY = "key"
    case VALUE = "value"
}

