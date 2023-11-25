var exec = require('cordova/exec');

const PLUGIN_NAME = 'RbSensorkitCordovaPlugin';

exports.isSensorKitAvailable = function(success, error) {
    exec(success, error, PLUGIN_NAME, "isSensorKitAvailable");
};

exports.getAvailableSensors = function(success, error) {
    exec(success, error, PLUGIN_NAME, "getAvailableSensors");
};

exports.isSensorAvailable = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "isSensorAvailable", [arg0]);
};

exports.setConfig = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "setConfig", arg0);
};

// exports.configureSensors = function(arg0, success, error) {
//     exec(success, error, PLUGIN_NAME, "configureSensors", arg0);
// };

exports.selectSensors = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "selectSensors", arg0);
};

exports.authorize = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "authorize", arg0);
};

exports.checkAuthorization = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "checkAuthorization", arg0);
};

exports.stopRecording = function(success, error) {
    exec(success, error, PLUGIN_NAME, "stopRecording", []);
};


// exports.selectSensor = function(arg0, success, error) {
//     exec(success, error, PLUGIN_NAME, "selectSensor", arg0);
// };




exports.startFetchingAll = function(success, error) {
    exec(success, error, PLUGIN_NAME, "startFetchingAll");
};

exports.getCacheStatus = function(success, error) {
    exec(success, error, PLUGIN_NAME, "getCacheStatus");
};

exports.clearCache = function(success, error) {
    exec(success, error, PLUGIN_NAME, "clearCache");
};

exports.uploadCache = function(success, error) {
    exec(success, error, PLUGIN_NAME, "uploadCache");
};




// exports.initialiseSensor = function(success, error) {
//     exec(success, error, PLUGIN_NAME, "initialiseSensor", []);
// };
//
// exports.fetchData = function(arg0, success, error) {
//     exec(success, error, PLUGIN_NAME, "fetchData", arg0);
// };


// exports.startRecording = function(success, error) {
//     exec(success, error, PLUGIN_NAME, "startRecording", []);
// };


// exports.fetchDevices = function(success, error) {
//     exec(success, error, PLUGIN_NAME, "fetchDevices", []);
// };



exports.echo = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "echo", [arg0]);
};

exports.selectMagneticFieldSensor = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "selectMagneticFieldSensor", arg0);
};

exports.startMagneticFieldUpdate = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "startMagneticFieldUpdate", arg0);
};

exports.stopMagneticFieldUpdate = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "stopMagneticFieldUpdate", arg0);
};
