# RADAR-base Sensorkit Cordova Plugin

This plugin integrates Apple Sensorkit with RADAR-base platform. It fetches a sensor data and directly send it to RADAR-base.

## Installation

In Cordova:

```
cordova plugin add ../RbSensorkitCordovaPlugin/'
```

## iOS requirements

* Make sure your app id has the 'Sensorkit' entitlement when this plugin is installed (see iOS dev center).
* Sensorkit works for iOS 14 and above. Some sensors work only on newer versions
## Usage
### Call methods in sequence
- Check if sensor is available
- Set RADAR-base configuration
- Select sensor (with sensor name, topic, period)
- Check authorization status and request authorization
- Initialise sensor
- Start recording
- After 24 hours data will be available
- Fetch devices
- Fetch data
## Methods

### isSensorKitAvailable()

```
RbSensorkitCordovaPlugin.isSensorKitAvailable(successCallback, errorCallback)
```

- successCallback: {type: function(res: boolean)}, true = available, false = not-available
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### isSensorAvailable(sensor: String)

```
RbSensorkitCordovaPlugin.isSensorAvailable(sensor: string, successCallback, errorCallback)
```
- sensor: {type :string}: valid sensor strings: accelerometer, ambientLightSensor, ambientPressure, deviceUsageReport, keyboardMetrics, mediaEvents, messagesUsageReport, onWristState, pedometerData, phoneUsageReport, rotationRate, siriSpeechMetrics, telephonySpeechMetrics, visits

- successCallback: {type: function(res: boolean)}, true = available, false = not-available
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### setConfig(configArray: string[])

```
RbSensorkitCordovaPlugin.setConfig(configArray, successCallback, errorCallback)
```
- configArray: {type: string[]}: [token: string, baseUrl: string, kafkaEndpoint: string, schemaEndpoint: string, projectId: string, userId: string, sourceId: string] 
  - token: The access token from RADAR-base,
  - baseUrl: RADAR-base instance BaseUrl **[Note: add trailing slash]** (e.g. `https://your-domain-name.com/`),
  - projectId: Project ID from RADAR-base ManagementPortal,
  - userId: Subject ID from RADAR-base ManagementPortal,
  - sourceId: Source ID from RADAR-base ManagementPortal or empty string
    - Default: Empty string
  - kafkaEndpoint: RADAR-base kafka endpoint **[Note: add trailing slash]** (e.g. `kafka/topics/`)
    - Default: `kafka/topics/` 
  - schemaEndpoint: RADAR-base schema endpoint **[Note: add trailing slash]** (e.g. `schema/subjects/`)
      - Default: `schema/subjects/`

- successCallback: {type: function()}, called in success
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### selectSensor(sensorParams: string[])
- sensorParams: {type :string[]}: [name: name, topic: topic, period: period, chunkSize: chunkSize}]valid sensor strings: accelerometer, ambientLightSensor, ambientPressure, deviceUsageReport, keyboardMetrics, mediaEvents, messagesUsageReport, onWristState, pedometerData, phoneUsageReport, rotationRate, siriSpeechMetrics, telephonySpeechMetrics, visits

- successCallback: {type: function()}
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

```
RbSensorkitCordovaPlugin.selectSensor(sensor, successCallback, errorCallback)
```

- successCallback: {type: function()}, called in success
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### checkAuthorization()

```
RbSensorkitCordovaPlugin.checkAuthorization(successCallback, errorCallback)
```

- successCallback: {type: function(res: string)}, called in success
  - res: 'NOT_DETERMINED', 'AUTHORIZED', 'DENIED'
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### authorize()

```
RbSensorkitCordovaPlugin.authorize(successCallback, errorCallback)
```
- successCallback: {type: function(res: string)}, called in success
    - res: 'NOT_DETERMINED', 'AUTHORIZED', 'DENIED'
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### initialiseSensor()

```
RbSensorkitCordovaPlugin.initialiseSensor(successCallback, errorCallback)
```

- successCallback: {type: function()}, called in success
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### startRecording()

```
RbSensorkitCordovaPlugin.startRecording(successCallback, errorCallback)
```

- successCallback: {type: function()}, called in success
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### stopRecording()

```
RbSensorkitCordovaPlugin.stopRecording(successCallback, errorCallback)
```

- successCallback: {type: function()}, called in success
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### fetchDevices()

```
RbSensorkitCordovaPlugin.fetchDevices(successCallback, errorCallback)
```

- successCallback: {type: function(res: {devices: Device[]})}, called in success
```
interface Device {
    "name": string; // device name e.g. "My iPhone"
    "model": string; // device model e.g. @"iPhone"
    "systemName": string; // device system name e.g. @"iOS"
    "systemVersion": string; // device system version
}
```
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### fetchData(requestParamsArray: string[])
```
RbSensorkitCordovaPlugin.fetchData(requestParamsArray, successCallback, errorCallback)
```
- requestParamsArray: {type: string[]}: [startDate: string, endDate: string, deviceName: string]
  - startDate: The request start date in ISO Dates (Date-Time) `YYYY-MM-DDTHH:MM:SS` e.g. `2023-07-28T10:00:00`
  - endDate: The request end date in ISO Dates (Date-Time) `YYYY-MM-DDTHH:MM:SS` e.g. `2023-07-28T10:00:00`
  - deviceName: Name (property `name`) of the device from the list of devices fetched by `fetchDevices`
    - Default: Current device

- successCallback: {type: function(res: {devices: Devices[]})}, called in success
```
interface ChunkSentResponse {
    "progress": number; // Number of sent chunk
    "total": number; // totla number of chunks
    "start": number; // timestamp in seconds of first record in this chunk
    "end": number; // timestamp in seconds of first record in this chunk
    "recordCount": number; // Number of records in this chunk
}
```
    
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem
```
interface ChunkSentError {
    "progress": number; // Number of sent chunk
    "total": number; // totla number of chunks
    "start": number; // timestamp in seconds of first record in this chunk
    "end": number; // timestamp in seconds of first record in this chunk
    "recordCount": number; // Number of records in this chunk
    "error_description": string;
    "error_message": string;
}
```

## External resources

* The official Apple documentation for SensorKit [here](https://developer.apple.com/documentation/sensorkit).
* Configuring your project for sensor reading (How to create entitlement file and modify info.plist) [here](https://developer.apple.com/documentation/sensorkit/configuring_your_project_for_sensor_reading).
* **NOTE** SensorKit places a 24-hour holding period on newly recorded data before an app can access it. This gives the user an opportunity to delete any data they don’t want to share with the app. A fetch request doesn’t return any results if its time range overlaps this holding period.
* SensorKit sample types [here](https://developer.apple.com/documentation/sensorkit/srfetchresult/3377648-sample#3682718)
