// figma @ GameWindow.TimeRemain

public class GameTimeRemainElement extends Element {
    private static final int PLACEMENT_X = 704;
    private static final int PLACEMENT_Y = 80;
    private static final String BG_IMAGE_ASSET = "assets/images/GameWindow_TimeRemain.png";

    private PFont boldCondensedFont;
    private PImage imageAsset;
    private int missionStartTime;
    private int missionTimeLimit;

    public GameTimeRemainElement(int mst, int mtl) {
        super(PLACEMENT_X, PLACEMENT_Y);

        // load image assets
        imageAsset = loadImage(BG_IMAGE_ASSET);
        boldCondensedFont = loadFont("assets/fonts/NuberNextCondensed-Bold.otf");

        missionStartTime = mst;
        missionTimeLimit = mtl;
    }

    public void update(PGraphics targetGraphics) {
        // draw time remain
        int timeRemainMilis = missionTimeLimit - (millis() - missionStartTime);  // in milliseconds
        
        // if time is up, set to 0
        if (timeRemainMilis < 0) timeRemainMilis = 0;

        // format to Minutes:Seconds.Miliseconds(2 digits)
        float timeRemainSeconds = timeRemainMilis / 1000;
        float timeRemainMinutes = timeRemainSeconds / 60;
        timeRemainSeconds = timeRemainSeconds % 60;
        float timeRemainMiliseconds = timeRemainMilis % 1000 / 10;

        // we need to format the time ourselves :(
        String timeRemain = "";
        if (timeRemainMinutes < 10) timeRemain += "0";
        timeRemain += floor(timeRemainMinutes) + ":";
        if (timeRemainSeconds < 10) timeRemain += "0";
        timeRemain += floor(timeRemainSeconds) + ".";
        if (timeRemainMiliseconds < 10) timeRemain += "0";
        timeRemain += floor(timeRemainMiliseconds);

        // draw the bar
        targetGraphics.fill(0, 0, 0);
        int barWidth = 395 * (timeRemainMilis / missionTimeLimit);
        targetGraphics.rect(transform.x + 114, transform.y + 55, barWidth, 58);

        targetGraphics.image(imageAsset, transform.x, transform.y);

        // draw text
        targetGraphics.fill(255);
        targetGraphics.textFont(boldCondensedFont, 24);
        targetGraphics.textAlign(LEFT);
        targetGraphics.text(timeRemain, transform.x + 18, transform.y + 92);
    }

    public void isTimeUp() {
        int timeRemainMilis = missionTimeLimit - (millis() - missionStartTime);  // in milliseconds
        if (timeRemainMilis < 0) return true;
        return false;
    }
}