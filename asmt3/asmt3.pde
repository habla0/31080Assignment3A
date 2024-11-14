import processing.video.*;

Capture cam;
boolean areWeProcessing;
PImage plate;
String brightStr = " .:,'-^*+?!|=0#X%WM@"; // Thanks Emil Widlund
String message = "";
PFont font;

void setup() {
    areWeProcessing = false;

    // Set parameters for the camera
    size(1280, 960);
    cam = new Capture(this, 80, 60);
    cam.start();
    plate = createImage(80, 60, RGB);

    // Set font
    font = createFont("Cascadia Code", 10);
    textFont(font);
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
    message = message.toUpperCase();

    // Remember the background
    if (key == ENTER) {
        areWeProcessing = true;
        plate.copy(cam, 0, 0, cam.width, cam.height, 0, 0, plate.width, plate.height);
        plate.updatePixels();
    }
    if (key == BACKSPACE) {
        message = "";
    }
    
}

// Display the screen
void inputScreen() {
    background(0);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(message, width / 2, height / 2);
}

// Where the final result is processed using the character set / message
void processingScreen(String message) {
    background(0);

    float sqWidth = width / cam.width;
    float sqHeight = height / cam.height;
    int posY = 0;
    int posX = 0;

    cam.loadPixels();
    plate.loadPixels();
    //image(cam, 0, 0, width, height);

    // For some reason a nested loop doesn't work for an INEXPLICABLE reason
    // Loop through all the pixels on the scene
    for (int x = 0; x < 4800; x++) {
        color currentColour = cam.pixels[x];
        color prevColour = plate.pixels[x];

        if (posX % 80 == 0 && posX != 0) {
            posY += 1;
        }
        if (posX == 80) {
            posX = 0;
        }
        
        float r = red(currentColour);
        float g = green(currentColour);
        float b = blue(currentColour);

        float r1 = red(prevColour);
        float g1 = green(prevColour);
        float b1 = blue(prevColour);

        // Draw the scene as ASCII
        float brightness = r + g + b / 3; // Take the average
        int brightIndex = floor(map(brightness, 0, 254, 0, brightStr.length() - 1));
        if (brightIndex < 0) {
            brightIndex = 0;
        }
        if (brightIndex > 19) {
            brightIndex = 19;
        }
        textSize(sqWidth);
        textAlign(CENTER, CENTER);
        text(brightStr.charAt(brightIndex), posX * sqWidth, posY * sqHeight);

        posX++;
    }
    updatePixels();

}
