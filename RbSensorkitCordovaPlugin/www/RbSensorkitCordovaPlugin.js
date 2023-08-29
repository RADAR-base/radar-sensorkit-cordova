var exec = require('cordova/exec');

const PLUGIN_NAME = 'RbSensorkitCordovaPlugin';

exports.selectSensor = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "selectSensor", arg0);
};

exports.authorize = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "authorize", arg0);
};

exports.isSensorKitAvailable = function(success, error) {
    exec(success, error, PLUGIN_NAME, "isSensorKitAvailable");
};

exports.isSensorAvailable = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "isSensorAvailable", [arg0]);
};

exports.checkAuthorization = function(success, error) {
    exec(success, error, PLUGIN_NAME, "checkAuthorization", []);
};

exports.initialiseSensor = function(success, error) {
    exec(success, error, PLUGIN_NAME, "initialiseSensor", []);
};

exports.fetchData = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "fetchData", arg0);
};

exports.setConfig = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "setConfig", arg0);
};

exports.startRecording = function(success, error) {
    exec(success, error, PLUGIN_NAME, "startRecording", []);
};

exports.stopRecording = function(success, error) {
    exec(success, error, PLUGIN_NAME, "stopRecording", []);
};

exports.fetchDevices = function(success, error) {
    exec(success, error, PLUGIN_NAME, "fetchDevices", []);
};

exports.echo = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "echo", [arg0]);
};

exports.selectMagneticFieldSensor = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "selectMagneticFieldSensor", arg0);
};

exports.startMagneticFieldUpdate = function(arg0, success, error) {
    exec(success, error, PLUGIN_NAME, "startMagneticFieldUpdate", arg0);
};
