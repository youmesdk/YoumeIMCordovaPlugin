var exec = require('cordova/exec');
function YoumeIMCordovaPlugin(){
    console.log('YoumeIMCordovaPlugin created')
}

YoumeIMCordovaPlugin.prototype.init = function (appKey,secretKey,regionId, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'init', [appKey,secretKey,regionId]);
};
YoumeIMCordovaPlugin.prototype.login = function (userid, password, token, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'login', [userid, password, token]);
};
YoumeIMCordovaPlugin.prototype.logout = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'logout', []);
};
YoumeIMCordovaPlugin.prototype.sendTextMessage = function (strRecvId, iChatType, strMsgContent, strAttachParam, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'sendTextMessage', [strRecvId, iChatType, strMsgContent, strAttachParam]);
};

YoumeIMCordovaPlugin.prototype.registerReconnectCallback = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'registerReconnectCallback', []);
};
YoumeIMCordovaPlugin.prototype.registerKickOffCallback = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'registerKickOffCallback', []);
};
YoumeIMCordovaPlugin.prototype.registerMsgEventCallback = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'registerMsgEventCallback', []);
};
YoumeIMCordovaPlugin.prototype.startRecordAudioMessage = function (recvID, chatType, extraText, needRecognize, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'startRecordAudioMessage', [recvID, chatType, extraText, needRecognize]);
};
YoumeIMCordovaPlugin.prototype.cancelAudioMessage = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'cancelAudioMessage', []);
};
YoumeIMCordovaPlugin.prototype.stopAndSendAudioMessage = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'stopAndSendAudioMessage', []);
};

YoumeIMCordovaPlugin.prototype.joinChatRoom = function (roomID, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'joinChatRoom', [roomID]);
};

YoumeIMCordovaPlugin.prototype.leaveChatRoom = function (roomID, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'leaveChatRoom', [roomID]);
};

YoumeIMCordovaPlugin.prototype.startPlayAudio = function (audioPath, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'startPlayAudio', [audioPath]);
};

YoumeIMCordovaPlugin.prototype.stopPlayAudio = function (success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'stopPlayAudio', []);
};

var YoumeIMCordovaPluginInstance = new YoumeIMCordovaPlugin();
module.exports = YoumeIMCordovaPluginInstance;

