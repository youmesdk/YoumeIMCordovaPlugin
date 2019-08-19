/********* YoumeIMCordovaPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "YIMClient.h"
#import "YIMCallbackProtocol.h"

@interface YoumeIMCordovaPlugin <YIMCallbackProtocol> : CDVPlugin {
    // Member variables go here.
}

@property (nonatomic, strong) NSString* callbackIdReConnet;
@property (nonatomic, strong) NSString* callbackIdKickOff;
@property (nonatomic, strong) NSString* callbackIdMsgEvent;
@property (nonatomic, strong) NSString* callbackIdForStopAudioRecord;
@property (nonatomic, strong) NSString* callbackIdFile;
@property (nonatomic, retain) NSString* lastStartRecordParam;



- (void)init:(CDVInvokedUrlCommand*)command;
- (void)login:(CDVInvokedUrlCommand*)command;
- (void)logout:(CDVInvokedUrlCommand*)command;
- (void)joinChatRoom:(CDVInvokedUrlCommand*)command;
- (void)leaveChatRoom:(CDVInvokedUrlCommand*)command;

- (void)registerReconnectCallback:(CDVInvokedUrlCommand*)command;
- (void)registerKickOffCallback:(CDVInvokedUrlCommand*)command;
- (void)registerMsgEventCallback:(CDVInvokedUrlCommand*)command;
- (void)OnStartReconnect;
- (void)OnRecvReconnectResult:(ReconnectResultOC)result;
- (void)OnKickOff;


-(void) OnRecvMessage:(YIMMessage*) pMessage;
-(void) sendTextMessage:(CDVInvokedUrlCommand*)command;
-(void) startRecordAudioMessage:(CDVInvokedUrlCommand*)command;
-(void) cancelAudioMessage:(CDVInvokedUrlCommand*)command;
-(void) stopAndSendAudioMessage:(CDVInvokedUrlCommand*)command;
-(void) downloadAudioByUrl:(CDVInvokedUrlCommand*)command;


-(void) sendFileMessage:(CDVInvokedUrlCommand*)command;

- (void) startPlayAudio:(CDVInvokedUrlCommand*)command;
- (void) stopPlayAudio:(CDVInvokedUrlCommand*)command;

+(NSString*)createUniqFilePath;
@end

@implementation YoumeIMCordovaPlugin

- (void)registerReconnectCallback:(CDVInvokedUrlCommand*)command
{
    self.callbackIdReConnet  = command.callbackId;
}

- (void)registerKickOffCallback:(CDVInvokedUrlCommand*)command
{
    self.callbackIdKickOff  = command.callbackId;
}

- (void)registerMsgEventCallback:(CDVInvokedUrlCommand*)command
{
    self.callbackIdMsgEvent  = command.callbackId;
}



- (void)init:(CDVInvokedUrlCommand*)command
{
    CDVPluginResult* pluginResult = nil;
    NSString* appKey = [command.arguments objectAtIndex:0];
    NSString* secretKey = [command.arguments objectAtIndex:1];
    NSNumber* regionId = [command.arguments objectAtIndex:2];
    
    YIMErrorcodeOC code = [[YIMClient GetInstance] InitWithAppKey:appKey appSecurityKey:secretKey serverZone:(YouMeIMServerZoneOC) [regionId integerValue] ];
    
    [[YIMClient GetInstance] SetDelegate:self];
    
    
    if (code == YouMeIMCode_Success) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)login:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;

    NSString* userid = [command.arguments objectAtIndex:0];
    NSString* password = [command.arguments objectAtIndex:1];
    NSString* token = [command.arguments objectAtIndex:2];
    
    [[YIMClient GetInstance] Login:userid password:password token:token callback:^(YIMErrorcodeOC errorcode, NSString *userID) {
        if(errorcode == YouMeIMCode_Success)
        {
            NSLog(@"userID:%@ 登录成功",userID);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
        }
        else
        {
            NSLog(@"userID:%@ 登录失败，err: ",userID);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
    
}

-(void)logout:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;
    
    [[YIMClient GetInstance] Logout:^(YIMErrorcodeOC errorcode) {
        if(errorcode == YouMeIMCode_Success)
        {
            NSLog(@"登出成功");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
        }
        else
        {
            NSLog(@"登出失败，err: ");
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
    
}

-(void) sendTextMessage:(CDVInvokedUrlCommand*)command
{
    NSString* strRecvId = [command.arguments objectAtIndex:0];
    NSString* iChatType = [command.arguments objectAtIndex:1];
    NSString* strMsgContent = [command.arguments objectAtIndex:2];
    NSString* strAttachParam = [command.arguments objectAtIndex:3];
    
    [[YIMClient GetInstance] SendTextMessage:strRecvId chatType:(YIMChatTypeOC)[iChatType integerValue] msgContent:strMsgContent attachParam:strAttachParam callback:^(YIMErrorcodeOC errorcode, unsigned int sendTime, bool isForbidRoom, int reasonType, unsigned long long forbidEndTime) {
        NSDictionary *msgInfo = @{
                                       @"RequestID":@0,
                                       @"SendTime":@(sendTime),
                                       @"IsForbidRoom":@(isForbidRoom),
                                       @"reasonType":@(reasonType),
                                       @"forbidEndTime":@(forbidEndTime),
                                       };
        NSData *data = [NSJSONSerialization dataWithJSONObject:msgInfo options:kNilOptions error:nil];
        NSString * jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        CDVPluginResult* pluginResult = nil;
        if (errorcode == YouMeIMCode_Success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResult];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        
    }];
}

-(void)OnStartReconnect
{
    if(self.callbackIdReConnet != nil){
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"{event:\"onStartReconnect\" }"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdReConnet];
    }
}

-(void) OnRecvReconnectResult:(ReconnectResultOC)result
{
    if(self.callbackIdReConnet != nil){
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:[NSString stringWithFormat:@"{event:\"onRecvReconnectResult\", result:%d }", result]];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdReConnet];
    }
}

- (void) OnKickOff
{
    if(self.callbackIdKickOff != nil){
        CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"{event:\"onKickOff\" }"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdKickOff];
    }
}

-(void) joinChatRoom:(CDVInvokedUrlCommand*)command
{
    NSString* roomid = [command.arguments objectAtIndex:0];
    
    __block CDVPluginResult* pluginResult = nil;
    [[YIMClient GetInstance] JoinChatRoom:roomid callback:^(YIMErrorcodeOC errorcode, NSString *roomID) {
        
        if (errorcode == YouMeIMCode_Success)
        {
            NSLog(@"加入频道:%@ 成功",roomID);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
        }
        else
        {
            NSLog(@"加入频道:%@ 失败，err:%d",roomID,errorcode);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

-(void) leaveChatRoom:(CDVInvokedUrlCommand*)command
{
    NSString* roomid = [command.arguments objectAtIndex:0];
    
    __block CDVPluginResult* pluginResult = nil;
    [[YIMClient GetInstance] LeaveChatRoom:roomid callback:^(YIMErrorcodeOC errorcode, NSString *roomID) {
        if (errorcode == YouMeIMCode_Success)
        {
            NSLog(@"离开频道:%@ 成功",roomID);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
        }
        else
        {
            NSLog(@"离开频道:%@ 失败，err:%d",roomID,errorcode);
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}




- (void)OnRecvMessage:(YIMMessage*) pMessage
{
    
    if(pMessage == nil)
        return;
    if(pMessage.messageBody.messageType == YIMMessageBodyType_TXT){
        //收到的是文本消息
        
        YIMMessageBodyText *tMessage = (YIMMessageBodyText *)pMessage.messageBody;
        NSDictionary *txtMsg = @{
                                @"createTime":@([pMessage createTime]),
                                @"isRead":@0,
                                @"chatType":@([pMessage chatType]),
                                @"receiveId":[pMessage receiverID],
                                @"senderId":[pMessage senderID],
                                @"msgId":@([pMessage messageID]),
                                @"msgType":@1,
                                
                                @"msgContent":[tMessage messageContent],
                                @"attachParam":[tMessage attachParam]
                                };
        NSData *data = [NSJSONSerialization dataWithJSONObject:txtMsg options:kNilOptions error:nil];
        
        NSString * jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"文字消息:%@",jsonResult);
        if(self.callbackIdMsgEvent != nil){
            CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResult];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdMsgEvent];
        }
    }
    else if(pMessage.messageBody.messageType == YIMMessageBodyType_Voice){
            //收到的是语音消息
            YIMMessageBodyAudio *vMessage = (YIMMessageBodyAudio *)pMessage.messageBody;
        [[YIMClient GetInstance] DownloadAudio:pMessage.messageID strSavePath:[YoumeIMCordovaPlugin createUniqFilePath] callback:^(YIMErrorcodeOC errorcode, YIMMessage *msg, NSString *savePath) {
            NSDictionary *audioMsg = @{
                                       @"createTime":@([pMessage createTime]),
                                       @"isRead":@0,
                                       @"chatType":@([pMessage chatType]),
                                       @"receiveId":[pMessage receiverID],
                                       @"senderId":[pMessage senderID],
                                       @"msgId":@([pMessage messageID]),
                                       @"msgType":@5,
                                       
                                       @"attachParam":@0,
                                       @"audioPath":savePath,
                                       @"audioText":[vMessage textContent],
                                       @"audioTime":@([vMessage audioTime]),
                                       };
            NSData *data = [NSJSONSerialization dataWithJSONObject:audioMsg options:kNilOptions error:nil];
            
            NSString * jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"文字识别结果:%@,fileSize:%d,audioTime:%d",[vMessage textContent], [vMessage fileSize], [vMessage audioTime]);
            if(self.callbackIdMsgEvent != nil){
                CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResult];
                [pluginResult setKeepCallbackAsBool:YES];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdMsgEvent];
            }
        }];
        }
    else if(pMessage.messageBody.messageType == YIMMessageBodyType_File){
        //收到的是文件
        YIMMessageBodyFile* fMessage = (YIMMessageBodyFile *)pMessage.messageBody;
        NSLog(@"获得文件:" );
        [[YIMClient GetInstance] DownloadAudio:pMessage.messageID strSavePath:[YoumeIMCordovaPlugin createUniqFilePath] callback:^(YIMErrorcodeOC errorcode, YIMMessage *msg, NSString *savePath) {
            NSDictionary *fileMsg = @{
                                       @"createTime":@([pMessage createTime]),
                                       @"isRead":@0,
                                       @"chatType":@([pMessage chatType]),
                                       @"receiveId":[pMessage receiverID],
                                       @"senderId":[pMessage senderID],
                                       @"msgId":@([pMessage messageID]),
                                       @"msgType":@7,
                                       
                                       @"attachParam":@0,
                                       @"filePath":savePath,
                                       @"fileExtension":[fMessage fileExtension],
                                       @"fileType":@([fMessage fileType]),
                                       @"fileSize":@([fMessage fileSize]),
                                       @"fileName":@([fMessage fileType]),
                                       };
            NSData *data = [NSJSONSerialization dataWithJSONObject:fileMsg options:kNilOptions error:nil];
            
            NSString * jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"文件消息:%@",jsonResult);
            if(self.callbackIdMsgEvent != nil){
                CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResult];
                [pluginResult setKeepCallbackAsBool:YES];
                [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdMsgEvent];
            }
        }];
    }
    
}

-(void)startRecordAudioMessage:(CDVInvokedUrlCommand*)command
{
    
    NSString* recvID = [command.arguments objectAtIndex:0];
    NSNumber* chatType = [command.arguments objectAtIndex:1];
    NSNumber* extraText = [command.arguments objectAtIndex:2];
    NSNumber* needRecognize = [command.arguments objectAtIndex:3];
    
    self.lastStartRecordParam = [NSString stringWithFormat:@"%@", extraText];

    [[YIMClient GetInstance]StartRecordAudioMessage:recvID chatType:(YIMChatTypeOC)[chatType integerValue] recognizeText:(BOOL)[needRecognize boolValue] isOpenOnlyRecognizeText:false callback:^(YIMErrorcodeOC errorcode, NSString *text, NSString *audioPath, unsigned int audioTime, unsigned int sendTime, bool isForbidRoom, int reasonType, unsigned long long forbidEndTime) {
        /*
        NSDictionary *msgStartInfo = @{
                                   @"msgId":@0,
                                   @"audioText":text,
                                   @"audioPath":audioPath,
                                   @"audioTime":@(audioTime),
                                   };
        NSData *data = [NSJSONSerialization dataWithJSONObject:msgStartInfo options:kNilOptions error:nil];
        NSString * jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"发送的语音消息:%@",jsonResult);
        
        if (errorcode == YouMeIMCode_Success && self.callbackIdForStopAudioRecord) {
            CDVPluginResult*  pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResult];
            [pluginResult setKeepCallbackAsBool:YES];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdForStopAudioRecord];
        }
        */
    }
    startSendCallback:^(YIMErrorcodeOC errorcode, NSString *text, NSString *audioPath, unsigned int audioTime) {
        NSDictionary *msgStartInfo = @{
                                  @"msgId":@0,
                                  @"audioText":text,
                                  @"audioPath":audioPath,
                                  @"audioTime":@(audioTime),
                                  };
       NSData *data = [NSJSONSerialization dataWithJSONObject:msgStartInfo options:kNilOptions error:nil];
       NSString * jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
       NSLog(@"发送的语音消息:%@",jsonResult);
        
        CDVPluginResult* pluginResult = nil;
        if (errorcode == YouMeIMCode_Success && self.callbackIdForStopAudioRecord) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: jsonResult];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackIdForStopAudioRecord];
        }
        
    }];
    CDVPluginResult* pluginResult = nil;
    pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}

