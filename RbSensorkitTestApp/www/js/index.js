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
    token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOlsicmVzX2FwcGNvbmZpZyIsInJlc19BcHBTZXJ2ZXIiLCJyZXNfZ2F0ZXdheSIsInJlc19NYW5hZ2VtZW50UG9ydGFsIl0sInN1YiI6Ijk2OWI5OTI5LTExNTktNDMyMS04YzM1LTFjZDM0ZjkzNGU4NyIsInNvdXJjZXMiOlsiOWMxMmI5MzItNDI5ZC00OWI2LWE0OTQtNDUzZGFlZjc0NDRmIl0sImdyYW50X3R5cGUiOiJhdXRob3JpemF0aW9uX2NvZGUiLCJ1c2VyX25hbWUiOiI5NjliOTkyOS0xMTU5LTQzMjEtOGMzNS0xY2QzNGY5MzRlODciLCJyb2xlcyI6WyJTVEFHSU5HX1BST0pFQ1Q6Uk9MRV9QQVJUSUNJUEFOVCJdLCJzY29wZSI6WyJNRUFTVVJFTUVOVC5DUkVBVEUiLCJTVUJKRUNULlJFQUQiLCJTVUJKRUNULlVQREFURSJdLCJpc3MiOiJNYW5hZ2VtZW50UG9ydGFsIiwiZXhwIjoxNjk0NzM3NTYyLCJpYXQiOjE2OTQ2OTQzNjIsImF1dGhvcml0aWVzIjpbIlJPTEVfUEFSVElDSVBBTlQiXSwiY2xpZW50X2lkIjoiYVJNVCJ9.CV52Ag6DlWdLs0aE0R-iszqVcLgIuhRIM7TbGQbxM3_XZPTgr2wZkMNMgBKpOlYULjhoruHEDjqI8hKgkHsIyQ",
    baseUrl: "https://radar-dev.connectdigitalstudy.com/",
    kafkaEndpoint: "kafka/topics/",
    schemaEndpoint: "schema/subjects/",
    projectId: "STAGING_PROJECT",
    userId: "969b9929-1159-4321-8c35-1cd34f934e87",
    sourceId: "c032209c-b44a-45d5-b5a8-d45fef68a63e",
}

async function onDeviceReady() {

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');

    try {
        const res = await setConfig(config)
        console.log("[JS] Config is set", res);
    } catch (e) {
        console.log("[JS] Config is NOT set", e)
    }

    // try {
    //     const res = await selectMagneticFieldSensor({topic: "apple_ios_magnetic_field", period: 100, chunkSize: 100})
    //     document.getElementById('sensor').innerHTML = "Magnetic Field";
    //     console.log("[JS] Sensor Magnetic Field is selected", res);
    // } catch (e) {
    //     document.getElementById('sensor').innerHTML = "Sensor Magnetic Field is NOT selected (" + e + ")";
    //     console.log("[JS] Sensor Magnetic Field is NOT selected", e);
    // }
    //
    // await sleep(1000)
    //
    // fetchMagneticFieldData();

    // await sleep(60000);

    // await stopUpdateMagneticField();



    //return;

    isSensorkitAvailable();
    isSensorAvailable("accelerometer");
    isSensorAvailable("invalid_sensor");

    try {
        const res = await setConfig(config)
        console.log("[JS] Config is set", res);
    } catch (e) {
        console.log("[JS] Config is NOT set", e)
    }

    // await sleep(1000)
    /**********************************/
    const sensors = ["accelerometer", "ambientLightSensor", "ambientPressure", "deviceUsageReport", "keyboardMetrics", "mediaEvents", "messagesUsageReport", "onWristState", "pedometerData", "phoneUsageReport", "rotationRate", "siriSpeechMetrics", "telephonySpeechMetrics", "visits"]
    try {
        const res = await authorize(sensors)
        console.log("[JS] Authorize", res);
    } catch (e) {
        console.log("[JS] Authorize Error", e);
    }
    /**********************************/
    const startDate = "2023-11-02T10:00:00";
    const endDate = "2023-11-07T20:00:00";

    // await runSensor("onWristState", "sensorkit_on_wrist", 0, 10000, startDate, endDate, 0); //'iPhone')
    //
    // await sleep(20000);
    //
    // await runSensor("ambientLightSensor", "sensorkit_ambient_light", 60000, 10000, startDate, endDate, 0);//'iPhone')
    //
    // await sleep(20000)
    //
    // await runSensor("ambientLightSensor", "sensorkit_ambient_light", 60000, 10000, startDate, endDate, 1);//'iPhone')
    //
    // await sleep(20000)
    //
    // await runSensor("phoneUsageReport", "sensorkit_phone_usage", 0, 10000, startDate, endDate, 0); //'iPhone')
    //
    // await sleep(20000)
    await runSensor("telephonySpeechMetrics", "sensorkit_telephony_speech_metrics", 0, 10000, startDate, endDate, 0); //'iPhone')

    await sleep(20000)

    // await runSensor("ambientPressure", "sensorkit_ambient_pressure", 0, 10000, startDate, endDate, 0); //'iPhone')
    //
    // await sleep(20000)

    // await runSensor("pedometerData", "sensorkit_pedometer", 0, 10000, startDate, endDate, 0); //'iPhone')
    //
    // await sleep(20000)
    //
    // await runSensor("pedometerData", "sensorkit_pedometer", 0, 10000, startDate, endDate, 1); //'Apple Watch')
    //
    // await sleep(20000)
    // //
    // await runSensor("pedometerData", "sensorkit_pedometer", 0, 10000, startDate, endDate, 0); //'iPhone')
    //
    // await sleep(20000)




    // await runSensor("onWristState", "sensorkit_on_wrist", 0, 10000, '2023-09-01T10:00:00', '2023-09-11T10:00:00', 'iPhone')

    // await sleep(20000)

    // await runSensor("visits", "sensorkit_visits", 0, 10000, '2023-07-28T10:00:00', '2023-08-05T10:00:00', 'iPhone')

    // await sleep(20000)

    // await runSensor("accelerometer", "sensorkit_acceleration", 1000, 10000, '2023-08-23T10:00:00', '2023-08-24T10:00:00', 'iPhone')

    // await sleep(20000)

    // await runSensor("accelerometer", "sensorkit_acceleration", 1000, 10000, '2023-08-24T10:00:00', '2023-08-25T10:00:00', 'iPhone')

}

