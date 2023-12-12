/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

// Wait for the deviceready event before using any of Cordova's device APIs.
// See https://cordova.apache.org/docs/en/latest/cordova/events/events.html#deviceready

document.addEventListener('deviceready', onDeviceReady, false);

const config = {
    token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOlsicmVzX2FwcGNvbmZpZyIsInJlc19BcHBTZXJ2ZXIiLCJyZXNfZ2F0ZXdheSIsInJlc19NYW5hZ2VtZW50UG9ydGFsIl0sInN1YiI6ImRjODI4Mzg2LTcwZDgtNDBiMy04ZGNjLTQyNmVmNDBkMGEyZCIsInNvdXJjZXMiOltdLCJncmFudF90eXBlIjoiYXV0aG9yaXphdGlvbl9jb2RlIiwidXNlcl9uYW1lIjoiZGM4MjgzODYtNzBkOC00MGIzLThkY2MtNDI2ZWY0MGQwYTJkIiwicm9sZXMiOlsidGVzdDpST0xFX1BBUlRJQ0lQQU5UIl0sInNjb3BlIjpbIk1FQVNVUkVNRU5ULkNSRUFURSIsIlNVQkpFQ1QuUkVBRCIsIlNVQkpFQ1QuVVBEQVRFIl0sImlzcyI6Ik1hbmFnZW1lbnRQb3J0YWwiLCJleHAiOjE3MDI0MDgzMDcsImlhdCI6MTcwMjM2NTEwNywiYXV0aG9yaXRpZXMiOlsiUk9MRV9QQVJUSUNJUEFOVCJdLCJjbGllbnRfaWQiOiJhUk1UIn0.rr9E1BGd7MHnsOodCu5W7TMdchB86d1KH5piE8OTCirSiEjPgRsHlTQfsOa9oHMt1iiQfLwJYdDFlgjovNZe-A",
    baseUrl: "https://radar.connectdigitalstudy.com/",
    kafkaEndpoint: "kafka/topics/",
    schemaEndpoint: "schema/subjects/",
    projectId: "test",
    userId: "dc828386-70d8-40b3-8dcc-426ef40d0a2d",
    sourceId: "c032209c-b44a-45d5-b5a8-d45fef68a63e",
}

async function onDeviceReady() {

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');

    await isSensorkitAvailable();

    try {
        const res = await getAvailableSensors()
        console.log("[JS] Available Sensors", JSON.stringify(res));
    } catch (e) {
        console.log("[JS] Available Sensors Error", e);
    }

    try {
        const res = await setConfig(config)
        console.log("[JS] Config is set", res);
    } catch (e) {
        console.log("[JS] Config is NOT set", e)
    }

    try {
        const res = await getCacheStatus()
        console.log("[JS] Cache Status - Number of files:", res);
    } catch (e) {
        console.log("[JS] Cache Status Error", e);
    }

    try {
        const res = await clearCache()
        console.log("[JS] Clear Cache", res);
    } catch (e) {
        console.log("[JS] Clear Cache Error", e);
    }
    // try {
    //     const res = await uploadCache()
    //     console.log("[JS] Upload Cache", res);
    // } catch (e) {
    //     console.log("[JS] Upload Cache Error", e);
    // }
    //
    // return;

    try {
        const sensorArray = ["ambientLightSensor", "accelerometer", "deviceUsageReport","keyboardMetrics","messagesUsageReport","onWristState","pedometerData","phoneUsageReport","visits","ambientPressure"]
        const res = await checkAuthorization(sensorArray)
        console.log("[JS] checkAuthorization", JSON.stringify(res));
    } catch (e) {
        console.log("[JS] checkAuthorization", e);
    }

    try {
        const sensorArray = ["ambientLightSensor", "accelerometer", "deviceUsageReport","keyboardMetrics","messagesUsageReport","onWristState","pedometerData","phoneUsageReport","visits","ambientPressure"]
        const res = await authorize(sensorArray)
        console.log("[JS] Authorize", JSON.stringify(res));
    } catch (e) {
        console.log("[JS] Authorize", e);
    }

    // try {
    //     const sensorArray = ["deviceUsageReport","keyboardMetrics"]
    //     const res = await stopRecording(sensorArray)
    //     console.log("[JS] stopRecording", JSON.stringify(res));
    // } catch (e) {
    //     console.log("[JS] stopRecording", e);
    // }

    // return;

    try {
        const sensorArray = [
            {sensor: "ambientLightSensor", period: 60000, chunkSize: 10000},
            {sensor: "accelerometer", period: 100, chunkSize: 10000},
            {sensor: "deviceUsageReport"},
            {sensor: "keyboardMetrics"},
            {sensor: "messagesUsageReport"},
            {sensor: "onWristState"},
            {sensor: "pedometerData"},
            {sensor: "phoneUsageReport"},
            {sensor: "visits"},
            {sensor: "ambientPressure"},
            {sensor: "telephonySpeechMetrics"}
        ]
        const res = await RbSensorkitCordovaPlugin.selectSensors(sensorArray)
        console.log("[JS] Select Sensor Success");

        await sleep(1000)
    } catch (e) {
        // add bugfender
        console.log("[JS] Error selecting sensors", e);
    }
    // try {
    //     const sensorArray = [
    //         {sensor: "ambientLightSensor", topic: "sk_amb_light", period: 6000},
    //         {sensor: "accelerometer", period: 200},
    //         // {sensor: "deviceUsageReport"},
    //         // {sensor: "keyboardMetrics"},
    //         {sensor: "messagesUsageReport"},
    //         {sensor: "onWristState"},
    //         {sensor: "pedometerData"},
    //         {sensor: "phoneUsageReport"},
    //         {sensor: "visits"},
    //         {sensor: "ambientPressure"},
    //         {sensor: "telephonySpeechMetrics"}
    //     ]
    //     const res = await selectSensors(sensorArray)
    //     console.log("[JS] Select Sensor Success");
    // } catch (e) {
    //     console.log("[JS] Select Sensors Error", e);
    // }

    // return;

    try {
        const res = await startFetchingAll()
        console.log("[JS] startFetchingAll", res);
    } catch (e) {
        console.log("[JS] startFetchingAll", e);
    }

    return;

    try {
        const res = await selectMagneticFieldSensor({topic: "apple_ios_magnetic_field", period: 100, chunkSize: 100})
        console.log("[JS] Sensor Magnetic Field is selected", res);
    } catch (e) {
        console.log("[JS] Sensor Magnetic Field is NOT selected", e);
    }

    await sleep(1000)

    fetchMagneticFieldData();

    await sleep(60000);

    await stopUpdateMagneticField();

    await sleep(1000)
}

