import processing.video.*;

Capture cam;
boolean areWeProcessing;
PImage plate;
String brightness = " .:,'-^*+?!|=0#X%WM@";
String message = "";

void setup() {
    areWeProcessing = false;

    size(640, 480);
    cam = new Capture(this, 80, 60);
    cam.start();

    plate = createImage(80, 60, RGB);

}

void captureEvent(Capture cam) {
    if (cam.available() == true) {
        cam.read();
    }

}

void draw() {
    if (!areWeProcessing) {
        inputScreen();
    } else if (areWeProcessing) {
        processingScreen(message);
    }
    
}

// Take in input to append it to the string. Once ENTER is pressed
// the user should duck as the camera needs to see the user's background
void keyPressed() {
    message += key;

    if (key == ENTER) {
        areWeProcessing = true;
        plate.copy(cam, 0, 0, cam.width, cam.height, 0, 0, plate.width, plate.height);
        plate.updatePixels();
    }

}

// Display the screen
void inputScreen() {
    background(0);
    if (keyPressed) {
        println(message);
    }

}

// Where the final result is processed using the character set / message
void processingScreen(String message) {
    float sqWidth = width / cam.width;
    float sqHeight = height / cam.height;
    int posY = 0;
    int posX = 0;

    cam.loadPixels();
    plate.loadPixels();
    image(cam, 0, 0, width, height);

    // For some reason a nested for loop doesn't work for this application for an INEXPLICABLE reason.
    // Here's my stupid workaround
    for (int x = 0; x < 4800; x++) {
        color currentColour = cam.pixels[x];

        if (posX % 80 == 0 && posX != 0) {
            posY += 1;
        }
        if (posX == 80) {
            posX = 0;
        }
        
        float r = red(currentColour);
        float g = green(currentColour);
        float b = blue(currentColour);

        noStroke();
        fill(r, g, b);
        square(posX * sqWidth, posY * sqHeight, sqWidth);

        posX++;
    }
    updatePixels();

}
