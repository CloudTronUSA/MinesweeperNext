// figma @ GameWindow.RecursionStack

public class GameStackElement extends Element {
    private static final int PLACEMENT_X = 704;
    private static final int PLACEMENT_Y = 234;
    private static final String BG_IMAGE_ASSET = "assets/images/GameWindow_Stack.png";
    private static final String[] STACK_ITEM_ASSET = {
        "assets/images/stackIcons/1.png",
        "assets/images/stackIcons/2.png",
        "assets/images/stackIcons/3.png",
        "assets/images/stackIcons/4.png"
    }; // first is for the surface stack
    private ArrayList<PImage> imageAssets;

    // list of [x, y]
    private ArrayList<ArrayList<Integer>> stack;
    private int currentStack;
    private PFont boldCondensedFont;

    public GameStackElement() {
        super(PLACEMENT_X, PLACEMENT_Y);

        stack = new ArrayList<ArrayList<Integer>>();
        currentStack = 0;

        // load image assets
        imageAssets = new ArrayList<PImage>();
        imageAssets.add(loadImage(BG_IMAGE_ASSET));
        for (String imgPath: STACK_ITEM_ASSET)
            imageAssets.add(loadImage(imgPath));

        boldCondensedFont = loadFont("assets/fonts/NuberNextCondensed-Bold.otf");
    }

    public void update(PGraphics targetGraphics) {
        // draw bg
        targetGraphics.image(imageAssets.get(0), transform.x, transform.y);

        // draw other stack
        targetGraphics.fill(255);
        targetGraphics.textFont(boldCondensedFont, 16);
        targetGraphics.textAlign(CENTER);
        for (int i=currentStack; i>0; i--) {
            targetGraphics.image(imageAssets.get(i+1), transform.x + (128*(i)), transform.y + 43);
            
            ArrayList<Integer> stackItem = retrieve(false);
            String stackItemText = "NEST X" + stackItem.get(0) + " Y" + stackItem.get(1);
            targetGraphics.text(stackItemText, transform.x + (128*(i)) + 70, transform.y + 65.5);
        }
        // draw base stack
        targetGraphics.image(imageAssets.get(1), transform.x, transform.y + 43);
    }

    public void push(int x, int y) {
        ArrayList<Integer> newStackItem = new ArrayList<Integer>();
        newStackItem.add(x);
        newStackItem.add(y);
        stack.add(newStackItem);
        currentStack = stack.size();
    }

    public ArrayList<Integer> retrieve(boolean doDelete) {
        if (stack.size() > 0) {
            ArrayList<Integer> poppedItem = stack.get(stack.size()-1);
            if (doDelete) {
                stack.remove(stack.size()-1);
                currentStack = stack.size();
            }
            return poppedItem;
        }
        return null;
    }

    public void setStack(ArrayList<ArrayList<Integer>> newStack) {
        stack = newStack;
        currentStack = stack.size();
    }

    public ArrayList<ArrayList<Integer>> getStack() {
        return stack;
    }
}
