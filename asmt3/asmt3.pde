import processing.video.*;

Capture cam;
boolean areWeProcessing;
PImage plate;
String brightStr = " `.-':_,^=;><+!rc*/z?sLTv)J7(|Fi{C}fI319d4VOGHm8RD#$0MNWQ%&@"; // ASCII string
String message = "";
PFont font;

void setup() {
    areWeProcessing = false;
    size(1280, 960);

    // Decrease resolution for the camera
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

    // Remember the background and switch to the next screen.
    if (key == ENTER) {
        areWeProcessing = true;
        plate.copy(cam, 0, 0, cam.width, cam.height, 0, 0, plate.width, plate.height);
        plate.updatePixels();
    }

    // Purge the string if you make a mistake (no I'm not bothered to import StringBuilder)
    if (key == BACKSPACE) {
        message = "";
    }
    
}

// Display the text
void inputScreen() {
    background(0);
    textSize(15);
    textAlign(CENTER, CENTER);
    text(message, width / 2, height / 2);
}

// Process the screen
void processingScreen(String message) {
    background(0);

    // Make sure that the characters display within a square boundary
    float sqWidth = width / cam.width;
    float sqHeight = height / cam.height;

    // Keep track of the position
    int posY = 0;
    int posX = 0;

    int threshold = 50; // Threshold to detect colour change of a pixel

    cam.loadPixels();
    plate.loadPixels();
    //image(cam, 0, 0, width, height);

    // For some reason a nested loop doesn't work for an INEXPLICABLE reason
    // Loop through all the pixels on the scene (so many if statements)
    for (int x = 0; x < cam.width * cam.height; x++) {
        color currentColour = cam.pixels[x];
        color prevColour = plate.pixels[x];

        // I'm so good at maths (I'm not)
        // Increment Y position every 80 X pixels (as the resolution is 80 * 60)
        if (posX % 80 == 0 && posX != 0) {
            posY += 1;
        }
        if (posX == 80) {
            posX = 0; // Edge😳 case if X = 0
        }
        
        float r = red(currentColour);
        float g = green(currentColour);
        float b = blue(currentColour);

        float r1 = red(prevColour);
        float g1 = green(prevColour);
        float b1 = blue(prevColour);

        // Detect colour change in pixels using the distance formula (thanks Daniel Shiffman)
        double distance = Math.sqrt((r-r1)*(r-r1) + (g-g1)*(g-g1) + (b-b1)*(b-b1));
        // Pixels that are different from the plate image will be coloured white
        if (distance > threshold) { 
            //cam.pixels[posX+posY*cam.width] = color(255);
            cam.pixels[x] = color(255);
        }

        // // Draw the scene as ASCII
        float brightness = r + g + b / 3; // Average of colours equals luminosity
        int brightIndex = floor(map(brightness, 0, 255, 0, brightStr.length() - 1));

        if (brightness > 255) {
            brightness = 255;
        }

        // Ensure I don't get index errors
        if (brightIndex < 0) {
            brightIndex = 0;
        }
        if (brightIndex >= brightStr.length()) {
            brightIndex = brightStr.length()-1;
        }

        if (cam.pixels[x] < 255) {
            textSize(sqWidth);
            textAlign(CENTER, CENTER);
            text(brightStr.charAt(brightIndex), posX * sqWidth, posY * sqHeight);
        } else {
            textSize(sqWidth);
            textAlign(CENTER, CENTER);
            text(message.charAt(messageIndex), posX * sqWidth, posY * sqHeight);
        }
 
        //println(brightness);

        posX++;
    }
    updatePixels();

}

char displayMessageChar() {
    char a = 'a';
    return a;
}
