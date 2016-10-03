Fix low battery sleep/hibernation do not work issue for OS X/macOS for laptops
============

Well, as hackintosh laptops have a very known issue on OS X/macOS. That is, system cannot correctly
put system into sleep/hibernation when the battery level is lower than 5%. Once the battery is drained 
out, the system will halt instantly and cause data lose. So, I started this project with objective-c 
to provide a better sleep mode for both Macbook and hackintosh laptops. This method is better than Apple's original low
battery policy, I will explain this later. 

And also, as it's name, it will provide more powerful/flexible power management functions/policies as you like to control
the system.

But at the very first beginning, let me upload the executable file first, I will upload source code later
for some personal reasons(some guys always make me annoying to comment some rubbish on my works, even worse, she/he stole my work to claim that she/he has a better solution!). So, I have to delay releasing my source 
    code.

Notice: I removed lines that are used to fix the issue due to my personal reasons I just said.

Since, I am too busy these days to finish assignments and 3 midterms this months, I may update my Github slow,
but I can assure you that great things will happen, and when they happen… they will happen here.

So now, let's turn to my work: IOPowerManagement.

How to use IOPowerManagement?
----------------

Will come soon in this months!

Change Log
----------------
2016-10-2

- Initial Commit
- Tested successfully on Dell Precision M3800. More improvements will be added soon
- Battery percentage routine comes into IOPowerManagement
