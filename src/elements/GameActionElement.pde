// figma @ GameWindow.OperationSelect.action

public class GameActionElement extends Element {
    private static final String L_BG_ASSET = "assets/images/GameWindow_Action_L.png";
    private static final String D_BG_ASSET = "assets/images/GameWindow_Action_D.png";
    private static final String DF_ARROW_ASSET = "assets/images/basicIcons/arrow_d_filled.png";
    private static final String DO_ARROW_ASSET = "assets/images/basicIcons/arrow_d_outline.png";
    private static final String LF_ARROW_ASSET = "assets/images/basicIcons/arrow_l_filled.png";
    private static final String LO_ARROW_ASSET = "assets/images/basicIcons/arrow_l_outline.png";

    private ArrayList<PImage> imageAssets;
    private PFont boldCondensedFont;
    private PFont boldWideFont; 
    private boolean isCurrentlySelected;

    private boolean enabled;
    private boolean isHidden;
    private int selfId;
    private int maxUses;
    private int remainingUses;
    private String actionName;
    private char[] actionKeys;

    private Timer timer;
    private ArrayList<Character> keysPressed;

    public GameActionElement(int sid, boolean isHidden, int x, int y, int mu, int ru, int an, char[] ak) {
        super(x, y);

        // load assets (0 = light, 1 = dark)
        imageAssets = new ArrayList<PImage>();
        imageAssets.add(loadImage(L_BG_ASSET));
        imageAssets.add(loadImage(D_BG_ASSET));
        imageAssets.add(loadImage(DO_ARROW_ASSET));
        imageAssets.add(loadImage(LO_ARROW_ASSET));
        imageAssets.add(loadImage(DF_ARROW_ASSET));
        imageAssets.add(loadImage(LF_ARROW_ASSET));

        boldCondensedFont = loadFont("assets/fonts/NuberNextCondensed-Bold.otf");
		boldWideFont = loadFont("assets/fonts/NuberNextWide-Bold.otf");

        isCurrentlySelected = false;

        enabled = true;
        this.isHidden = isHidden;
        selfId = sid;
        maxUses = mu;
        remainingUses = ru;
        actionName = an;
        actionKeys = ak;

        keysPressed = new ArrayList<Character>();
        timer = new Timer();
    }

    // override update
    public void update(PGraphics targetGraphics) {
        int timerStatus = timer.update();
        if (timerStatus == 1) {  // a key is completed, do the action
            TimerMessage message = timer.getMessage();
            if (message.msgStr[0] == "EXECUTE_ACTION") {
                keysPressed.clear();
                remainingUses -= 1;
                isCurrentlySelected = false;
                timer.reset();
            }
        }

        if (isHidden) return;

        targetGraphics.fill(#000000);   // black by default 

        // draw bg
        if(isCurrentlySelected) {
            targetGraphics.image(imageAssets.get(1), transform.x, transform.y);
            targetGraphics.fill(#ffffff);    // change to white
        } else {
            targetGraphics.image(imageAssets.get(0), transform.x, transform.y);
        }

        // draw text: action name
        targetGraphics.textFont(boldCondensedFont, 24);
        targetGraphics.textAlign(LEFT);
        if(isCurrentlySelected)
            targetGraphics.text(actionName, transform.x + 45, transform.y + 50); 
        else
            targetGraphics.text(actionName, transform.x + 18, transform.y + 50); 

        // draw text: remaining
        String remainingText = (""+remainingUses) + " / " + (""+maxUses) + " LEFT";
        if (remainingUses <= -1)
            remainingText = "UNLIMITED";
        targetGraphics.textFont(boldWideFont, 20);
        targetGraphics.textAlign(RIGHT);
        targetGraphics.text(remainingText, transform.x + 458, transform.y + 48);

        // draw arrow icons
        for (int i=0; i<actionKeys.length; i++) {
            int posX = transform.x + (40*i);
            if (isCurrentlySelected) 
                posX += 42;
            else
                posX += 16;
            int posY = transform.y + 60;

            int imgOffset = 0;
            if (i < keysPressed.size())
                imgOffset += 2;
            if (isCurrentlySelected)
                imgOffset += 1;

            switch (actionKeys[i]) {
                case 'w':
                    targetGraphics.image(imageAssets.get(imgOffset+2), posX, posY);
                    break;
                case 's':
                    targetGraphics.translate(posX, posY);
                    targetGraphics.rotate(radians(180));
                    targetGraphics.image(imageAssets.get(imgOffset+2), -32, -32);
                    break;
                case 'd':
                    targetGraphics.translate(posX, posY);
                    targetGraphics.rotate(radians(90));
                    targetGraphics.image(imageAssets.get(imgOffset+2), 0, -32);
                    break;
                case 'a':
                    targetGraphics.translate(posX, posY);
                    targetGraphics.rotate(radians(270));
                    targetGraphics.image(imageAssets.get(imgOffset+2), -32, 0);
                    break;
            }
            targetGraphics.resetMatrix();
        }
    }

    public void onKey(GameFieldElement gF) {
        if (remainingUses == 0 || timer.update() == 0) {    // if no remaining uses or timer is running, return
            return;
        }
        if (key == 'w' || key == 'a' || key == 's' || key == 'd') {
            if (key == actionKeys[keysPressed.size()]) {
                keysPressed.add(key);
                isCurrentlySelected = true;
                // check for full combo
                if (actionKeys.length == keysPressed.size()) {
                    // all passed!
                    timer.startTimer(100, new TimerMessage(
                        new String[] {"EXECUTE_ACTION"},
                        new int[] {},
                        new float[] {},
                        new Object[] {}
                    ));

                    onActionUse(gF);
                }
            } else {
                isCurrentlySelected = false;
                keysPressed.clear();
            }
        } else {
            isCurrentlySelected = false;
            keysPressed.clear();
        }
    }

    private void onActionUse(GameFieldElement gF) {
        if (selfId == 1)
            gF.onReveal();
        else if (selfId == 2)
            gF.onFlag();
        else if (selfId == 3)
            gF.onCheat();
    }

    public void setActionSelected(boolean selected) {isCurrentlySelected = selected;}
    public void setActionRemainingUse(int rU) {remainingUses = rU;}
    public void setActionTotalUse(int tU) {maxUses = tU;}
}