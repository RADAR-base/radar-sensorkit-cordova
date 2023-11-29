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
#### Important: In App Targets/Signing and Capabilities add Background Modes capability and enable Background processing

- Set RADAR-base configuration
- Check cache status
- Upload all files in the cache
- Get the list of available sensors
- Check authorization status and request authorization
- Enable sensors to collect data (with sensor name, topic, period)
- After 24 hours data will be available
- Fetch data
- 
- Stop recording for sensors if needed
- Clear cache on logout

## Methods

### isSensorKitAvailable()

```
RbSensorkitCordovaPlugin.isSensorKitAvailable(successCallback, errorCallback)
```

- successCallback: {type: function(res: boolean)}, true = available, false = not-available
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### getAvailableSensors()
```
RbSensorkitCordovaPlugin.getAvailableSensors(successCallback, errorCallback)
```
- successCallback: {type: function(res: string[])}, list of available sensors
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### setConfig(configs: Config)

```
RbSensorkitCordovaPlugin.setConfig([configs], successCallback, errorCallback)
```
- configs: {type: Config}:
  const configs = {
  token: string,
  baseUrl: string,
  kafkaEndpoint?: string,
  schemaEndpoint?: string,
  projectId: string,
  userId: string,
  sourceId?: string
  }

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

### selectSensors(sensorsArray: SensorConfig[])
- sensorsArray: {type :SensorConfig[]}: {sensor: string, topic?: string, period?: number, chunkSize?: number}[]

- successCallback: {type: function()}
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

```
RbSensorkitCordovaPlugin.selectSensor(sensorsArray, successCallback, errorCallback)
```

### checkAuthorization(sensorArray: string[])

```
RbSensorkitCordovaPlugin.checkAuthorization(sensorArray, successCallback, errorCallback)
```
- sensorsArray: {type :string[]}

- successCallback: {type: function(res: {"results":{"sensorName":"AUTHORIZED|DENIED|NOT_DETERMINED"}[]}) called in success
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### authorize()

```
RbSensorkitCordovaPlugin.authorize(sensorArray, successCallback, errorCallback)
```
- sensorsArray: {type :string[]}

- successCallback: {type: function(res: {"results":{"sensorName":"AUTHORIZED|DENIED|NOT_DETERMINED"}[]}) called in success
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### stopRecording()

```
RbSensorkitCordovaPlugin.stopRecording(sensorsArray, successCallback, errorCallback)
```
- sensorsArray: {type :string[]}

- successCallback: {type: function()}, called in success
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
### getCacheStatus()

```
RbSensorkitCordovaPlugin.getCacheStatus(successCallback, errorCallback)
```

- successCallback: {type: function(res: number)}, number of files are in the cache
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### clearCache()

```
RbSensorkitCordovaPlugin.clearCache(successCallback, errorCallback)
```

- successCallback: {type: function()}, all files are successfully deleted.
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

### uploadCache()

```
RbSensorkitCordovaPlugin.uploadCache(successCallback, errorCallback)
```

- successCallback: {type: function()}
- errorCallback: {type: function(err)}, called if something went wrong, err contains a textual description of the problem

## External resources

* The official Apple documentation for SensorKit [here](https://developer.apple.com/documentation/sensorkit).
* Configuring your project for sensor reading (How to create entitlement file and modify info.plist) [here](https://developer.apple.com/documentation/sensorkit/configuring_your_project_for_sensor_reading).
* **NOTE** SensorKit places a 24-hour holding period on newly recorded data before an app can access it. This gives the user an opportunity to delete any data they don’t want to share with the app. A fetch request doesn’t return any results if its time range overlaps this holding period.
* SensorKit sample types [here](https://developer.apple.com/documentation/sensorkit/srfetchresult/3377648-sample#3682718)