function isSensorkitAvailable() {
    RbSensorkitCordovaPlugin.isSensorKitAvailable(
        function(msg) { console.log("[JS] SensorKit Available", msg); },
        function(err) { console.log("[JS] SensorKit Error", err); }
    );
}

function getAvailableSensors() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.getAvailableSensors(resolve, reject)
    })
}

function setConfig(configs) {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.setConfig([configs], resolve, reject)
    })
}

function selectSensors(sensorArray) {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.selectSensors(sensorArray, resolve, reject)
    })
}

function authorize(sensors) {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.authorize(sensors, resolve, reject)
    })
}

function checkAuthorization(sensorArray) {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.checkAuthorization(sensorArray, resolve, reject)
    })
}

function stopRecording(sensorArray) {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.stopRecording(sensorArray, resolve, reject)
    })
}

function startFetchingAll() {
    RbSensorkitCordovaPlugin.startFetchingAll(
        function(res){
            console.log("[JS] startFetchingAll", JSON.stringify(res));
        },
        function(e){
            console.log("[JS] startFetchingAll ERROR ", JSON.stringify(e));
        }
    )
}

function getCacheStatus() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.getCacheStatus(resolve, reject)
    })
}

function clearCache() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.clearCache(resolve, reject)
    })
}

function uploadCache() {
    // return new Promise((resolve, reject) => {
    //     RbSensorkitCordovaPlugin.uploadCache(resolve, reject)
    // })

    RbSensorkitCordovaPlugin.uploadCache(
        function(res){
            console.log("[JS] uploadCache", JSON.stringify(res));
        },
        function(e){
            console.log("[JS] uploadCache ERROR ", JSON.stringify(e));
        }
    )
}

function selectMagneticFieldSensor(sensor) {
    const sensorArray = [sensor.topic, sensor.period, sensor.chunkSize];
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.selectMagneticFieldSensor(sensorArray, resolve, reject)
    })
}

function fetchMagneticFieldData(requestParams) {
    RbSensorkitCordovaPlugin.startMagneticFieldUpdate([],
        function(res){
            console.log("[JS] MagneticField Data sent", JSON.stringify(res));
            document.getElementById('result').innerHTML = document.getElementById('result').innerHTML + JSON.stringify(res) + '<br>';
        },
        function(e){
            console.log("[JS] MagneticField failed", JSON.stringify(e));
            document.getElementById('result').innerHTML = document.getElementById('result').innerHTML + JSON.stringify(e) + '<br>';
        }
    )
}

function stopUpdateMagneticField() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.stopMagneticFieldUpdate([],
            function(){
                console.log("[JS] Stop magnetic field");
            },
            function(e){
                console.log("[JS] Error on Stop magnetic field");
            }
        )
    })
}

const sleep = ms => new Promise(res => setTimeout(res, ms));