-(void) cancelAudioMessage:(CDVInvokedUrlCommand*)command
{
    [[YIMClient GetInstance] CancleAudioMessage];
}

-(void) stopAndSendAudioMessage:(CDVInvokedUrlCommand*)command
{

    YIMErrorcodeOC errorcode = [[YIMClient GetInstance] StopAndSendAudioMessage:self.lastStartRecordParam ? self.lastStartRecordParam : @""];
    self.lastStartRecordParam = nil;
    CDVPluginResult* pluginResult = nil;
    if (errorcode != YouMeIMCode_Success) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }else{
        self.callbackIdForStopAudioRecord = command.callbackId;
    }
    
}

-(void) downloadAudioByUrl:(CDVInvokedUrlCommand*)command
{
    NSString* downloadURL = [command.arguments objectAtIndex:0];
    [[YIMClient GetInstance]DownloadAudioByUrl:downloadURL strSavePath:[YoumeIMCordovaPlugin createUniqFilePath] callback:^(YIMErrorcodeOC errorcode, NSString *strFromUrl, NSString *savePath) {
        CDVPluginResult* pluginResult = nil;
        if (errorcode == YouMeIMCode_Success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) startPlayAudio:(CDVInvokedUrlCommand*)command
{
    NSString* audioPath = [command.arguments objectAtIndex:0];
    [[YIMClient GetInstance]StartPlayAudio:audioPath callback:^(YIMErrorcodeOC errorcode, NSString *path)
    {
        CDVPluginResult* pluginResult = nil;
        if (errorcode == YouMeIMCode_Success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@""];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void) stopPlayAudio:(CDVInvokedUrlCommand*)command
{
    [[YIMClient GetInstance] StopPlayAudio];
}

-(void) sendFileMessage:(CDVInvokedUrlCommand*)command
{
    NSString* strRecvId = [command.arguments objectAtIndex:0];
    NSNumber* iChatType = [command.arguments objectAtIndex:1];
    NSString* filePath = [command.arguments objectAtIndex:2];
    NSString* strAttachParam = [command.arguments objectAtIndex:3];
    NSNumber* fileType = [command.arguments objectAtIndex:4];
    
[[YIMClient GetInstance]SendFile:strRecvId chatType:(YIMChatTypeOC)[iChatType integerValue] filePath:filePath extraParam:strAttachParam fileType:(YIMFileTypeOC)[fileType integerValue] callback:^(YIMErrorcodeOC errorcode, unsigned int sendTime, bool isForbidRoom, int reasonType, unsigned long long forbidEndTime) {
        NSDictionary *msgInfo = @{
                                  @"RequestID":@0,
                                  @"SendTime":@(sendTime),
                                  @"IsForbidRoom":@(isForbidRoom),
                                  @"reasonType":@(reasonType),
                                  @"forbidEndTime":@(forbidEndTime),
                                  };
        NSData *data = [NSJSONSerialization dataWithJSONObject:msgInfo options:kNilOptions error:nil];
        NSString * jsonResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        CDVPluginResult* pluginResult = nil;
        if (errorcode == YouMeIMCode_Success) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResult];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}






+(NSString*)createUniqFilePath{
    NSArray *cachePaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachePath = [cachePaths objectAtIndex:0];
    
    NSString *fullCachePath = [cachePath stringByAppendingPathComponent:@"YIMVoiceCache"];
    NSString *fileName = [NSString stringWithFormat:@"%@.wav", [[NSUUID UUID] UUIDString]];
    BOOL isDir = FALSE;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirExist = [fileManager fileExistsAtPath:fullCachePath
                                        isDirectory:&isDir];
    if(!isDirExist){
        BOOL bCreateDir = [fileManager createDirectoryAtPath:fullCachePath
                                 withIntermediateDirectories:YES
                                                  attributes:nil
                                                       error:nil];
        
        if(!bCreateDir){
            
            NSLog(@"YIM Create Audio Cache Directory Failed.");
            
        }
        
        NSLog(@"%@",fullCachePath);
    }
    return [fullCachePath stringByAppendingPathComponent:fileName];
}


@end
