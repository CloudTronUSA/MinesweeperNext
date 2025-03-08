// figma @ SummaryWindow

public class HBInfoElement extends Element {
    private static final int PLACEMENT_X = 0;
    private static final int PLACEMENT_Y = 0;
    private static final int TEXT_TARGET_X = 75;
    private static final int TEXT_TARGET_Y = 350;
    private static final int SECTION_TARGET_X = 833;
    private static final int SECTION_TARGET_Y = 458;

    private static final String[] TEXT_ASSET = {
        "assets/images/handbookText/g0.png",
        "assets/images/handbookText/g1.png",
        "assets/images/handbookText/c0.png",
        "assets/images/handbookText/c1.png"
    };
    private static final String[] SECTION_ASSET = {
        "assets/images/HBWindow_Section_G.png",
        "assets/images/HBWindow_Section_C.png"
    };

    private PImage[] textAssets;
    private PImage[] sectionAssets;

    private int currAnimationFrame;
    private int textAnimationFrameMax;
    private int sectionAnimationFrameMax;

    private int currentDisplaying;
    private int currentDisplayStage; // 0: entering, 1: displaying, 2: exiting

    private boolean presentationComplete;
    private boolean isSkippingLocked;

    public HBInfoElement() {
        super(PLACEMENT_X, PLACEMENT_Y);

        // load image assets
        textAssets = new PImage[TEXT_ASSET.length];
        for (int i = 0; i < TEXT_ASSET.length; i++) {
            textAssets[i] = loadImage(TEXT_ASSET[i]);
        }
        sectionAssets = new PImage[SECTION_ASSET.length];
        for (int i = 0; i < SECTION_ASSET.length; i++) {
            sectionAssets[i] = loadImage(SECTION_ASSET[i]);
        }

        textAnimationFrameMax = 15;
        sectionAnimationFrameMax = 20;

        currentDisplaying = 0;
        currentDisplayStage = 0;
        presentationComplete = false;

        isSkippingLocked = false;
    }

    public void update(PGraphics targetGraphics) {
        noCursor();
        if (presentationComplete) return;

        // figure out what to display
        PImage textGraphics;
        PImage sectionGraphics;

        int textX;
        int sectionX;

        if (currentDisplayStage == 0) {
            textGraphics = textAssets[currentDisplaying];
            sectionGraphics = sectionAssets[(int)(currentDisplaying/2)];

            if (currAnimationFrame < max(textAnimationFrameMax, sectionAnimationFrameMax)) {
                currAnimationFrame += 1;
                textX = lerp(
                    -TEXT_TARGET_X-textGraphics.width, TEXT_TARGET_X, 
                    min(currAnimationFrame, textAnimationFrameMax)/textAnimationFrameMax
                );
                sectionX = lerp(
                    targetGraphics.width, SECTION_TARGET_X, 
                    min(currAnimationFrame, sectionAnimationFrameMax)/sectionAnimationFrameMax
                );
            } else {
                textX = TEXT_TARGET_X;
                sectionX = SECTION_TARGET_X;
                currentDisplayStage = 1;
            }
        } else if (currentDisplayStage == 1) {
            textGraphics = textAssets[currentDisplaying];
            sectionGraphics = sectionAssets[(int)(currentDisplaying/2)];
            textX = TEXT_TARGET_X;
            sectionX = SECTION_TARGET_X;
        } else if (currentDisplayStage == 2) {
            textGraphics = textAssets[currentDisplaying];
            sectionGraphics = sectionAssets[(int)(currentDisplaying/2)];

            if (currAnimationFrame > 0) {
                currAnimationFrame -= 1;
                textX = lerp(
                    -TEXT_TARGET_X-textGraphics.width, TEXT_TARGET_X, 
                    min(currAnimationFrame, textAnimationFrameMax)/textAnimationFrameMax
                );
                sectionX = lerp(
                    targetGraphics.width, SECTION_TARGET_X, 
                    min(currAnimationFrame, sectionAnimationFrameMax)/sectionAnimationFrameMax
                );
            } else {
                textX = -TEXT_TARGET_X-textGraphics.width;
                sectionX = targetGraphics.width;
                currentDisplayStage = 0;
                currentDisplaying += 1;
                if (currentDisplaying >= TEXT_ASSET.length) {
                    presentationComplete = true;
                }
                console.log("currentDisplaying: " + currentDisplaying);
            }
        }

        targetGraphics.image(textGraphics, textX, TEXT_TARGET_Y);
        targetGraphics.image(sectionGraphics, sectionX, SECTION_TARGET_Y);
    }

    public void onKey() {
        if (key == ' ' && !isSkippingLocked) {
            currentDisplayStage = 2;
        }
    }

    public boolean isComplete() {
        return presentationComplete;
    }

    public void lockSkip() {
        isSkippingLocked = true;
    }

    public void unlockSkip() {
        isSkippingLocked = false;
    }
}