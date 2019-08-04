package im.youme.cordovaim;

public class TextMessage {
    public int chatType = 0;
    public String receiveId = null;
    public String senderId = null;
    public long msgId = 0L;
    public int msgType = 0;
    public int createTime;
    public boolean isRead;

    public String msgContent = null;
    public String attachParam = null;
}
