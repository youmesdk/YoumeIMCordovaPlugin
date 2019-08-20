package im.youme.cordovaim;

import android.content.Context;
import android.os.Environment;
import android.util.Log;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.gson.Gson;
import com.youme.imsdk.YIMClient;
import com.youme.imsdk.YIMConstInfo;
import com.youme.imsdk.YIMMessage;
import com.youme.imsdk.YIMMessageBodyAudio;
import com.youme.imsdk.YIMMessageBodyFile;
import com.youme.imsdk.YIMMessageBodyText;
import com.youme.imsdk.callback.YIMEventCallback;
import com.youme.imsdk.internal.ChatRoom;
import com.youme.imsdk.internal.SendMessage;
import com.youme.imsdk.internal.SendVoiceMsgInfo;

/**
 * This class echoes a string called from JavaScript.
 */
public class YoumeIMCordovaPlugin extends CordovaPlugin implements YIMEventCallback.ReconnectCallback, YIMEventCallback.KickOffCallback, YIMEventCallback.MessageEventCallback {

    private static final String TAG = "YoumeIMCordovaPlugin";

    private CallbackContext reconnectCallback ;
    private CallbackContext kickOffCallback;
    private CallbackContext msgEventCallback;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        switch (action){
            case "init":
            {
                String appKey = args.getString(0);
                String appSecretKey = args.getString(1);
                int serverRegionId = args.getInt(2);
                this.init(appKey,appSecretKey ,serverRegionId, callbackContext);
            }
            break;
            case "registerReconnectCallback":
            {
                this.reconnectCallback = callbackContext;
            }
            return true;
            case "registerKickOffCallback":
            {
                this.kickOffCallback = callbackContext;
            }
            return true;
            case "registerMsgEventCallback":
            {
                this.msgEventCallback = callbackContext;
            }
            return true;
            case "login":
            {
                String userID = args.getString(0);
                String password = args.getString(1);
                String userToken = args.getString(2);
                this.login(userID, password, userToken, callbackContext);
            }
            break;
            case "logout":
            {
                this.logout(callbackContext);
            }
            break;
            case "sendTextMessage":
            {
                String recvID     = args.getString(0);
                int    chatType   = args.getInt(1);
                String msgContent = args.getString(2);
                String attachPram = args.getString(3);
                this.sendTextMessage(recvID, chatType, msgContent, attachPram, callbackContext);
            }
            break;
            case "startRecordAudioMessage":
            {
                String recvID     = args.getString(0);
                int    chatType   = args.getInt(1);
                String extraText = args.getString(2);
                boolean needRecognize = args.getBoolean(3);
                this.startRecordAudioMessage(recvID, chatType, extraText, needRecognize, false, callbackContext);
            }
            break;
            case "cancelAudioMessage":
            {
                this.cancelAudioMessage();
            }
            return false;
            case "joinChatRoom":
            {
                String roomID     = args.getString(0);
                this.joinChatRoom(roomID, callbackContext);
            }
            break;
            case "stopAndSendAudioMessage":
            {
                this.stopAndSendAudioMessage(callbackContext);
            }
            break;
            case "leaveChatRoom":
            {
                String roomID     = args.getString(0);
                this.leaveChatRoom(roomID, callbackContext);
            }
            break;
            case "startPlayAudio":
            {
                String audioPath     = args.getString(0);
                this.startPlayAudio(audioPath, callbackContext);
            }
            break;
            case "stopPlayAudio":
            {
                this.stopPlayAudio();
            }
            return false;
            case "switchTransType":
            {
                int    transType   = args.getInt(0);
                this.switchTransType(transType, callbackContext);
            }
            break;
            case "sendFileMessage":
            {
                String recvID     = args.getString(0);
                int    chatType   = args.getInt(1);
                String filePath = args.getString(2);
                String attachPram = args.getString(3);
                int    fileType   = args.getInt(4);
                filePath = filePath.replace("file:///","/");
                filePath = filePath.replace("FILE:///","/");
                this.sendFileMessage(recvID, chatType, filePath, attachPram, fileType, callbackContext);
            }
            break;
            case "downloadFileByUrl":
            {
                String url      = args.getString(0);
                String savePath = args.getString(1);
                int    fileType = args.getInt(2);
                this.downloadFileByURL(url, savePath, fileType, callbackContext);
            }
                break;
            default:
                return false;
        }
        return true;
    }

    private void init(String appKey, String secretKey,int serverId, CallbackContext callbackContext) {
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                int code = YIMClient.getInstance().init(YoumeIMCordovaPlugin.this.cordova.getActivity(), appKey, secretKey, serverId);
                if ( code == 0 ) {
                    callbackContext.success(0);
                } else {
                    callbackContext.error(code);
                }

                YIMClient.getInstance().registerReconnectCallback(YoumeIMCordovaPlugin.this);
                YIMClient.getInstance().registerKickOffCallback(YoumeIMCordovaPlugin.this);
                YIMClient.getInstance().registerMsgEventCallback(YoumeIMCordovaPlugin.this);
            }
        });
    }

    private void login(String userid, String password, String token,  CallbackContext callbackContext) {
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                YIMClient.getInstance().login(userid, password, token, new YIMEventCallback.ResultCallback<String>() {
                    @Override
                    public void onSuccess(String userid) {
                        callbackContext.success(0);
                    }

                    @Override
                    public void onFailed(int code, String userid) {
                        callbackContext.error(code);
                    }
                });
            }
        });
    }

    private void logout(CallbackContext callbackContext){
        cordova.getActivity().runOnUiThread(new Runnable() {
            public void run() {
                YIMClient.getInstance().logout(new YIMEventCallback.OperationCallback(){

                    @Override
                    public void onSuccess() {
                        callbackContext.success(0);
                    }

                    @Override
                    public void onFailed(int code) {
                        callbackContext.error(code);
                    }
                });
            }
        });
    }

    private void sendTextMessage(String recvID, int chatType, String msgContent, String attachParam, CallbackContext callbackContext){
        YIMClient.getInstance().sendTextMessage(recvID, chatType, msgContent, attachParam, new   YIMEventCallback.ResultCallback<SendMessage>(){

            @Override
            public void onSuccess(SendMessage sendMessage) {
                Gson gson = new Gson();
                String sendMessageInfo = gson.toJson(sendMessage);
                callbackContext.success(sendMessageInfo);
            }

            @Override
            public void onFailed(int code, SendMessage sendMessage) {
                Gson gson = new Gson();
                String sendMessageInfo = gson.toJson(sendMessage);
                callbackContext.error(sendMessageInfo);
            }
        });
    }

    private void sendFileMessage(String recvID, int chatType,String filePath,String extParam, int fileType, CallbackContext callbackContext){
        YIMClient.getInstance().sendFile(recvID, chatType, filePath, extParam, fileType, new YIMEventCallback.ResultCallback<SendMessage>(){

            @Override
            public void onSuccess(SendMessage sendMessage) {
                Gson gson = new Gson();
                String sendMessageInfo = gson.toJson(sendMessage);
                callbackContext.success(sendMessageInfo);
            }

            @Override
            public void onFailed(int code, SendMessage sendMessage) {
                Gson gson = new Gson();
                String sendMessageInfo = gson.toJson(sendMessage);
                callbackContext.error(sendMessageInfo);
            }
        });
    }

    private void downloadFileByURL(String url,String savePath , int fileType, CallbackContext callbackContext){
        YIMClient.getInstance().downloadFileByUrl(url, savePath, fileType, new YIMEventCallback.DownloadByUrlCallback(){

            @Override
            public void onDownloadByUrl(int code, String fromUrl,  String savePath,int audioTime) {
                im.youme.cordovaim.FileDownloadMessage result = new im.youme.cordovaim.FileDownloadMessage();
                result.code = code;
                result.fromURL = fromUrl;
                result.savePath = savePath;
                result.audioTime = audioTime;
                Gson gson = new Gson();
                String jsonStr = gson.toJson(result);
                if(code == 0){
                    callbackContext.success(jsonStr);
                }else{
                    callbackContext.error(jsonStr);
                }
            }
        });
    }

    private void startRecordAudioMessage(String recvId, int chatType, String extraText, boolean recognizeText, boolean isOpenOnlyRecognizeText,CallbackContext callbackContext){
        YIMClient.MessageSendStatus status = YIMClient.getInstance().startRecordAudioMessage(recvId, chatType, extraText, recognizeText,isOpenOnlyRecognizeText );
        if(status != null && status.getErrorCode() == 0)
        {
            callbackContext.success(""+status.getMessageId());
        }else{
            callbackContext.error(status.getErrorCode());
        }
    }

    private void cancelAudioMessage() {
        YIMClient.getInstance().cancleAudioMessage();
    }

    private void stopAndSendAudioMessage(CallbackContext callbackContext){
        YIMClient.getInstance().stopAndSendAudioMessage(new YIMEventCallback.AudioMsgEventCallback(){

            @Override
            public void onStartSendAudioMessage(long requestID, int code, String strText, String strAudioPath, int audioTime) {
                if(code == 0) {
                    im.youme.cordovaim.AudioMessageStartSendInfo msgStartInfo = new im.youme.cordovaim.AudioMessageStartSendInfo();
                    msgStartInfo.msgId = requestID;
                    msgStartInfo.audioText = strText;
                    msgStartInfo.audioPath = strAudioPath;
                    msgStartInfo.audioTime = audioTime;
                    callbackContext.success(new Gson().toJson(msgStartInfo));
                }else{
                    callbackContext.error(code);
                }
            }

            @Override
            public void onSendAudioMessageStatus(int code, SendVoiceMsgInfo sendVoiceMsgInfo) {
                if(code != 0){
                    callbackContext.error(code);
                }
            }
        });
    }

    private void joinChatRoom(String roomID, CallbackContext callbackContext){
        YIMClient.getInstance().joinChatRoom(roomID, new YIMEventCallback.ResultCallback<ChatRoom>() {
            @Override
            public void onSuccess(ChatRoom chatRoom) {
                callbackContext.success(chatRoom.groupId);
            }

            @Override
            public void onFailed(int code, ChatRoom chatRoom) {
                callbackContext.error(chatRoom.groupId);
            }
        });
    }

    private void leaveChatRoom(String roomID, CallbackContext callbackContext){
        YIMClient.getInstance().leaveChatRoom(roomID, new YIMEventCallback.ResultCallback<ChatRoom>() {
            @Override
            public void onSuccess(ChatRoom chatRoom) {
                callbackContext.success(chatRoom.groupId);
            }

            @Override
            public void onFailed(int code, ChatRoom chatRoom) {
                callbackContext.error(chatRoom.groupId);
            }
        });
    }

    private void startPlayAudio(String audioPath, CallbackContext callbackContext){
        YIMClient.getInstance().startPlayAudio(audioPath, new YIMEventCallback.ResultCallback<String>() {
            @Override
            public void onSuccess(String s) {
                callbackContext.success();
            }

            @Override
            public void onFailed(int code, String s) {
                callbackContext.error(code);
            }
        });
    }

    private void stopPlayAudio(){
        YIMClient.getInstance().stopPlayAudio();
    }

    private void switchTransType(int transType, CallbackContext callbackContext){
        int code = YIMClient.getInstance().switchMsgTransType(transType);
        if(code == 0){
            callbackContext.success();
        }else{
            callbackContext.error("switchTransType failed, code: "+code);
        }
    }

    @Override
    public void onStartReconnect() {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "{event:\"onStartReconnect\" }");
        pluginResult.setKeepCallback(true);
        if(this.reconnectCallback != null) this.reconnectCallback.sendPluginResult(pluginResult);
    }

    @Override
    public void onRecvReconnectResult(int result) { //result 0- reconnect success，1- reconnect fail，try again，2- reconnect failed
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "{event:\"onRecvReconnectResult\", result:"+result+" }");
        pluginResult.setKeepCallback(true);
        if(this.reconnectCallback != null) this.reconnectCallback.sendPluginResult(pluginResult);
    }

    @Override
    public void onKickOff() {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, "{event:\"onKickOff\"}");
        pluginResult.setKeepCallback(true);
        if(this.kickOffCallback != null) this.kickOffCallback.sendPluginResult(pluginResult);
    }

    @Override
    public void onRecvNewMessage(int i, String s) {

    }

    @Override
    public void onRecvMessage(YIMMessage message) {
        if (null == message)
            return;

        int msgType = message.getMessageType();
        if (YIMConstInfo.MessageBodyType.TXT == msgType){
            YIMMessageBodyText sdkMsg = (YIMMessageBodyText)message.getMessageBody();
            im.youme.cordovaim.TextMessage txtMsg = new im.youme.cordovaim.TextMessage();
            txtMsg.createTime = message.getCreateTime();
            txtMsg.isRead = message.getIsRead();
            txtMsg.chatType = message.getChatType();
            txtMsg.receiveId = message.getReceiveID();
            txtMsg.senderId = message.getSenderID();
            txtMsg.msgId = message.getMessageID();
            txtMsg.msgType = message.getMessageType();

            txtMsg.msgContent = sdkMsg.getMessageContent();
            txtMsg.attachParam = sdkMsg.getAttachParam();

            String jsonResult = new Gson().toJson(txtMsg);

            Log.d(TAG,"recv txt msg: " + jsonResult);

            PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonResult);
            pluginResult.setKeepCallback(true);
            if(this.msgEventCallback != null) this.msgEventCallback.sendPluginResult(pluginResult);

        }else if (YIMConstInfo.MessageBodyType.Voice == msgType){
            long mRecvAudioMsgId = message.getMessageID();
            //download audio file
            YIMClient.getInstance().downloadAudioMessage(mRecvAudioMsgId, getDiskCachePath(this.cordova.getContext())+"/"+mRecvAudioMsgId+".wav",
                    new YIMEventCallback.DownloadFileCallback() {
                        @Override
                        public void onDownload(int errorcode, YIMMessage message, String savePath) {
                            if(errorcode == 0) {
                                YIMMessageBodyAudio sdkMsg = (YIMMessageBodyAudio) message.getMessageBody();
                                im.youme.cordovaim.AudioMessage audioMsg = new im.youme.cordovaim.AudioMessage();
                                audioMsg.createTime = message.getCreateTime();
                                audioMsg.isRead = message.getIsRead();
                                audioMsg.chatType = message.getChatType();
                                audioMsg.receiveId = message.getReceiveID();
                                audioMsg.senderId = message.getSenderID();
                                audioMsg.msgId = message.getMessageID();
                                audioMsg.msgType = message.getMessageType();

                                audioMsg.attachParam = sdkMsg.getParam();
                                audioMsg.audioPath = savePath;
                                audioMsg.audioText = sdkMsg.getText();
                                audioMsg.audioTime = sdkMsg.getAudioTime();
                                String jsonResult = new Gson().toJson(audioMsg);
                                Log.d(TAG,"recv audio msg: " + jsonResult);

                                PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonResult);
                                pluginResult.setKeepCallback(true);
                                if(YoumeIMCordovaPlugin.this.msgEventCallback != null) YoumeIMCordovaPlugin.this.msgEventCallback.sendPluginResult(pluginResult);
                            }else{
                                Log.e(TAG,"download msg:"+mRecvAudioMsgId+ " failed");
                            }

                        }
                    }
            );
        }else if(YIMConstInfo.MessageBodyType.File == msgType){
            long mRecvMsgId = message.getMessageID();
            YIMMessageBodyFile sdkMsg = (YIMMessageBodyFile) message.getMessageBody();
            String fileExtension = sdkMsg.getFileExtension();
            String originalFileName = sdkMsg.getFileName();
            YIMClient.getInstance().downloadFile(mRecvMsgId,getDiskCachePath(this.cordova.getContext())+"/"+mRecvMsgId+"."+fileExtension,new YIMEventCallback.DownloadFileCallback(){

                @Override
                public void onDownload(int errorcode, YIMMessage yimMessage, String savePath) {
                    if(errorcode == 0) {
                        im.youme.cordovaim.FileMessage fileMsg = new im.youme.cordovaim.FileMessage();
                        fileMsg.createTime = message.getCreateTime();
                        fileMsg.isRead = message.getIsRead();
                        fileMsg.chatType = message.getChatType();
                        fileMsg.receiveId = message.getReceiveID();
                        fileMsg.senderId = message.getSenderID();
                        fileMsg.msgId = message.getMessageID();
                        fileMsg.msgType = message.getMessageType();

                        fileMsg.attachParam = sdkMsg.getExtParam();
                        fileMsg.filePath = savePath;
                        fileMsg.fileExtension = sdkMsg.getFileExtension();
                        fileMsg.fileType = sdkMsg.getFileType();
                        fileMsg.fileSize = sdkMsg.getFileSize();
                        fileMsg.fileName = sdkMsg.getFileName();
                        String jsonResult = new Gson().toJson(fileMsg);
                        Log.d(TAG,"recv fileMsg msg: " + jsonResult);

                        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, jsonResult);
                        pluginResult.setKeepCallback(true);
                        if(YoumeIMCordovaPlugin.this.msgEventCallback != null) YoumeIMCordovaPlugin.this.msgEventCallback.sendPluginResult(pluginResult);
                    }else{
                        Log.e(TAG,"download msg:"+ mRecvMsgId+" name:"+originalFileName+ " failed");
                    }
                }
            } );
        }


    }

    @Override
    public void onGetRecognizeSpeechText(int i, long l, String s) {

    }

    @Override
    public void onRecordVolume(float v) {

    }

    public static String getDiskCachePath(Context context) {
        if (Environment.MEDIA_MOUNTED.equals(Environment.getExternalStorageState())
                || !Environment.isExternalStorageRemovable()) {
            return context.getExternalCacheDir().getPath();
        } else {
            return context.getCacheDir().getPath();
        }
    }

}
