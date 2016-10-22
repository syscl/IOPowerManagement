Fix low battery sleep/hibernation do not work issue for OS X/macOS for laptops
============

Well, as macOS/OS X has a very known issue that is, system cannot correctly
put itself into sleep/hibernation/shutdown when the battery level is lower than critical state. Once the battery is drained 
out, the system will halt instantly and cause data lose. So, I started this project with Objective-C 
to provide a better sleep mode for both Macbook and hackintosh laptops. This method is better than Apple's original low
battery policy, I will explain this later. 

And also, as it's name, it will provide more powerful/flexible power management functions/policies as you like to control
the system.

Notice: Kext version still need to be refined due to my intention. I want to make this project in a more general situation.

Since, I am too busy these days to finish assignments and my final exams will come soon, I may update my Github slow,
but I can assure you that great things will happen, and when they happen… they will happen here.

So now, let's turn to my work: IOPowerManagement.

How to use IOPowerManagement?
----------------

For Objective-C version(recommanded now):

Download the latest version installation package/directory by entering the following command in a terminal window:
```sh
git clone https://github.com/syscl/IOPowerManagement
```

Build the project by typing:
```sh
cd IOPowerManagement/
clang IOPowerManagement.m -fobjc-arc -fmodules -mmacosx-version-min=10.6 -o IOPowerManagement
```
Then place com.syscl.iopm.plist in /Library/LaunchDaemons/ by typing:
```sh
sudo cp -RX ./com.syscl.iopm.plist /Library/LaunchDaemons/
```

Installing both program and service for macOS by typing:
```sh
sudo cp -RX ./IOPowerManagement /etc
sudo launchctl load /Library/LaunchDaemons/com.syscl.iopm.plist 
```
Reboot to enjoy your macOS/OS X :)



For kext version, just place it under /Library/Extensions or /System/Library/Extensions by typing:
```sh
sudo cp -RX ./IOPowerDeploy.kext /Library/Extensions
```
or 
```sh
sudo cp -RX ./IOPowerDeploy.kext /System/Library/Extensions
```
Then load kext by typing:
```sh
sudo kextload /Library/Extensions/IOPowerDeploy.kext
```
or
```sh
sudo kextload /System/Library/Extensions/IOPowerDeploy.kext
```

Change Log
----------------
2016-10-22

- Released source code
- Optimised source code
- You can config IOPowerManagement through com.syscl.iopm instead of recompile it. Actually, I tend to like compile version, since config 
- will reduce the speed of the program.

2016-10-2

- Initial Commit
- Tested successfully on Dell Precision M3800. More improvements will be added soon
- Battery percentage routine comes into IOPowerManagement
