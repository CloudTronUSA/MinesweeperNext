// scene object

public class Scene {
    private PGraphics sceneGraphics;
    private ArrayList<Element> elements;

    private PImage sceneBgImage;

    public Scene() {
        // initiate components
        sceneGraphics = createGraphics(width, height, P2D);
        elements = new ArrayList<Element>();
    }

    public void setBackground(String imgPath) {
        sceneBgImage = loadImage(imgPath);
    }

    public int addElement(Element elem) {
        elements.add(elem);
        return elements.size() - 1; // return elem id
    }

    public void replaceElement(int elemId, Element elem) {
        if (elemId < elements.size()) {
            elements.set(elemId, elem);
        } else {
            elements.add(elem);
        }
    }

    public void update() {
        sceneGraphics.beginDraw();

        // update bg
        if (sceneBgImage != null)
            sceneGraphics.background(sceneBgImage);
        else
            sceneGraphics.background(100);

        // update elements
        for(Element elem : elements) {
            elem.update(sceneGraphics);
            //console.log("Scene: elem " + elem + " updated!");
        }

        sceneGraphics.endDraw();

        // draw this to screen
        image(sceneGraphics, 0, 0);
    }

    public void onKey() {
        for(Element elem : elements) {
            elem.onKey();
        }
    }
}