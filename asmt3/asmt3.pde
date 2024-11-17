import processing.video.*;
import processing.sound.*;

Capture cam;
boolean areWeProcessing;
PImage plate;
PFont font;

SqrOsc[] square;
float[] soundFreqs;
int freqNum;

int delay; 
int movement;

String brightStr; 
String message;

void setup() {
    size(1280, 960);
    surface.setTitle("messagetoyou.exe");
    areWeProcessing = false;

    brightStr = " `.-':_,^=;><+!rc*/z?sLTv)J7(|Fi{C}fI319d4VOGHm8RD#$0MNWQ%&@"; // ASCII string
    message = "> ";

    delay = 0;
    movement = 0;

    // Decrease resolution for the camera
    cam = new Capture(this, 80, 60);
    cam.start();
    plate = createImage(80, 60, RGB);

    // Set font
    font = createFont("JetBrains Mono", 10);
    textFont(font);

    // Set sound
    freqNum = 4;
    square = new SqrOsc[freqNum];
    soundFreqs = new float[freqNum];
    for (int i = 0; i < freqNum; i++) {
        square[i] = new SqrOsc(this);
        square[i].amp(0.1);
    }

}

void captureEvent(Capture cam) {
    if (cam.available() == true) {
        frameDelay();
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
    switch (keyCode) {
        case ENTER: // Remember the background and switch to the next screen
            String newMsg = message.replace(" ", "");
            float frequency = 0.0;

            for (int c = 0; c < newMsg.length(); ++c) {
                frequency += newMsg.charAt(c);
            }
            frequency /= newMsg.length();;
            println(frequency);

            for (int i = 0; i < freqNum; i++) {
                soundFreqs[i] = frequency * (i + random(-0.5, 0.5));
            }

            message += " ";
            message = message.substring(2);
            areWeProcessing = true;
            break;
        case BACKSPACE: // Purge the string if you make a mistake (no I'm not bothered to import StringBuilder)
            message = "> ";
            break;
        case RIGHT: // Change the delay timing for taking the plate image
            if (delay < 1) {
                delay++;
            }
            break;
        case LEFT:
            if (delay > 0) {
                delay--;
            }
            break;
        default:
            if (!areWeProcessing && keyCode != SHIFT) {
                message += key;
                message = message.toUpperCase();
            }
    }

}

// Display the text
void inputScreen() {
    background(0);
    textSize(60);
    textAlign(CENTER, CENTER);
    text("SAY SOMETHING", width / 2, (height / 2) - 200);
    text("SAY SOMETHING", width, (height / 2) - 200);
    text("SAY SOMETHING", width - width, (height / 2) - 200);
    textSize(25);
    textAlign(CENTER, CENTER);
    text(message, width / 2, (height / 2) + 100);

}

// Process the screen
void processingScreen(String message) {
    background(0);
    
    // Make sure that the characters display within a square boundary
    float sqWidth = width / cam.width;
    float sqHeight = height / cam.height;

    // Keep track of the coordinates in the array
    int posY = 0;
    int posX = 0;

    int threshold = 50; // Threshold to detect colour change of a pixel

    int msgIndex = 0;

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

        // Detect colour change in pixels using the distance formula (thanks Daniel Shiffman for this idea)
        double distance = Math.sqrt((r-r1)*(r-r1) + (g-g1)*(g-g1) + (b-b1)*(b-b1));

        // Pixels that are different from the plate image will be coloured red
        if (distance > threshold) { 
            currentColour = color(255, 0, 0);
        }

        // Draw the scene as ASCII
        float brightness = r + g + b / 3; // Average of colours equals luminosity
        int brightIndex = floor(map(brightness, 0, 255, 0, brightStr.length() - 1));
        
        // Boundary checking
        if (brightness > 255) {
            brightness = 255;
        }
        if (brightIndex < 0) {
            brightIndex = 0;
        }
        if (brightIndex >= brightStr.length()) {
            brightIndex = brightStr.length()-1;
        }

        textSize(sqWidth);
        textAlign(CENTER, CENTER);
        if (currentColour == color(255, 0, 0)) {
            text(message.charAt(msgIndex), posX * sqWidth, posY * sqHeight);
            fill(255, 0, 0);
            msgIndex++;
        } else {
            text(brightStr.charAt(brightIndex), posX * sqWidth, posY * sqHeight);
            fill(255);
        }

        int timeStart = millis();

        soundProcessing(currentColour);

        // Reset msgIndex at the end of the message
        if (msgIndex >= message.length() - 1) {
            msgIndex = 0;
        }
        
        posX++;
    }
    updatePixels();

}

// Strangely convoluted solution to a problem that doesn't exist
// I am just bored and am throwing things together (this doesn't work correctly half the time istg)
void frameDelay() {
    int start = millis();
    delay(delay);
    int stop = millis();

    if (stop - start <= 1) {
        plate.copy(cam, 0, 0, cam.width, cam.height, 0, 0, plate.width, plate.height);
        plate.updatePixels();
    }
    
}

// Simple function to determine the number of red pixels and to play sound accordingly
void soundProcessing(color c) {

    if (c == color(255, 0, 0)) {
        movement += 10;
    } else if (c != color(255, 0, 0) && movement > 0) {
        movement--;
    }
    //println(movement);

    if (movement > 120) {
        for (int i = 0; i < freqNum; i++) {
            square[i].freq(soundFreqs[i]);
            square[i].play();
        }
        
    } else {
        for (int i = 0; i < freqNum; i++) {
            square[i].stop();
        }
    }

}
