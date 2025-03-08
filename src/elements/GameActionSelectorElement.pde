// figma @ GameWindow.OperationSelect

public class GameActionSelectorElement extends Element {
    private static final int PLACEMENT_X = 704;
    private static final int PLACEMENT_Y = 340;
    private static final String BG_IMAGE_ASSET = "assets/images/GameWindow_ActionSelector.png";

    private PImage imageAsset;
    private int currentlySelectedAction;

    private ArrayList<GameActionElement> actionElems;
    private GameFieldElement gameField;

    public GameActionSelectorElement(GameFieldElement gF) {
        super(PLACEMENT_X, PLACEMENT_Y);
        gameField = gF;

        // load image assets
        imageAsset = loadImage(BG_IMAGE_ASSET);

        // initiate sub-elems
        actionElems = new ArrayList<GameActionElement>();

        actionElems.add(new GameActionElement(
            2, false,
            transform.x + 15,
            transform.y + 68,
            gameField.getGameMap().getMineTotal(),
            gameField.getGameMap().getMineTotal() - gameField.getGameMap().getMineFlagged(),
            "FLAG / UNFLAG BLOCK",
            new char[] {'w', 'w'}
        ));

        actionElems.add(new GameActionElement(
            1, false,
            transform.x + 15,
            transform.y + 192,
            -1,
            -1,
            "ENTER BLOCK",
            new char[] {'s', 's'}
        ));

        actionElems.add(new GameActionElement(
            3, true,
            transform.x + 15,
            transform.y + 316,
            2,
            2,
            "CHEAT",
            new char[] {'w', 's', 'd', 'd', 'd'}
        ));
    }

    public void update(PGraphics targetGraphics) {
        targetGraphics.image(imageAsset, transform.x, transform.y);
        actionElems.get(0).setActionTotalUse(gameField.getGameMap().getMineTotal());
        actionElems.get(0).setActionRemainingUse(gameField.getGameMap().getMineTotal() - gameField.getGameMap().getMineFlagged());

        for (GameActionElement elem : actionElems)elem.update(targetGraphics);
    }

    public void onKey() {
        // if there is one that is being selected, only update that
        boolean selectedExists = false;
        for (GameActionElement elem : actionElems) {
            if (elem.isCurrentlySelected) {
                selectedExists = true;
                break;
            }
        }
        if (selectedExists) {
            for (GameActionElement elem : actionElems)
                if (elem.isCurrentlySelected) elem.onKey(gameField);
        } else {
            for (GameActionElement elem : actionElems) elem.onKey(gameField);
        }
    }
}