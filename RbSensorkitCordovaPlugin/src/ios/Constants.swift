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
    static var schemaStr: Dictionary<String, String> = [
        "accelerometer": "{\"type\":\"record\",\"name\":\"SensorKitAcceleration\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data from 3-axis accelerometer sensor with gravitational constant g as unit.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"x\",\"type\":\"float\",\"doc\":\"Acceleration in the x-axis (g).\"},{\"name\":\"y\",\"type\":\"float\",\"doc\":\"Acceleration in the y-axis (g).\"},{\"name\":\"z\",\"type\":\"float\",\"doc\":\"Acceleration in the z-axis (g).\"}]}",
        "ambientLightSensor": "{\"type\":\"record\",\"name\":\"SensorKitAmbientLight\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data describes the amount of ambient light in the user’s environment.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"chromaticityX\",\"type\":\"float\",\"doc\":\"x-value of the coordinate pair that describes the light brightness and tint.\"},{\"name\":\"chromaticityY\",\"type\":\"float\",\"doc\":\"y-value of the coordinate pair that describes the light brightness and tint.\"},{\"name\":\"lux\",\"type\":\"float\",\"doc\":\"Illuminance (lx).\"},{\"name\":\"placement\",\"type\":{\"type\":\"enum\",\"name\":\"SensorPlacement\",\"doc\":\"Directional values that describe light-source location with respect to the sensor.\",\"symbols\":[\"FRONT_BOTTOM\",\"FRONT_BOTTOM_LEFT\",\"FRONT_BOTTOM_RIGHT\",\"FRONT_LEFT\",\"FRONT_RIGHT\",\"FRONT_TOP\",\"FRONT_TOP_LEFT\",\"FRONT_TOP_RIGHT\",\"UNKNOWN\"]},\"doc\":\"The light’s location relative to the sensor.\",\"default\":\"UNKNOWN\"}]}",
        "ambientPressure": "{\"type\":\"record\",\"name\":\"SensorKitAmbientPressure\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"A measurement of the ambient pressure and temperature.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"pressure\",\"type\":\"double\",\"doc\":\"The ambient pressure (Pascal).\"},{\"name\":\"temperature\",\"type\":\"double\",\"doc\":\"The temperature (Celsius).\"}]}",
        "deviceUsageReport": "{\"type\":\"record\",\"name\":\"SensorKitDeviceUsage\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Describes the frequency and relative duration that the user uses their device, particular Apple apps, or websites.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"duration\",\"type\":\"double\",\"doc\":\"The duration that the report spans (s).\"},{\"name\":\"totalScreenWakes\",\"type\":\"int\",\"doc\":\"The total number of screen wakes for the device.\"},{\"name\":\"totalUnlocks\",\"type\":\"int\",\"doc\":\"The total number of unlocks for the device.\"},{\"name\":\"totalUnlockDuration\",\"type\":\"double\",\"doc\":\" The duration of time the device is in an unlocked state (s).\"},{\"name\":\"version\",\"type\":\"string\",\"doc\":\"Version\"},{\"name\":\"applicationUsageByCategory\",\"type\":\"string\",\"doc\":\"The usage time of apps per category.\"},{\"name\":\"notificationUsageByCategory\",\"type\":\"string\",\"doc\":\"The frequency of notifications per category.\"},{\"name\":\"webUsageByCategory\",\"type\":\"string\",\"doc\":\"The amount of time the user accesses domains per category.\"}]}",
        "faceMetrics": "",
        "heartRate": "",
        "keyboardMetrics": "{\"type\":\"record\",\"name\":\"SensorKitKeyboardMetrics\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data that describes the configuration of a device’s keyboard and its usage patterns.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"totalWords\",\"type\":\"int\",\"doc\":\"The total number of typed words for the keyboard.\"},{\"name\":\"totalAlteredWords\",\"type\":\"int\",\"doc\":\"The total number of altered words for the keyboard.\"},{\"name\":\"totalTaps\",\"type\":\"int\",\"doc\":\"The total number of taps for the keyboard.\"},{\"name\":\"totalEmojis\",\"type\":\"int\",\"doc\":\"The total number of emojis for the keyboard.\"},{\"name\":\"totalTypingDuration\",\"type\":\"double\",\"doc\":\"The total amount of typing time for the keyboard.\"},{\"name\":\"totalPauses\",\"type\":\"int\",\"doc\":\"The total number of pauses during the session.\"},{\"name\":\"totalTypingEpisodes\",\"type\":\"int\",\"doc\":\"The total number of continuous typing episodes during the session.\"}]}",
        "mediaEvents": "",
        "messagesUsageReport": "{\"type\":\"record\",\"name\":\"SensorKitMessageUsage\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data that describes the user’s Messages app activity over a period of time.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"duration\",\"type\":\"double\",\"doc\":\"The duration that the report spans (s).\"},{\"name\":\"totalIncomingMessages\",\"type\":\"int\",\"doc\":\"The number of messages the user receives.\"},{\"name\":\"totalOutgoingMessages\",\"type\":\"int\",\"doc\":\"The number of messages the user sends.\"},{\"name\":\"totalUniqueContacts\",\"type\":\"int\",\"doc\":\"The user’s number of contacts.\"}]}",
        "odometer": "",
        "onWristState": "{\"type\":\"record\",\"name\":\"SensorKitOnWrist\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data about the configuration of a watch on the wearer’s wrist.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"crownOrientation\",\"type\":{\"type\":\"enum\",\"name\":\"CrownOrientation\",\"doc\":\"Directions the Digital Crown can face with respect to the wearer.\",\"symbols\":[\"LEFT\",\"RIGHT\"]},\"doc\":\"A value that indicates the direction the Digital Crown faces with respect to the wearer.\"},{\"name\":\"onWrist\",\"type\":\"boolean\",\"doc\":\"A value that indicates whether the watch is on the user’s wrist.\"},{\"name\":\"wristLocation\",\"type\":{\"type\":\"enum\",\"name\":\"WristLocation\",\"doc\":\"Preferences for where a user wears a watch.\",\"symbols\":[\"LEFT\",\"RIGHT\"]},\"doc\":\"A value that indicates the wrist where the user wears the watch.\"},{\"name\":\"offWristDate\",\"type\":\"double\",\"doc\":\"Off Wrist Date timestamp in UTC (s).\"},{\"name\":\"onWristDate\",\"type\":\"double\",\"doc\":\"On Wrist Date timestamp in UTC (s).\"}]}",
        "pedometerData": "{\"type\":\"record\",\"name\":\"SensorKitPedometer\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data about the distance traveled by a user on foot.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"startDate\",\"type\":\"double\",\"doc\":\"The start time for the pedometer data timestamp in UTC (s).\"},{\"name\":\"endDate\",\"type\":\"double\",\"doc\":\"The end time for the pedometer data timestamp in UTC (s).\"},{\"name\":\"numberOfSteps\",\"type\":\"int\",\"doc\":\"Number of steps taken between this and the previous record.\"},{\"name\":\"distance\",\"type\":\"double\",\"doc\":\"The estimated distance (in meters) traveled by the user.\"},{\"name\":\"averageActivePace\",\"type\":\"double\",\"doc\":\"The average pace of the user, measured in seconds per meter.\"},{\"name\":\"currentPace\",\"type\":\"double\",\"doc\":\"The current pace of the user, measured in seconds per meter.\"},{\"name\":\"currentCadence\",\"type\":\"double\",\"doc\":\"The rate at which steps are taken, measured in steps per second.\"},{\"name\":\"floorsAscended\",\"type\":\"int\",\"doc\":\"The approximate number of floors ascended by walking.\"},{\"name\":\"floorsDescended\",\"type\":\"int\",\"doc\":\"The approximate number of floors descended by walking.\"}]}",
        "phoneUsageReport": "{\"type\":\"record\",\"name\":\"SensorKitPhoneUsage\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data that describes the user’s phone activity over a period of time.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"duration\",\"type\":\"double\",\"doc\":\"The duration that the report spans (s).\"},{\"name\":\"totalIncomingCalls\",\"type\":\"int\",\"doc\":\"The number of calls the user receives.\"},{\"name\":\"totalOutgoingCalls\",\"type\":\"int\",\"doc\":\"The number of calls the user makes.\"},{\"name\":\"totalPhoneCallDuration\",\"type\":\"double\",\"doc\":\"The total duration of all calls. (s)\"},{\"name\":\"totalUniqueContacts\",\"type\":\"int\",\"doc\":\"The user’s number of contacts.\"}]}",
        "rotationRate": "{\"type\":\"record\",\"name\":\"SensorKitRotationRate\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Data from the 3-axis gyroscope sensor (rotation-rate).\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"x\",\"type\":\"float\",\"doc\":\"Gyration in the x-axis (rad/s).\"},{\"name\":\"y\",\"type\":\"float\",\"doc\":\"Gyration in the y-axis (rad/s).\"},{\"name\":\"z\",\"type\":\"float\",\"doc\":\"Gyration in the z-axis (rad/s).\"}]}",
        "siriSpeechMetrics": "",
        "telephonySpeechMetrics": "{\"type\":\"record\",\"name\":\"SensorKitTelephonySpeechMetrics\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"Describes the metrics about a range of speech.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"audioLevelStart\",\"type\":[\"null\",\"double\"],\"doc\":\"The start time of the time range in the audio stream that the level applies to, in seconds relative to time (s).\"},{\"name\":\"audioLevelDuration\",\"type\":[\"null\",\"double\"],\"doc\":\"The duration of the time range in the audio stream that the level applies to (s).\"},{\"name\":\"audioLevelLoudness\",\"type\":[\"null\",\"double\"],\"doc\":\"The measure of the audio level in decibels.\"},{\"name\":\"soundClassificationStart\",\"type\":[\"null\",\"double\"],\"doc\":\"The start time of the time span that corresponds to the result’s classifications, in seconds relative to time (s).\"},{\"name\":\"soundClassificationDuration\",\"type\":[\"null\",\"double\"],\"doc\":\"The duration of the time span that corresponds to the result’s classifications (s).\"},{\"name\":\"soundClassification\",\"type\":[\"null\",\"string\"],\"doc\":\"The confidence value the model has in its prediction.\"},{\"name\":\"speechExpressionStart\",\"type\":[\"null\",\"double\"],\"doc\":\"The start time of the time range in the audio stream that the metrics and analytics apply to, in seconds relative to time (s).\"},{\"name\":\"speechExpressionDuration\",\"type\":[\"null\",\"double\"],\"doc\":\"The duration of the time range in the audio stream that the metrics and analytics apply to (s).\"},{\"name\":\"speechExpressionActivation\",\"type\":[\"null\",\"double\"],\"doc\":\"The level of energy or activation of the speaker.\"},{\"name\":\"speechExpressionConfidence\",\"type\":[\"null\",\"double\"],\"doc\":\"The level of confidence of the speaker.\"},{\"name\":\"speechExpressionDominance\",\"type\":[\"null\",\"double\"],\"doc\":\"The degree of how strong or meek the speaker sounds.\"},{\"name\":\"speechExpressionMood\",\"type\":[\"null\",\"double\"],\"doc\":\"An indication of how slurry, tired, or exhausted the speaker sounds compared to normal speech.\"},{\"name\":\"speechExpressionValence\",\"type\":[\"null\",\"double\"],\"doc\":\"The degree of positive or negative emotion or sentiment of the speaker.\"}]}",
        "visits": "{\"type\":\"record\",\"name\":\"SensorKitVisits\",\"namespace\":\"org.radarcns.passive.apple.sensorkit\",\"doc\":\"The user’s progress in their daily travel routine.\",\"fields\":[{\"name\":\"time\",\"type\":\"double\",\"doc\":\"Device timestamp in UTC (s).\"},{\"name\":\"timeReceived\",\"type\":\"double\",\"doc\":\"Device receiver timestamp in UTC (s).\"},{\"name\":\"device\",\"type\":\"string\",\"doc\":\"Device model.\"},{\"name\":\"identifier\",\"type\":\"string\",\"doc\":\"A value that maps to a unique geographic location.\"},{\"name\":\"arrivalDateIntervalStart\",\"type\":\"double\",\"doc\":\"The start date of a range of time within which the user arrives at a location of interest timestamp in UTC (s).\"},{\"name\":\"arrivalDateIntervalEnd\",\"type\":\"double\",\"doc\":\"The end date of a range of time within which the user arrives at a location of interest timestamp in UTC (s).\"},{\"name\":\"arrivalDateIntervalDuration\",\"type\":\"double\",\"doc\":\"The duration of a range of time within which the user arrives at a location of interest (s).\"},{\"name\":\"departureDateIntervalStart\",\"type\":\"double\",\"doc\":\"The start date of a range of time within which the user departs from a location of interest timestamp in UTC (s).\"},{\"name\":\"departureDateIntervalEnd\",\"type\":\"double\",\"doc\":\"The end date of a range of time within which the user departs from a location of interest timestamp in UTC (s).\"},{\"name\":\"departureDateIntervalDuration\",\"type\":\"double\",\"doc\":\"The duration of a range of time within which the user departs from a location of interest (s).\"},{\"name\":\"distanceFromHome\",\"type\":\"double\",\"doc\":\"The location’s distance from the home-category location.\"},{\"name\":\"locationCategory\",\"type\":{\"type\":\"enum\",\"name\":\"LocationCategory\",\"doc\":\"Types of locations.\",\"symbols\":[\"GYM\",\"HOME\",\"SCHOOL\",\"WORK\",\"UNKNOWN\"]},\"doc\":\"The location’s type.\",\"default\":\"UNKNOWN\"}]}",
        "wristTemperature": "",
        "magneticField": "",
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
