// figma @ GameWindow.GameArea

public class GameFieldElement extends Element {
    private static final int PLACEMENT_X = 52;
    private static final int PLACEMENT_Y = 54;
    private static final String BG_IMAGE_ASSET = "assets/images/GameWindow_Field.png";
    private static final String CURSOR_IMAGE_ASSET = "assets/images/basicIcons/cursor.png";

    private static final color CHUNK_BASE = #5B5B5B;
    private static final color[] CHUNK_WITH_NUMBER = {
        #d0d0d0, #ababab, #808080, #2c2c2c
    };  // for 1,2,3,4+
    private static final color CHUNK_FLAGGED = #F65858;

    private ArrayList<PImage> imageAssets;
    private PFont boldCondensedFont;
    private PImage cursorImage;

    // game map (x, y, c) where c = [type, isHidden, isFlagged, isReward]
    // type: -1 = landmine, 0 = empty, 1+ = numbers
    private GameMap gameMap;
    private GameRound gameRoundHandle;

    private Transform currentSelection;

    public GameFieldElement(GameMap gM, GameRound gRH) {
        super(PLACEMENT_X, PLACEMENT_Y);

        // load assets
        imageAssets = new ArrayList<PImage>();
        imageAssets.add(loadImage(BG_IMAGE_ASSET));
        imageAssets.add(loadImage(CURSOR_IMAGE_ASSET));

        boldCondensedFont = loadFont("assets/fonts/NuberNextCondensed-Bold.otf");
        cursorImage = loadImage("assets/images/mouseCursor.png");

        gameMap = gM;
        gameRoundHandle = gRH;
        currentSelection = new Transform();
        currentSelection.x = -1;
        currentSelection.y = -1;
    }

    private ArrayList<ArrayList<ArrayList<Integer>>> convertToArrayList(int[][][] rawMap) {
        ArrayList<ArrayList<ArrayList<Integer>>> listMap = new ArrayList<ArrayList<ArrayList<Integer>>>();
        for (int i = 0; i < rawMap.length; i++) {
            ArrayList<ArrayList<Integer>> row = new ArrayList<ArrayList<Integer>>();
            for (int j = 0; j < rawMap[i].length; j++) {
                ArrayList<Integer> cell = new ArrayList<Integer>();
                for (int k = 0; k < rawMap[i][j].length; k++) {
                    cell.add(rawMap[i][j][k]);
                }
                row.add(cell);
            }
            listMap.add(row);
        }
        return listMap;
    }

    // track mouse movement
    private void updateMouseTracking() {
        if (! (mouseX > PLACEMENT_X && mouseX < PLACEMENT_X + 600 && mouseY > PLACEMENT_Y && mouseY < PLACEMENT_Y+612) ) {
            currentSelection.x = -1;
            currentSelection.y = -1;
            cursor(cursorImage);
            return;
        }

        boolean found = false;
        cursor(CROSS);
        for (int y=0; y<9 && !found; y++) {
            for (int x=0; x<9 && !found; x++) {
                ArrayList<Integer> block = gameMap.queryBlock(x, y);

                // determine location
                float posX = 17 + (8.93 * x) + (x * 55) + transform.x;
                float posY = 17 + (10.4 * y) + (y * 55) + transform.y;

                if (mouseX > posX && mouseX < posX + 55 && mouseY > posY && mouseY < posY + 55) {
                    currentSelection.x = x;
                    currentSelection.y = y;
                    found = true;
                    break;
                }
            }
        }
    }

    public void update(PGraphics targetGraphics) {
        updateMouseTracking();

        // draw bg
        targetGraphics.image(imageAssets.get(0), transform.x, transform.y);

        // draw the boxes
        for (int y=0; y<9; y++) {
            for (int x=0; x<9; x++) {
                ArrayList<Integer> block = gameMap.queryBlock(x, y);

                // determine location
                float posX = 17 + (8.93 * x) + (x * 55) + transform.x;
                float posY = 17 + (10.4 * y) + (y * 55) + transform.y;

                // determine color
                color drawColor = CHUNK_BASE;
                if (block.get(0) > 0 && block.get(1) == 0) {
                    drawColor = CHUNK_WITH_NUMBER[min(block.get(0), 4)-1];

                    // draw
                    targetGraphics.noStroke();
                    targetGraphics.fill(drawColor);
                    targetGraphics.rect(posX, posY, 55, 55);

                    // draw text
                    targetGraphics.fill(#ffffff);
                    targetGraphics.textFont(boldCondensedFont, 24);
                    targetGraphics.textAlign(CENTER);
                    targetGraphics.text(""+block.get(0), posX+28, posY+36);
                } else if (block.get(2) == 1) {
                    // draw the flag

                    drawColor = CHUNK_FLAGGED;

                    targetGraphics.noStroke();
                    targetGraphics.fill(drawColor);
                    targetGraphics.triangle(
                        posX + 0,
                        posY + 54,
                        posX + 28,
                        posY + 0,
                        posX + 55,
                        posY + 54
                    );
                } else if (block.get(1) == 1) {
                    // draw hidden blk
                    targetGraphics.noStroke();
                    targetGraphics.fill(drawColor);
                    targetGraphics.rect(posX, posY, 55, 55);
                } else if (block.get(0) == -2) {
                    // draw cleared blk
                    drawColor = #40FF99;
                    targetGraphics.noStroke();
                    targetGraphics.fill(drawColor);
                    targetGraphics.triangle(
                        posX + 0,
                        posY + 2,
                        posX + 55,
                        posY + 2,
                        posX + 28,
                        posY + 55
                    );
                }
            }
        }

        // draw cursor
        if (currentSelection.x != -1 && currentSelection.y != -1) {
            int x = currentSelection.x;
            int y = currentSelection.y;

            // determine location
            float posX = 17 + (8.93 * x) + (x * 55) + transform.x;
            float posY = 17 + (10.4 * y) + (y * 55) + transform.y;

            targetGraphics.image(imageAssets.get(1), posX-6.5, posY-6);
        }
    }

    public void onReveal() {
        if (currentSelection.x != -1 && currentSelection.y != -1) {
            int x = currentSelection.x;
            int y = currentSelection.y;
            gameRoundHandle.revealCallback(x, y);
        }
    }

    public void onFlag() {
        if (currentSelection.x != -1 && currentSelection.y != -1) {
            gameMap.flagBlock(currentSelection.x, currentSelection.y);
        }
    }

    public void onCheat() {
        gameMap.useCheat();
    }

    public GameMap getGameMap() {return gameMap;}
}