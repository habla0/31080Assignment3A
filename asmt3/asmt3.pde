import processing.video.*;
Capture cam;
boolean screenType;

void setup() {
    screenType = false;

    size(640, 480);
    cam = new Capture(this, 640, 480);
    cam.start();
    plate = createImage(640, 480);

}

void captureEvent(Capture cam) {
    plate.copy(video, 0, 0, video.width, video.height, 0, 0, plate.width, plate.height);
    if (cam.available() == true) {
        cam.read();
    }

}

void draw() {
    if (!screenType) {
        inputScreen();
    } else {
        processingScreen();
    }
    
}

// Where the user enters in the string (and to get out of the way)
String inputScreen() {
    String charSet = "";
    // Take in input to append it to the string. Once space is pressed
    // the user should duck as the camera needs to see the user's background
    
    return charSet;

}

// Where the final result is processed using the character set / message
void processingScreen(String charSet) {
    image(cam, 0, 0, width, height);
}