async function runSensor(name, topic, period, chunkSize, startDate, endDate, deviceNumber) { //deviceName) {
    document.getElementById('result').innerHTML = "";

    // const sensor = {name: "accelerometer", topic: "sensorkit_acceleration", period: 20, chunkSize: 10000};
    // const sensor = {name: "ambientLightSensor", topic: "sensorkit_ambient_light", period: 1000, chunkSize: 10000};
    // const sensor = {name: "ambientPressure", topic: "sensorkit_ambient_pressure", period: 0, chunkSize: 10000};
    // const sensor = {name: "deviceUsageReport", topic: "sensorkit_device_usage", period: 0, chunkSize: 10000};
    // const sensor = {name: "keyboardMetrics", topic: "sensorkit_keyboard_metrics", period: 0, chunkSize: 10000};
    // const sensor = {name: "mediaEvents", topic: "sensorkit_media_events", period: 0, chunkSize: 10000};
    // const sensor = {name: "messagesUsageReport", topic: "sensorkit_message_usage", period: 0, chunkSize: 10000};
    // const sensor = {name: "onWristState", topic: "sensorkit_on_wrist", period: 0, chunkSize: 10000};
    // const sensor = {name: "pedometerData", topic: "sensorkit_pedometer", period: 0, chunkSize: 10000};
    // const sensor = {name: "phoneUsageReport", topic: "sensorkit_phone_usage", period: 0, chunkSize: 10000};
    // const sensor = {name: "rotationRate", topic: "sensorkit_rotation_rate", period: 20, chunkSize: 10000};
    // const sensor = {name: "siriSpeechMetrics", topic: "", period: 0, chunkSize: 10000};
    // const sensor = {name: "telephonySpeechMetrics", topic: "", period: 0, chunkSize: 10000};
    // const sensor = {name: "visits", topic: "sensorkit_visits", period: 0, chunkSize: 10000};
    const sensor = {name: name, topic: topic, period: period, chunkSize: chunkSize};

    try {
        const res = await selectSensor(sensor)
        document.getElementById('sensor').innerHTML = sensor.name;
        console.log("[JS] Sensor " + sensor.name + " is selected", res);
    } catch (e) {
        document.getElementById('sensor').innerHTML = "Sensor " + sensor.name + " is NOT selected (" + e + ")";
        console.log("[JS] Sensor " + sensor.name + " is NOT selected", e);
    }
    // await sleep(1000)
    checkAuthorization()

    // try {
    //     const res = await checkAuthorization()
    //     console.log("[JS] AuthorizationStatus", res);
    //     // // if(res === 'NOT_DETERMINED') {
    //     //     try {
    //     //         const authRes = await authorize()
    //     //         console.log("[JS] Authorize", authRes);
    //     //     } catch (e) {
    //     //         console.log("[JS] Authorize Error", e);
    //     //     }
    //     // // }
    // } catch (e) {
    //     console.log("[JS] AuthorizationStatus Error", e);
    // }

    // await sleep(1000)
    try {
        const res = await startRecording()
        console.log("[JS] Start Recording", res);
    } catch (e) {
        console.log("[JS] Start Recording Error", e);
    }

    // await sleep(1000)
    try {
        const res = await startRecording()
        console.log("[JS] Start Recording2", res);
    } catch (e) {
        console.log("[JS] Start Recording2 Error", e);
    }

    // await sleep(1000)
    try {
        const res = await startRecording()
        console.log("[JS] Start Recording3", res);
    } catch (e) {
        console.log("[JS] Start Recording3 Error", e);
    }

    // await sleep(1000)
    let devices = [];
    try {
        const res = await fetchDevices()
        console.log("[JS] Devices", JSON.stringify(res));
        document.getElementById('device').innerHTML = JSON.stringify(res);
        devices = res['devices'];
    } catch (e) {
        console.log("[JS] Devices Error", e);
        document.getElementById('device').innerHTML = JSON.stringify((e));
        devices = [];
    }
    // await sleep(1000)
    console.log("[JS*****] Device:", devices[deviceNumber].name)
    const requestParams = {
        startDate: startDate,
        endDate: endDate,
        deviceName: devices[deviceNumber].name //deviceName
    }
    fetchData(requestParams)
}

