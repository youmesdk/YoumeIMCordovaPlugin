package im.youme.cordovaim;

public class FileMessage {
    public int chatType = 0;
    public String receiveId = null;
    public String senderId = null;
    public long msgId = 0L;
    public int msgType = 0;
    public int createTime;
    public boolean isRead;

    public String filePath = null;
    public String attachParam = "";
    public int fileType = 0;
    public int fileSize = 0;
    public String fileName = null;
    public String fileExtension = "";
}
