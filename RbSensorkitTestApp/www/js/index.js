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
    token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJFUzI1NiJ9.eyJhdWQiOlsicmVzX2FwcGNvbmZpZyIsInJlc19BcHBTZXJ2ZXIiLCJyZXNfZ2F0ZXdheSIsInJlc19NYW5hZ2VtZW50UG9ydGFsIl0sInN1YiI6IjIyMDQyNGE3LTliYTctNDNlMS1hMzkzLWNkZjVkN2Y3MGJkOSIsInNvdXJjZXMiOlsiZTM5MTUxYTgtMWU5Ny00MmEwLTgwNmUtOTNiMjhkNjM2MWEwIiwiNjg3Y2EzMWQtNWE5Yy00NjYwLTgxZTQtOGJkM2FhMjcxMmVhIl0sImdyYW50X3R5cGUiOiJhdXRob3JpemF0aW9uX2NvZGUiLCJ1c2VyX25hbWUiOiIyMjA0MjRhNy05YmE3LTQzZTEtYTM5My1jZGY1ZDdmNzBiZDkiLCJyb2xlcyI6WyJyYWRhci10ZXN0LTE6Uk9MRV9QQVJUSUNJUEFOVCJdLCJzY29wZSI6WyJNRUFTVVJFTUVOVC5DUkVBVEUiLCJTVUJKRUNULlJFQUQiLCJTVUJKRUNULlVQREFURSJdLCJpc3MiOiJNYW5hZ2VtZW50UG9ydGFsIiwiZXhwIjoxNzIwNDE1Nzk0LCJpYXQiOjE3MjAzNzI1OTQsImF1dGhvcml0aWVzIjpbIlJPTEVfUEFSVElDSVBBTlQiXSwiY2xpZW50X2lkIjoiYVJNVCJ9.VtPC7HGimsnYKhxc6lmeziPzlDCUHsDw9kvZeTuXe3_DolbJerN_MC2FuedBuPubXLD3KcJR-_fEfqc1y1JUWQ",
    baseUrl: "https://staging-alpha.radar.thehyve.nl/",
    kafkaEndpoint: "kafka/topics/",
    schemaEndpoint: "schema/subjects/",
    projectId: "radar-test-1",
    userId: "220424a7-9ba7-43e1-a393-cdf5d7f70bd9",
    sourceId: "687ca31d-5a9c-4660-81e4-8bd3aa2712ea",
}

