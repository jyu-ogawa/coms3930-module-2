
// Button Pin
#define BUTTON_PIN 15
// Potentiometer Pin
#define POT_PIN 13  
// Joystick Pins
#define JOY_X_PIN 39
#define JOY_Y_PIN 32
#define JOY_BTN_PIN 33

const int NUM_TASKS = 3;  // Pre-defined # of tasks
const int NUM_THEMES = 2; // 0: Minimalistic, 1: Aesthetic Dashboard

int activeTheme = 0; // Start in the minimal theme

// Button + debouncing
volatile bool ButtonPressed = false;
unsigned long lastPressTime = 0;
unsigned long debounceDelay = 200;

// Joystick + "debouncing"
bool joyMovedX = false;
unsigned long lastThemeChangeTime = 0;
const unsigned long themeCooldown = 350; 

// Hold to reset variables for Y-axis
unsigned long joyYPressStartTime = 0;
const unsigned long resetHoldTime = 500; // Must hold for 0.5 seconds to reset
bool resetTriggered = false;

void setup() {
  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(JOY_BTN_PIN, INPUT_PULLUP); 
  // Debounce implementation
  attachInterrupt(digitalPinToInterrupt(BUTTON_PIN), pressedButton, FALLING);
  Serial.begin(9600);
}

void pressedButton() { // Debounce button
  unsigned long currentTime = millis();
  if (currentTime - lastPressTime > debounceDelay) {
    lastPressTime = currentTime;
    ButtonPressed = true;
  }
}

void loop() {
  // Read potentiometer for task selection (ADC: 0 to 4095)
  int potValue = analogRead(POT_PIN);
  int currentTask = (potValue * NUM_TASKS) / 4096;
  if (currentTask >= NUM_TASKS) { // prevent Index Out of Bounds error
    currentTask = NUM_TASKS - 1;
  }

  // Read raw joystick values
  int joyX = analogRead(JOY_X_PIN);
  int joyY = analogRead(JOY_Y_PIN);
  unsigned long currentTime = millis();

  /* X-AXIS: Theme Switching
  !joyMovedX --> used to prevent the theme from rapid theme
    changes when moving left/right
    (delta t has to be greater than the themeCooldown 
    time defined in the beginning, 0.35s)
  */ 
  // Push to the left (<1400), decrease Theme (go to previous theme)
  if (joyX < 1400 && !joyMovedX && (currentTime - lastThemeChangeTime > themeCooldown)) {
    activeTheme--;
    if (activeTheme < 0) activeTheme = NUM_THEMES - 1;
    joyMovedX = true;
    lastThemeChangeTime = currentTime;
  } 
  // Push to the right (>2600), increase activeTheme (go to next theme)
  else if (joyX > 2600 && !joyMovedX && (currentTime - lastThemeChangeTime > themeCooldown)) {
    activeTheme++;
    if (activeTheme >= NUM_THEMES) activeTheme = 0;
    joyMovedX = true;
    lastThemeChangeTime = currentTime;
  }

  // Y-AXIS: Reset (Hold by 0.5s)
  int joyYAction = 0; 
  if (joyY < 1400 || joyY > 2600) { // Push up or down
    if (joyYPressStartTime == 0) {
      joyYPressStartTime = currentTime; // Start the timer when first pushed
    } else if (!resetTriggered && (currentTime - joyYPressStartTime >= resetHoldTime)) {
      joyYAction = 1; // Trigger reset only after holding long enough
      resetTriggered = true; // Lock so it only triggers once per hold
    }
  } else {
    // Reset timer and trigger flag when stick returns to the center zone
    joyYPressStartTime = 0;
    resetTriggered = false;
  }

  // Reset X-axis lock when stick returns safely to the center zone
  if (joyX >= 1800 && joyX <= 2200) {
    joyMovedX = false; 
  }

  // Check push button event (Pin 15)
  int buttonEvent = 0;
  if (ButtonPressed) {
    ButtonPressed = false;
    buttonEvent = 
  }

  // Send packet to serial communication (Processing): "TaskIndex,ButtonEvent,ThemeIndex,JoyYAction"
  Serial.print(currentTask);
  Serial.print(",");
  Serial.print(buttonEvent);
  Serial.print(",");
  Serial.print(activeTheme);
  Serial.print(",");
  Serial.println(joyYAction);
  // CSV style

  delay(50); 
}