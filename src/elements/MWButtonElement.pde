// figma @ MainWindow.StartButton

public class MWButtonElement extends Element {
    private static final int PLACEMENT_X = 448;
    private static final int PLACEMENT_Y = 457;
    private static final String BG_IMAGE_D_ASSET = "assets/images/MainWindow_SButton_D.png";
    private static final String BG_IMAGE_L_ASSET = "assets/images/MainWindow_SButton_L.png";

    private int fillPercentage;
    private PImage[] imageAssets;

    public MWButtonElement() {
        super(PLACEMENT_X, PLACEMENT_Y);

        // load image assets
        imageAssets = new PImage[2];
        imageAssets[0] = loadImage(BG_IMAGE_L_ASSET);
        imageAssets[1] = loadImage(BG_IMAGE_D_ASSET);

        fillPercentage = 0;
    }

    public void update(PGraphics targetGraphics) {
        if (keyPressed && key == ' ') fillPercentage += 4;
        else fillPercentage -= 8;

        if (fillPercentage < 0) fillPercentage = 0;
        if (fillPercentage > 100) fillPercentage = 100;

        targetGraphics.image(imageAssets[0], transform.x, transform.y);

        // fillAreaWidth should reflect the fill percentage
        int fillAreaWidth = imageAssets[1].width-1;
        fillAreaWidth = (int) (fillAreaWidth * (fillPercentage/100));

        // now copy the appropriate area
        targetGraphics.copy(
            imageAssets[1], 0, 0,
            fillAreaWidth, imageAssets[1].height,
            transform.x, transform.y,
            fillAreaWidth, imageAssets[1].height-1
        );
    }

    public boolean isFilled() {
        if (fillPercentage >= 100) {
            fillPercentage = 0;
            return true;
        }
        return false;
    }
}