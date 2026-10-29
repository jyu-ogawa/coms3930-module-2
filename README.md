# coms3930-module-2: Interactive Device

Using a pushbutton, a potentiometer, and a joystick connected to a ESP-TFT, I make a task tracker. 

![Breadboard schematic](fritzing_img/module2_bb.png)

![Layout schematic of circuit][fritzing_img/module2_schem.png]

## Code - Design Choices
### To change the tracked tasks

### To change the available themes
Changing the following lines of code allows you to personalise the characteristics of your bubbles. 

### To change timing parameters
- ```const unsigned long themeCooldown = 350;```: determine the delay between x-axis movement to change the theme (default: 0.35s);
- ```const unsigned long resetHoldTime = 500;```: how long user has to hold joystick in y-axis direction to reset the tasks to uncompleted (default: 0.5s)