async function onDeviceReady() {

    console.log('Running cordova-' + cordova.platformId + '@' + cordova.version);
    document.getElementById('deviceready').classList.add('ready');

    document.getElementById('get-cache-status-button').onclick = async function () {
        try {
            const res = await getCacheStatus()
            console.log("[JS] Cache Status - Number of files:", res);
            document.getElementById('cache-status-result').innerHTML = res.toString();
        } catch (e) {
            console.log("[JS] Cache Status Error", e);
            alert("[JS] Cache Status Error: " + e);
        }
    }

    document.getElementById('clear-cache-button').onclick = async function () {
        try {
            const res = await clearCache()
            console.log("[JS] Clear Cache", res);
            document.getElementById('cache-status-result').innerHTML = "000";
        } catch (e) {
            console.log("[JS] Clear Cache Error", e);
            alert("[JS] Clear Cache Error: " + e);
        }
    }

    document.getElementById('set-config-button').onclick = async function () {
        try {
            const res = await setConfig(config)
            console.log("[JS] Config is set", res);
            document.getElementById('set-config-result').innerHTML = "Config is set";
        } catch (e) {
            console.log("[JS] Config is NOT set", e);
            document.getElementById('set-config-result').innerHTML = "ERROR in Config set: " + e;
        }
    }

    document.getElementById('upload-cache-button').onclick = async function () {
        console.log("Upload all clicked");
        try {
            const res = await uploadCache()
            console.log("[JS] Upload Cache", JSON.stringify(res));
            document.getElementById('upload-cache-result').innerHTML = document.getElementById('upload-cache-result').innerHTML + JSON.stringify(res) + '<br>';
        } catch (e) {
            console.log("[JS] Upload Cache Error", JSON.stringify(e));
            document.getElementById('upload-cache-result').innerHTML = document.getElementById('upload-cache-result').innerHTML + JSON.stringify(e) + '<br>';
        }
    }

    document.getElementById('process-button').onclick = async function () {
        alert(1);
        await isSensorkitAvailable();

        // try {
        //     const res = await setConfig(config)
        //     console.log("[JS] Config is set", res);
        //     document.getElementById('set-config-result').innerHTML = "Config is set";
        // } catch (e) {
        //     console.log("[JS] Config is NOT set", e);
        //     document.getElementById('set-config-result').innerHTML = "ERROR in Config set: " + e;
        // }

        try {
            const res = await getAvailableSensors()
            console.log("[JS] Available Sensors", JSON.stringify(res));
            document.getElementById('available-sensors-result').innerHTML = res.toString();
        } catch (e) {
            console.log("[JS] Available Sensors Error", e);
            document.getElementById('available-sensors-result').innerHTML = "ERROR Available Sensors: " + e;
        }

        try {
            const sensorArray = ["ambientLightSensor", "accelerometer", "deviceUsageReport","keyboardMetrics","messagesUsageReport","onWristState","pedometerData","phoneUsageReport", "rotationRate", "visits","ambientPressure"]
            const res = await checkAuthorization(sensorArray)
            console.log("[JS] checkAuthorization", JSON.stringify(res));
        } catch (e) {
            console.log("[JS] checkAuthorization", e);
        }

        try {
            const sensorArray = ["ambientLightSensor", "accelerometer", "deviceUsageReport","keyboardMetrics","messagesUsageReport","onWristState","pedometerData","phoneUsageReport", "rotationRate", "visits","ambientPressure"]
            const res = await authorize(sensorArray)
            console.log("[JS] Authorize", JSON.stringify(res));
        } catch (e) {
            console.log("[JS] Authorize", e);
        }

        try {
            const sensorArray = [
                // {sensor: "ambientLightSensor", period: 3600000, chunkSize: 10},
                // {sensor: "accelerometer", period: 100, chunkSize: 10000},
                {sensor: "rotationRate", period: 1000, chunkSize: 10000},
                // {sensor: "deviceUsageReport"},
                // {sensor: "keyboardMetrics"},
                // {sensor: "messagesUsageReport"},
                // {sensor: "onWristState"},
                // {sensor: "pedometerData"},
                // {sensor: "phoneUsageReport"},
                // {sensor: "visits"},
                // {sensor: "ambientPressure", period: 3600000, chunkSize: 10},
                // {sensor: "telephonySpeechMetrics"}
            ]
            const res = await RbSensorkitCordovaPlugin.selectSensors(sensorArray)
            console.log("[JS] Select Sensor Success");

            await sleep(1000)
        } catch (e) {
            // add bugfender
            console.log("[JS] Error selecting sensors", e);
        }

        startFetchingAll()


    }

    document.getElementById('magnetic-field-button').onclick = async function () {
        try {
            const res = await selectMagneticFieldSensor({topic: "apple_ios_magnetic_field", period: 100, chunkSize: 100})
            console.log("[JS] Sensor Magnetic Field is selected", res);
        } catch (e) {
            console.log("[JS] Sensor Magnetic Field is NOT selected", e);
        }
        await sleep(1000)
        fetchMagneticFieldData();
        await sleep(60000);
    };



    //
    // return;




    // try {
    //     const sensorArray = ["deviceUsageReport","keyboardMetrics"]
    //     const res = await stopRecording(sensorArray)
    //     console.log("[JS] stopRecording", JSON.stringify(res));
    // } catch (e) {
    //     console.log("[JS] stopRecording", e);
    // }

    // return;


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
    // await sleep(30000);
    //
    // startFetchingAll();
    // await sleep(30000);
    //
    // startFetchingAll();
    // await sleep(30000);
    //
    // startFetchingAll();
    // await sleep(30000);
    //
    // startFetchingAll();
    // await sleep(30000);
    //
    // startFetchingAll();
    // await sleep(30000);
    //
    // startFetchingAll();
    //return;

    // try {
    //     const res = await startFetchingAll()
    //     console.log("[JS] startFetchingAll", res);
    // } catch (e) {
    //     console.log("[JS] startFetchingAll", e);
    // }
    //
    // return;
    //
    // try {
    //     const res = await selectMagneticFieldSensor({topic: "apple_ios_magnetic_field", period: 100, chunkSize: 100})
    //     console.log("[JS] Sensor Magnetic Field is selected", res);
    // } catch (e) {
    //     console.log("[JS] Sensor Magnetic Field is NOT selected", e);
    // }
    //
    // await sleep(1000)
    //
    // fetchMagneticFieldData();
    //
    // await sleep(60000);
    //
    // await stopUpdateMagneticField();
    //
    // await sleep(1000)
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
            document.getElementById('start-fetching-all-result').innerHTML = document.getElementById('start-fetching-all-result').innerHTML + JSON.stringify(res) + '<br>';

        },
        function(e){
            console.log("[JS] startFetchingAll ERROR ", JSON.stringify(e));
            document.getElementById('start-fetching-all-result').innerHTML = document.getElementById('start-fetching-all-result').innerHTML + JSON.stringify(e) + '<br>';
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

// function uploadCache() {
//     return new Promise((resolve, reject) => {
//         RbSensorkitCordovaPlugin.uploadCache(resolve, reject)
//     })
//
//     // return new Promise((resolve, reject) => {
//     //     RbSensorkitCordovaPlugin.uploadCache(resolve, reject)
//     // })
//
//     // RbSensorkitCordovaPlugin.uploadCache(
//     //     function(res){
//     //         console.log("[JS] uploadCache", JSON.stringify(res));
//     //         document.getElementById('upload-cache-result').innerHTML = document.getElementById('upload-cache-result').innerHTML + JSON.stringify(res) + '<br>';
//     //
//     //     },
//     //     function(e){
//     //         console.log("[JS] uploadCache ERROR ", JSON.stringify(e));
//     //         document.getElementById('upload-cache-result').innerHTML = document.getElementById('upload-cache-result').innerHTML + JSON.stringify(e) + '<br>';
//     //     }
//     // )
// }

function uploadCache() {
    RbSensorkitCordovaPlugin.uploadCache(
        function(res){
            console.log("[JS] uploadCache", JSON.stringify(res));
            document.getElementById('start-fetching-all-result').innerHTML = document.getElementById('start-fetching-all-result').innerHTML + JSON.stringify(res) + '<br>';

        },
        function(e){
            console.log("[JS] uploadCache ERROR ", JSON.stringify(e));
            document.getElementById('start-fetching-all-result').innerHTML = document.getElementById('start-fetching-all-result').innerHTML + JSON.stringify(e) + '<br>';
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