function echo(text){
    function success(msg) {
        console.log("[JS] Echo success", msg);
        document.getElementById('deviceready').querySelector('.received').innerHTML = msg;
    }
    function error(error) {
        console.log("[JS] Echo failed", error);
        document.getElementById('deviceready').innerHTML = '<p class="event received">' + error + '</p>';
    }
    RbSensorkitCordovaPlugin.echo(text, success, error);
}

function isSensorkitAvailable() {
    RbSensorkitCordovaPlugin.isSensorKitAvailable(
        function(msg) { console.log("[JS] SensorKit Available", msg); },
        function(err) { console.log("[JS] SensorKit Error", err); }
    );
}

function isSensorAvailable(sensor) {
    RbSensorkitCordovaPlugin.isSensorAvailable(sensor,
        function(msg) { console.log("[JS] Sensor " + sensor + " Available", msg); },
        function(err) { console.log("[JS] Sensor Error", err); }
    );
}

function setConfig(config) {
    const configArray = [config.token, config.baseUrl, config.projectId, config.userId, config.sourceId, config.kafkaEndpoint, config.schemaEndpoint];
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.setConfig(configArray, resolve, reject)
    })
}

function selectSensor(sensor) {
    const sensorArray = [sensor.name, sensor.topic, sensor.period, sensor.chunkSize];
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.selectSensor(sensorArray, resolve, reject)
    })
}

function selectMagneticFieldSensor(sensor) {
    const sensorArray = [sensor.topic, sensor.period, sensor.chunkSize];
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.selectMagneticFieldSensor(sensorArray, resolve, reject)
    })
}


function checkAuthorization() {
    RbSensorkitCordovaPlugin.checkAuthorization(function(res){
            console.log("[JS] AuthorizationStatus", res);
        },
        function(e){
            console.log("[JS] AuthorizationStatus Error", e);
        }
    )
}

// function checkAuthorization() {
//     return new Promise((resolve, reject) => {
//         RbSensorkitCordovaPlugin.checkAuthorization(resolve, reject)
//     })
// }

function authorize(sensors) {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.authorize(sensors, resolve, reject)
    })
}

function initialiseSensor() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.initialiseSensor(resolve, reject)
    })
}
function fetchDevices() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.fetchDevices(resolve, reject)
    })
}

function fetchData(requestParams) {
    const requestParamsArray = [requestParams.startDate, requestParams.endDate, requestParams.deviceName];
    RbSensorkitCordovaPlugin.fetchData(requestParamsArray,
        function(res){
            console.log("[JS] Data sent", JSON.stringify(res));
            document.getElementById('result').innerHTML = document.getElementById('result').innerHTML + JSON.stringify(res) + '<br>';
        },
        function(e){
            console.log("[JS] Sending failed", JSON.stringify(e));
            document.getElementById('result').innerHTML = document.getElementById('result').innerHTML + JSON.stringify(e) + '<br>';
        }
    )
}

function fetchMagneticFieldData(requestParams) {
    RbSensorkitCordovaPlugin.startMagneticFieldUpdate([],
        function(res){
            console.log("[JS] Data sent", JSON.stringify(res));
            document.getElementById('result').innerHTML = document.getElementById('result').innerHTML + JSON.stringify(res) + '<br>';
        },
        function(e){
            console.log("[JS] Sending failed", JSON.stringify(e));
            document.getElementById('result').innerHTML = document.getElementById('result').innerHTML + JSON.stringify(e) + '<br>';
        }
    )
}


function startRecording() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.startRecording(resolve, reject)
    })
}

function stopRecording() {
    return new Promise((resolve, reject) => {
        RbSensorkitCordovaPlugin.stopRecording(resolve, reject)
    })
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
