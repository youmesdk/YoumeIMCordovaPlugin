
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

YoumeIMCordovaPlugin.prototype.sendFileMessage = function (strRecvId, iChatType, filePath, strAttachParam, fileType, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'sendFileMessage', [strRecvId, iChatType, filePath, strAttachParam, fileType]);
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

YoumeIMCordovaPlugin.prototype.downloadFileByUrl = function (downloadURL, strSavePath, fileType, success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'downloadFileByUrl', [downloadURL, strSavePath, fileType]);
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

/**
 * transType: 0 message will delivery directly; 1 means just cc to app server, not delivery directly
 */
YoumeIMCordovaPlugin.prototype.switchTransType = function (transType,success, error) {
    exec(success, error, 'YoumeIMCordovaPlugin', 'switchTransType', []);
};

var YoumeIMCordovaPluginInstance = new YoumeIMCordovaPlugin();
module.exports = YoumeIMCordovaPluginInstance;
