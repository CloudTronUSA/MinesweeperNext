// figma @ SummaryWindow

public class SWMissionSummaryElement extends Element {
    private static final int PLACEMENT_X = 0;
    private static final int PLACEMENT_Y = 0;
    private static final int SUMMARY_TARGET_X = 65;
    private static final int SUMMARY_TARGET_Y = 125;
    private static final int COMPLETE_TARGET_X = 768;
    private static final int COMPLETE_TARGET_Y = 458;
    private static final int DELAY_DISPLAY_FRAMES = 20;
    private static final String SUMMARY_TEXT_ASSET = "assets/images/SW_Summary.png";
    private static final String COMPLETE_ASSET = "assets/images/SW_Complete.png";

    private PImage summaryTextAsset;
    private PImage completeAsset;

    private PFont boldCondensedFont;
    private int missionStartTime;
    private int missionEndTime;
    private int missionTimeLimit;

    private int summaryAnimationFrame;
    private int summaryAnimationFrameMax;
    private int completeAnimationFrame;
    private int completeAnimationFrameMax;
    private int delayDisplayFrames;

    public SWMissionSummaryElement(
        int mst, int met
    ) {
        super(PLACEMENT_X, PLACEMENT_Y);

        // load image assets
        summaryTextAsset = loadImage(SUMMARY_TEXT_ASSET);
        completeAsset = loadImage(COMPLETE_ASSET);

        boldCondensedFont = loadFont("assets/fonts/NuberNextCondensed-Bold.otf");

        missionStartTime = mst;
        missionEndTime = met;

        delayDisplayFrames = 0;

        summaryAnimationFrame = 0;
        summaryAnimationFrameMax = 15;

        completeAnimationFrame = 0;
        completeAnimationFrameMax = 10;
    }

    public void update(PGraphics targetGraphics) {
        // delay the display
        if (delayDisplayFrames < DELAY_DISPLAY_FRAMES) {
            delayDisplayFrames += 1;
            return;
        }

        // copy summary image and draw the remaining time on it
        int timeRemainMilis = (missionEndTime - missionStartTime);  // in milliseconds
        float timeRemainSeconds = timeRemainMilis / 1000;
        float timeRemainMinutes = timeRemainSeconds / 60;
        timeRemainSeconds = timeRemainSeconds % 60;
        String timeRemain = "";
        timeRemain += floor(timeRemainMinutes) + " Minutes ";
        timeRemain += floor(timeRemainSeconds) + " Seconds";

        PGraphics summaryGraphics = createGraphics(summaryTextAsset.width, summaryTextAsset.height, P2D);
        summaryGraphics.beginDraw();
        summaryGraphics.image(summaryTextAsset, 0, 0);
        summaryGraphics.textFont(boldCondensedFont, 48);
        summaryGraphics.textAlign(LEFT);
        summaryGraphics.fill(0, 0, 0);
        summaryGraphics.text(timeRemain, 75, 430);
        summaryGraphics.endDraw();

        // animate the image by sliding in from left
        int slideInX = 0;
        if (summaryAnimationFrame < summaryAnimationFrameMax) {
            slideInX = lerp(-SUMMARY_TARGET_X-summaryGraphics.width, SUMMARY_TARGET_X, summaryAnimationFrame/summaryAnimationFrameMax);
            summaryAnimationFrame += 1;
            targetGraphics.image(summaryGraphics, slideInX, SUMMARY_TARGET_Y);
            return;
        } else {
            slideInX = SUMMARY_TARGET_X;
            targetGraphics.image(summaryGraphics, slideInX, SUMMARY_TARGET_Y);
        }

        // draw complete image (sliding in from right)
        slideInX = 0;
        if (completeAnimationFrame < completeAnimationFrameMax) {
            slideInX = lerp(targetGraphics.width, COMPLETE_TARGET_X, completeAnimationFrame/completeAnimationFrameMax);
            completeAnimationFrame += 1;
        } else {
            slideInX = COMPLETE_TARGET_X;
        }

        targetGraphics.image(completeAsset, slideInX, COMPLETE_TARGET_Y);
    }

}