import processing.serial.*;

Serial myPort;  
String val = "";      

int NUM_TASKS = 3;  
int NUM_THEMES = 2; // 0: Minimalistic, 1: Aesthetic Dashboard
int TEXT_SIZE_MIN = 18;
String[] taskNames = {"Exercise", "Swift", "Reading"};

char[] taskStates; 
int activeTask = 0;
int activeTheme = 1; 

void setup() {
  size(400, 400); // Scaled down window size
  
  taskStates = new char[NUM_TASKS];
  for (int i = 0; i < NUM_TASKS; i++) {
    taskStates[i] = ' ';
  }

  printArray(Serial.list());
  String portName = Serial.list()[2];
  println(portName);
  myPort = new Serial(this, portName, 9600);
}

void draw() {
  // Read incoming serial data
  while (myPort.available() > 0) {  
    String rawData = myPort.readStringUntil('\n');
    
    if (rawData != null) {
      val = rawData.trim();
      String[] pieces = split(val, ',');
      
      // Expecting 4 pieces: TaskIndex, ButtonEvent, ThemeIndex, JoyYAction
      if (pieces.length >= 4 && pieces[3].length() > 0) {
        activeTask = int(pieces[0]);
        int buttonEvent = int(pieces[1]);
        activeTheme = int(pieces[2]) % NUM_THEMES; 
        int joyYAction = int(pieces[3]);
        
        if (activeTask >= 0 && activeTask < NUM_TASKS) {
          // Toggle individual task with push button
          if (buttonEvent == 1) {
            if (taskStates[activeTask] == 'X') {
              taskStates[activeTask] = ' '; 
            } else {
              taskStates[activeTask] = 'X'; 
            }
          }
        }
        
        // Reset all tasks when joystick Y-axis is pushed
        if (joyYAction == 1) {
          for (int i = 0; i < NUM_TASKS; i++) {
            taskStates[i] = ' ';
          }
        }
      }
    }
  }

  if (activeTheme == 0) {
    drawMinimalisticUI();
  } else {
    drawAestheticDashboardUI();
  }
}

// Design 0: Basic
void drawMinimalisticUI() {
  background(0); // black bg

  // Footer instruction
  textSize(10);
  fill(80);
  text("Use joystick left/right to change theme, Y-axis to clear", 25, 380);

  // Compact task list loop with current task highlighted
  for (int i = 0; i < NUM_TASKS; i++) {
    int yPos = 80 + (i * 35); // keep y-pos consistent
    
    if (i == activeTask) {
      fill(30, 144, 255); // Dodger Blue (match website design)
      textSize(TEXT_SIZE_MIN);
    } else {
      fill(255); // White
      textSize(TEXT_SIZE_MIN);
    }
    
    text(taskNames[i], 25, yPos);
    text("[" + taskStates[i] + "]", 280, yPos);
  }
}

// --- DESIGN 1: DETAILED & AESTHETIC DASHBOARD --- (incremented with Gemini)
void drawAestheticDashboardUI() {
  background(0, 25, 51);

  // 1. Task List Cards (Top section)
  for (int i = 0; i < NUM_TASKS; i++) {
    int boxY = 20 + (i * 85);
    
   
    
    rect(20, boxY, 360, 75, 8);

    noStroke();
    textSize(18);
    if (i == activeTask) {
      fill(255, 255, 255); 
    } else {
      fill(169, 177, 214); 
    }
    text(taskNames[i], 35, boxY + 45);
    
    if (taskStates[i] == 'X') {
      // box
      fill(158, 206, 106, 40); 
      stroke(158, 206, 106);
      strokeWeight(1);
      rect(265, boxY + 18, 100, 40, 6);
      
      // text
      textSize(13);
      fill(158, 206, 106);
      text("✓ DONE", 285, boxY + 43);
    } else {
      // box
      fill(0, 51, 102); 
      stroke(60, 64, 92);
      strokeWeight(1);
      rect(265, boxY + 18, 100, 40, 6);
      
      // text
      textSize(12);
      fill(120, 130, 160);
      text("PENDING", 282, boxY + 43);
    }
  }

  // 2. Control Bar / Header Container 
  // text
  textSize(12);
  fill(122, 162, 247); 
  text("PROGRESS", 35, 305);

  // Calculate completion percentage for progress bar
  int completedCount = 0;
  for (int i = 0; i < NUM_TASKS; i++) {
    if (taskStates[i] == 'X') completedCount++;
  }
  float progress = (float)completedCount / NUM_TASKS;

  // Progress Bar Background & Fill
  // progress bar bg blue
  fill(0, 51, 102);
  rect(35, 320, 180, 8, 4);
  // green progress 
  fill(158, 206, 106); 
  rect(35, 320, 180 * progress, 8, 4); // size based on progress (0 --> not visible)

  textSize(11);
  fill(150, 170, 200);
  text(int(progress * 100) + "% DONE", 225, 328); // size based on progress (0 --> not visible)

  // Extra helper text inside the bottom bar
  textSize(10);
  fill(120, 130, 160);
  text("Use joystick left/right to change theme, Y-axis to clear", 35, 358);
}
