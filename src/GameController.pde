// Game controller that cordiantes the game

public class GameController {
    private static final int MAX_STACK = 3;
    private static final String FAIL_WINDOW_STACK = "assets/images/FailWindow_Stack.png";
    private static final String FAIL_WINDOW_TIME = "assets/images/FailWindow_Time.png";

    private ArrayList<PImage> imageAsset;

    private ArrayList<GameRound> gameRounds;
    private boolean isGameOver;
    private boolean isMissionComplete;
    private int missionFailReason;  // 0: stack full, 1: time limit reached
    private boolean hasDrawnFailWindow;

    private int missionCreateTime;
    private int missionTimeLimit;

    public GameController(int missionTimeLimit) {
        // load assets
        imageAsset = new ArrayList<PImage>();
        imageAsset.add(loadImage(FAIL_WINDOW_STACK));
        imageAsset.add(loadImage(FAIL_WINDOW_TIME));

        ArrayList<ArrayList<Integer>> stack = new ArrayList<ArrayList<Integer>>();
        gameRounds = new ArrayList<GameRound>();

        missionCreateTime = millis();
        this.missionTimeLimit = missionTimeLimit;

        gameRounds.add(new GameRound(
            4, // difficulty
            stack, // stack
            -1, -1, // responsible for
            missionCreateTime, missionTimeLimit
        ));

        isGameOver = false;
        isMissionComplete = false;
    }

    public void update() {
        if (isGameOver || isMissionComplete) {
            if (!isMissionComplete && !hasDrawnFailWindow) {
                // draw fail window
                console.log("draw once Fail");
                image(imageAsset.get(missionFailReason), 0, 0);
                hasDrawnFailWindow = true;
            }
            return;
        }

        // time check
        if (millis() - missionCreateTime > missionTimeLimit) {
            isGameOver = true;
            missionFailReason = 1;
            console.log("GameController: mission time limit reached, game over");
            return;
        }

        for (int r=0; r<gameRounds.size(); r++) {
            GameRound gR = gameRounds.get(r);

            if (gR.getRoundState() == 0) {   // active rounds - update
                gR.update();
            } else if (gR.getRoundState() == 1) {    // waiting for revival - issue new round
                // first check if we can initiate a new round
                if (gameRounds.size() > MAX_STACK) {    // if stack is full, game over
                    console.log("GameController: stack is full, game over");
                    missionFailReason = 0;
                    isGameOver = true;
                    return; 
                } // we can initiate a new round!
                // mark the previous round as paused
                if (r > 0) {
                    gameRounds.get(r-1).setRoundState(2);
                }
                // initiate a new round
                console.log("GameController: checks all passed, initiating new round attemp to revive blk " + gR.getBlockReqRevival()[0] + ", " + gR.getBlockReqRevival()[1]);
                gameRounds.add(new GameRound(
                    3-r, // difficulty -1
                    gR.getStack(), // stack
                    gR.getBlockReqRevival()[0], gR.getBlockReqRevival()[1], // responsible for
                    missionCreateTime, missionTimeLimit
                ));
                // mark the current round as revival in progress
                gR.setRoundState(2);
            } else if (gR.getRoundState() == 2) {    // paused
                // do nothing
            } else if (gR.getRoundState() == 3) {    // finished round - check if we can return to previous round
                if (r == 0) {   // if this is the first round, game over
                    isGameOver = true;
                    isMissionComplete = true;
                    console.log("GameController: mission complete");
                    return;
                }
                // mark the previous round as active
                gameRounds.get(r-1).revive();
                gameRounds.get(r-1).setRoundState(0);
                // remove this round
                gameRounds.remove(r);
            }
        }
    }

    public void onKey() {
        for (GameRound gR : gameRounds) {
            if (gR.getRoundState() == 0) {  // active rounds only
                gR.onKey();
            }
        }
    }

    public boolean getIsGameOver() {return isGameOver;}
    public boolean getIsMissionComplete() {return isMissionComplete;}
    public int getMissionFailReason() {return missionFailReason;}
    public int getMissionCreateTime() {return missionCreateTime;}
    public int getMissionTimeLimit() {return missionTimeLimit;} 
}