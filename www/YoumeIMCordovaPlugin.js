cordova.define("im.youme.cordovaim.YoumeIMCordovaPlugin", function(require, exports, module) {
var exec = require('cordova/exec');

exports.init = function (appKey,secretKey,regionId, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'init', [appKey,secretKey,regionId]);
};
exports.login = function (userid, password, token, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'login', [userid, password, token]);
};
exports.logout = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'logout', []);
};
exports.sendTextMessage = function (strRecvId, iChatType, strMsgContent, strAttachParam, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'sendTextMessage', [strRecvId, iChatType, strMsgContent, strAttachParam]);
};

exports.registerReconnectCallback = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'registerReconnectCallback', []);
};
exports.registerKickOffCallback = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'registerKickOffCallback', []);
};
exports.registerMsgEventCallback = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'registerMsgEventCallback', []);
};
exports.startRecordAudioMessage = function (recvID, chatType, extraText, needRecognize, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'startRecordAudioMessage', [recvID, chatType, extraText, needRecognize]);
};
exports.cancelAudioMessage = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'cancelAudioMessage', []);
};
exports.stopAndSendAudioMessage = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'stopAndSendAudioMessage', []);
};

});
