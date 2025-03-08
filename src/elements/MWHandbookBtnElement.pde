// figma @ MainWindow.HandbookButton

public class MWHandbookBtnElement extends Element {
    private static final int PLACEMENT_X = 960;
    private static final int PLACEMENT_Y = 82;
    private static final String BG_IMAGE_F_ASSET = "assets/images/MainWindow_Handbook_F.png";
    private static final String BG_IMAGE_S_ASSET = "assets/images/MainWindow_Handbook_S.png";

    private PImage[] imageAssets;
    private boolean isExpanded;
    private boolean isClicked;

    public MWHandbookBtnElement() {
        super(PLACEMENT_X, PLACEMENT_Y);

        // load image assets
        imageAssets = new PImage[2];
        imageAssets[0] = loadImage(BG_IMAGE_F_ASSET);
        imageAssets[1] = loadImage(BG_IMAGE_S_ASSET);
    }

    public void update(PGraphics targetGraphics) {
        // check mouse hover
        if (mouseX > transform.x && mouseX < transform.x + imageAssets[1].width &&
            mouseY > transform.y && mouseY < transform.y + imageAssets[1].height) {
            isExpanded = true;
        }

        if (isExpanded) {
            targetGraphics.image(imageAssets[0], transform.x, transform.y);
            if (mouseX > transform.x && mouseX < transform.x + imageAssets[0].width &&
                mouseY > transform.y && mouseY < transform.y + imageAssets[0].height) {
                if (mousePressed) {
                    console.log("HandbookBtn: clicked");
                    isClicked = true;
                }
            } else {
                isExpanded = false;
            }
        } else {
            targetGraphics.image(imageAssets[1], transform.x, transform.y);
        }
    }

    public void queryClickState() {
        if (isClicked) {
            isClicked = false;
            return true;
        }
        return false;
    }
}