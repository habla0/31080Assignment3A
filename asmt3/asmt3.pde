import processing.video.*;
Capture cam;

void setup() {
    size(640, 480);
    cam = new Capture(this, 640, 480);
    cam.start();
    plate = createImage(640, 480);
}

void captureEvent(Capture cam) {

}

void draw() {
    if (cam.available() == true) {
        cam.read();
    }

    image(cam, 0, 0, width, height);
}