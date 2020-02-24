
int keyBoardLow = 1;
int keyBoardHigh = 1;
int keyBoardMedium = 1;
int modeNumber = 1;

// Overlay modes:
static int numberOfModes = 9;
boolean[] modeState = new boolean[numberOfModes];
float[] recordedInputStatic = new float[9];
float[] recordedInputTwo = new float[9];
int[] activeModes = new int[3];

boolean changingMode = false;


void CheckKeyPress() {
  if (keyPressed) {
    // Low keyboard
    if (key == 'z') {
      keyBoardLow = 1;
    }
    if (key == 'x') {
      keyBoardLow = 2;
    }
    if (key == 'c') {
      keyBoardLow = 3;
    }
    if (key == 'v') {
      keyBoardLow = 4;
    }
    if (key == 'b') {
      keyBoardLow = 5;
    }
    if (key == 'n') {
      keyBoardLow = 6;
    }
    if (key == 'm') {
      keyBoardLow = 7;
    }
    if (key == ',') {
      keyBoardLow = 8;
    }
    // High keyboard
    if (key == 'q') {
      keyBoardHigh = 1;
    }
    if (key == 'w') {
      keyBoardHigh = 2;
    }
    if (key == 'e') {
      keyBoardHigh = 3;
    }
    if (key == 'r') {
      keyBoardHigh = 4;
    }
    if (key == 't') {
      keyBoardHigh = 5;
    }
    if (key == 'y') {
      keyBoardHigh = 6;
    }
    if (key == 'u') {
      keyBoardHigh = 7;
    }
    if (key == 'i') {
      keyBoardHigh = 8;
    }
    if (key == 'o') {
      keyBoardHigh = 9;
    }
    if (key == 'p') {
      keyBoardHigh = 10;
    }
    
    // Medium keyboard
    if (key == 'a') {
      keyBoardMedium = 1;
    }
    if (key == 's') {
      keyBoardMedium = 2;
    }
    if (key == 'd') {
      keyBoardMedium = 3;
    }
    if (key == 'f') {
      keyBoardMedium = 4;
    }
    if (key == 'g') {
      keyBoardMedium = 5;
    }
    if (key == 'h') {
      keyBoardMedium = 6;
    }
    if (key == 'j') {
      keyBoardMedium = 7;
    }
    if (key == 'k') {
      keyBoardMedium = 8;
    }
    if (key == 'l') {
      keyBoardMedium = 9;
    }
    
    // State number:
    if (key == '1') {
      modeNumber = 1;
    }
    if (key == '2') {
      modeNumber = 2;
    }
    if (key == '3') {
      modeNumber = 3;
    }
    if (key == '4') {
      modeNumber = 4;
    }
    if (key == '5') {
      modeNumber = 5;
    }
    if (key == '6') {
      modeNumber = 6;
    }
    if (key == '7') {
      modeNumber = 7;
    }
    if (key == '8') {
      modeNumber = 8;
    }
    if (key == '9') {
      modeNumber = 9;
    }
    
    if ((key == '1' || key == '2' || key == '3' || key == '4' ||
        key == '5' || key == '6' || key == '7' || key == '8' || key == '9')
        && (!changingMode)) {
          
      // Remove the third active mode, and move all the others down one line:
      if (modeNumber != activeModes[0]) {
        if (modeNumber != activeModes[1]) {
          // Record them
          activeModes[2] = activeModes[1];
          activeModes[1] = activeModes[0];
          activeModes[0] = modeNumber;
        } else {
          // Exchange first and second
          activeModes[1] = activeModes[0];
          activeModes[0] = modeNumber;
        }
        for (int i = 0; i < inputData.length; i++) {
          recordedInputTwo[i] = recordedInputStatic[i];
          recordedInputStatic[i] = inputData[i];   
        }
      } else {
        // Remove the last, and move the pre-last to last:
        activeModes[2] = activeModes[1];
        activeModes[1] = 0;
        for (int i = 0; i < inputData.length; i++) {
          recordedInputTwo[i] = recordedInputStatic[i];
        }  
      }
      changingMode = true;
    }
    
    // Pause everything
    if (key == '0') {
      pauseComputation = !pauseComputation;
      if (pauseComputation) 
      {
        frameRate(1);
      } else {
        frameRate(60);
      }
    }
  }
}

void keyReleased() {
    // Recording:
    if (key == ' ') {
      recordingState += 1;
      if (recordingState > 3)
        recordingState = 0; // Stop replaying
      
      if (recordingState == 1) { // Start recording
        recordingIndex = 0;
        recordedData = new float[1000][9];
      }      
      if (recordingState == 2) { // Start replaying
        replayIndex = 0;
      }
      if (recordingState == 3) { // Start replaying with recorded background
        replayIndex = 0;
        activeModes[1] = activeModes[0];
      }
    }
    changingMode = false;
    
    println(activeModes);
    println(recordingState);
}
