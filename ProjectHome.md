HOMEMADE AUTONOMOUS SENTRY GUN  ( paintball / airsoft )

Bob Rudolph - creator. Email me at sentryGun53@gmail.com.

This sentry gun uses an Arduino microcontroller, servo motors, a webcam, and a laptop to aim and fire an airsoft/paintball gun.

The laptop runs code in Processing (visit processing.org), which finds movement using background subtraction methods from the webcam, and then sends commands to the Arduino through a serial connection. The Arduino aims and fires the gun using servos.

Some people want to know - why Arduino? There are plenty of other projects out there that do the same thing, but use a serial servo controller instead. Well, I prefer the Arduino because a) I'm comfortable and used to it (weak reason i know) and b) because it allows room for all sorts of crazy expansion: from LCD screens and optical encoders, to simple switches and LED's; to manage everything on the sentry gun itself.
Version 5 has three switches. The "reload" switch overrides the current instructions from the computer, and moves the gun to a safe, convenient position for reffilling the paintball hopper. The "aim" switch just gives or takes power to the aiming servo's, and the "safe" switch is a power cut-off to the servo pulling the trigger. It also has some indicator LED's to tell the user what it's trying to do, or that it is properly communicating with the PC.
So try to do that with a servo controller.

For the most recent videos on this project, see my youtube page at http://www.youtube.com/user/SentryGun53 .



UPDATE 2-24-11
All new code versions will now be published at https://sites.google.com/site/projectsentrygun/downloads. Email me at sentryGun53@gmail.com with any questions.

UPDATE 12-29-10:
Complete Version 5 code is available in downloads section. New improvements include a new on-screen control layout, ability to handle semi-automatic and full-automoatic weapons, flexibility to use HD webcams, and cool sound effects from Portal.

UPDATE 12-18-10:
Version 5 is now built, video is coming soon. Demo targeting code is available in downloads section.

UPDATE 9-08-10:
Coming soon: a step-by-step video tutorial to make your own sentry gun! I will guide you through the process, while making a new sentry gun as an example. All steps and details, from building the base, to calibrating the final code, will be included. Expect this video, and new code, sometime in October.

UPDATE 5-23-10:
Version 4 code is now available on the Downloads section. A detailed description of the code can be found near the top of the Processing code. Video coming soon. Enjoy!

UPDATE 5-10-10:
Sucessfully implemented background subtraction. Code (version 4) to be published soon.
Additionally, fabricated a new base for the ASG using sheet metal, which is much more stable. The vertical servo also uses gearing, for more precise aiming, because a 180 degree vertical range is not necessary at present. I will put up a video on YouTube covering version 4.

UPDATE 4-07-10:
Schematic added in downloads area of project.
Version 3.7 is now available. It uses standard servos, not continuous rotation servos.
An example of Background Subtraction with JMyron is available. If anybody can combine this with the 3.7 code, please post finished code in wiki section. It must do blob processing on the product image from the background subtraction. thanks

UPDATE 4-01-10:
Source code is on the downloads page - this is very poor programming because I am new to it. Versions 2 and 3 coming soon, and I will also comment them.