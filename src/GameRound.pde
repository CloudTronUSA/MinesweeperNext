// this class wraps around a game round, which is a single game of the game

public class GameRound {
    private Scene scene;
    private GameMap gameMap;

    private GameFieldElement gameFieldElement;
    private GameActionSelectorElement gameActionSelectorElement;
    private GameStackElement gameStackElement;
    private GameTimeRemainElement gameTimeRemainElement;

    private int roundState; // 0: in progress, 1: waiting for revival, 2: paused, 3: finished
    private int[] blockReqRevival;  // which block needs to be revived

    public GameRound(
        int difficulty, ArrayList<ArrayList<Integer>> stack,
        int responsibleForX, int responsibleForY, int missionCreateTime, int missionTimeLimit
    ) {
        roundState = 0;
        this.blockReqRevival = {-1, -1};    // default value

        scene = new Scene();
        scene.setBackground("assets/images/GameWindow_Base.png");

        console.log("GameRound: initiating new round with difficulty " + difficulty);
        console.log(scene);

        gameMap = new GameMap(difficulty);

        gameFieldElement = new GameFieldElement(gameMap, this);
        gameActionSelectorElement = new GameActionSelectorElement(gameFieldElement);
        gameStackElement = new GameStackElement();
        gameTimeRemainElement = new GameTimeRemainElement(
            missionCreateTime, missionTimeLimit
        );

        scene.addElement(gameFieldElement);
        scene.addElement(gameActionSelectorElement);
        scene.addElement(gameStackElement);
        scene.addElement(gameTimeRemainElement);

        // set the stack
        gameStackElement.setStack(stack);
        if (responsibleForX != -1 && responsibleForY != -1)
            gameStackElement.push(responsibleForX, responsibleForY);
    }

    public void update() {
        scene.update();

        if (gameMap.checkVictoryCondition()) {
            roundState = 3;
            console.log("GameRound: victory condition met");
        }
    }

    public void onKey() {
        scene.onKey();
    }

    public void revive() {
        roundState = 0;
        // set the mine as neutralized
        gameMap.neutralizeBlock(blockReqRevival[0], blockReqRevival[1]);
        blockReqRevival = {-1, -1};
        gameStackElement.retrieve(true);
    }

    public void revealCallback(int x, int y) {
        if (!gameMap.revealBlock(x, y)) {    // if it's a landmine
            roundState = 1;
            console.log("GameRound: landmine clicked at " + x + ", " + y);
            blockReqRevival = {x, y};
            return;
        }
        console.log("GameRound: block revealed at " + x + ", " + y);
    }

    public int getRoundState() {return roundState;}
    public void setRoundState(int state) {
        roundState = state;
        console.log("GameRound: round state set to " + state);
    }
    public int[] getBlockReqRevival() {return blockReqRevival;}
    public ArrayList<ArrayList<Integer>> getStack() {return gameStackElement.getStack();}
}