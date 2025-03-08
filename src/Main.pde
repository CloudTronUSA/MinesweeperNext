/* @pjs preload="assets/images/GameWindow_Base.png, assets/images/MainWindow_Base.png"; font="assets/fonts/NuberNextCondensed-Bold.otf, assets/fonts/NuberNextWide-Bold.otf" */

private static final int GAME_TIME = 1500000;

private GameController gameController;

private Scene mainWindow;
private Scene summaryWindow;
private Scene handbookWindow;

private MWButtonElement startButton;
private MWHandbookBtnElement handbookButton;
private HBInfoElement handbookInfo;

private int gameState;  // 0 = main menu, 1 = intro, 2 = briefing, 3 = in-game, 4 = win summary
private Timer timer;
private PImage cursorImage;

private boolean firstGame;
private boolean startGameAfterHandbook;

void setup() {
    size(1280,720);
    frameRate(60);

    // initiate a scene for main menu
    mainWindow = new Scene();
    mainWindow.setBackground("assets/images/MainWindow_Base.png");
    startButton = new MWButtonElement();
    handbookButton = new MWHandbookBtnElement();
    mainWindow.addElement(startButton);
    mainWindow.addElement(handbookButton);

    // initiate a scene for win summary
    summaryWindow = new Scene();
    summaryWindow.setBackground("assets/images/SW_Base.png");

    // initiate a scene for handbook
    handbookWindow = new Scene();
    handbookWindow.setBackground("assets/images/IntroWindow_Base.png");

    timer = new Timer();
    firstGame = true;
    startGameAfterHandbook = false;

    cursorImage = loadImage("assets/images/mouseCursor.png");
}

void draw() {
    cursor(cursorImage);

    if (startButton.isFilled()) {   // start the game
        // check if it is the first game
        if (firstGame) {
            timer.startTimer(
                1000,
                new TimerMessage(
                    new String[] {"UNLOCK_HANDBOOK_SKIP"},
                    new int[] {},
                    new float[] {},
                    new Object[] {}
                )
            );

            gameState = 1;
            handbookInfo = new HBInfoElement();
            handbookWindow.replaceElement(0, handbookInfo);
            handbookInfo.lockSkip();

            firstGame = false;
            startGameAfterHandbook = true;
        } else {
            gameState = 3;
            // initiate game controller
            gameController = new GameController(GAME_TIME);
        }
    }

    // check game over
    if (gameController != null && gameController.getIsGameOver() && !timer.getIsActivated()) {
        timer.startTimer(
            5000,
            new TimerMessage(
                new String[] {"RETURN_TO_MAIN"},
                new int[] {},
                new float[] {},
                new Object[] {}
            )
        );
        
        if (gameController.getIsMissionComplete()) {
            summaryWindow.replaceElement(0, new SWMissionSummaryElement(
                gameController.getMissionCreateTime(),
                millis()
            ));
            gameState = 4;
        }
    }

    if (timer.update() == 1) {  // return to main window
        TimerMessage message = timer.getMessage();
        if (message.msgStr[0] == "RETURN_TO_MAIN") {
            gameState = 0;
            gameController = null;
            timer.reset();
        } else if (message.msgStr[0] == "UNLOCK_HANDBOOK_SKIP") {
            handbookInfo.unlockSkip();
        }
    }

    switch (gameState) {
        case 0:
            mainWindow.update();
            if (handbookButton.queryClickState()) {
                gameState = 1;
                handbookInfo = new HBInfoElement();
                handbookWindow.replaceElement(0, handbookInfo);
                firstGame = false;
            }
            break;
        case 1:
            handbookWindow.update();
            if (handbookInfo.isComplete()) {
                gameState = 0;
                if (startGameAfterHandbook) {
                    gameState = 3;
                    gameController = new GameController(GAME_TIME);
                    startGameAfterHandbook = false;
                }
            }
            break;
        case 3:
            gameController.update();
            break;
        case 4:
            summaryWindow.update();
            break;
    }
}

void keyReleased() {
    switch (gameState) {
        case 0:
            mainWindow.onKey();
            break;
        case 1:
            handbookWindow.onKey();
            break;
        case 3:
            gameController.onKey();
            break;
    }
}