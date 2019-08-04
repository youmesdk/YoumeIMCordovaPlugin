package im.youme.cordovaim;

public class AudioMessage {
    public int chatType = 0;
    public String receiveId = null;
    public String senderId = null;
    public long msgId = 0L;
    public int msgType = 0;
    public int createTime;
    public boolean isRead;

    public String audioPath = null;
    public String attachParam = "";
    public int audioTime = 0;
    public String audioText = "";
}
