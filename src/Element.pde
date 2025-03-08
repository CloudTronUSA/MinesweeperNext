public class Element {
    protected Transform transform;

    public Element(int x, int y) {
        transform = new Transform();
        transform.x = x;
        transform.y = y;
    }

    public void update(PGraphics targetGraphics) {
        // do nothing
    }

    public void onKey() {
        // do nothing
    }
}

public class Transform {
    public int x;
    public int y;
}