//
//  IOPowerManagement.m
//  IOPowerManagement
//
//  Created by lighting on 10/2/16.
//  Copyright © 2016 syscl. All rights reserved.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial
// 4.0 Unported License => http://creativecommons.org/licenses/by-nc/4.0
//

#include <stdio.h>
#include <stdlib.h>
#include <Carbon/Carbon.h>

//
// IOPMPowerSource
//
#include <IOKit/pwr_mgt/IOPM.h>
#import <IOKit/ps/IOPowerSources.h>

//
// syscl::Power keys
//
#include <CoreFoundation/CoreFoundation.h>
#include <IOKit/ps/IOPowerSources.h>
#include <IOKit/ps/IOPSKeys.h>

//
// syscl::header file
//
#include "IOPowerManagement.h"

//
// syscl::method to be defined
//
static OSStatus TransportEventSystemCall(AEEventID EventToSend);
int getBatteryPercentage(void);


int main(int argc, char **argv)
{
    const char *operatorIOPM[] = { "sleep", "shutdown", "restart", "logout" };
    unsigned int kIOPMEvents[] = { kAESleep, kAEShutDown, kAERestart, kAEReallyLogOut };
    const char **poperatorIOPM = operatorIOPM;
    unsigned int *pkIOPMEvents = kIOPMEvents;
    unsigned int *kPMEventPass;
    OSStatus ret               = noErr;
    
    //
    // release from infinite loop to prevent rescourse exhausted
    //
    if (argc >= 3)
    {
        releaseLock = true;
    }
    else if (argc == 1)
    {
        //
        // use default
        //
        printf("Computer is waiting to %s\n", *poperatorIOPM);
        *kPMEventPass = kIOPMEvents[0];
    }
    else
    {
        releaseLock = false;
    }
    
    
    while (--argc > 0 && (*++argv)[0] == '-')
    {
        char *pargv = ++argv[0];
        for (unsigned long i = 0; i < sizeof(operatorIOPM)/sizeof(operatorIOPM[0]); ++i)
        {
            if (strcmp(pargv, *poperatorIOPM) == 0)
            {
                //
                // sending IOPMEvent to system
                //
                kPMEventPass = pkIOPMEvents;
                printf("Computer is waiting to %s\n", *poperatorIOPM);
                break;
            }
            else
            {
                ++poperatorIOPM;
                ++pkIOPMEvents;
            }
        }
    }
    
    while (!releaseLock)
    {
        timeRemaining_seconds = IOPSGetTimeRemainingEstimate();
        batPercentage         = getBatteryPercentage();
        if ((timeRemaining_seconds > timeToSleep_seconds || timeRemaining_seconds <= 0) && batPercentage >= lowBatPercentage)
        {
            //
            // Time is enough or there's battery charger plugged-in
            //
            releaseLock = false;
            if (timeRemaining_seconds > 0)
            {
                printf("Battery time remaining is %d seconds\n", timeRemaining_seconds);
            }
            printf("Battery percentage is %d\n", batPercentage);
            sleep(hookIntervalTime);
        }
        else
        {
            //
            // Signal system to sleep/hibernation
            //
            ret = TransportEventSystemCall(*kPMEventPass);
            if (ret == noErr)
            {
                printf("Computer is going to %s.\n", *poperatorIOPM);
            }
            else
            {
                printf("Computer wouldn't %s.\n", *poperatorIOPM);
            }
            sleep(hookIntervalSleep);
        }
    }
    
    printf("Usage:\n");
    printf("-shutdown:   halt system\n");
    printf("-sleep:      sleep system\n");
    printf("-logout:     logout system\n");
    printf("-restart:    restart system\n");

    return 0;
}
       
OSStatus TransportEventSystemCall(AEEventID EventToSend)
{
    AEAddressDesc targetAEAddressDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = { typeNull, NULL };
    AppleEvent appleEventToSend = { typeNull, NULL };
    
    OSStatus ret = noErr;
    
    ret = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess,
                         sizeof(kPSNOfSystemProcess), &targetAEAddressDesc);
    
    if (ret != noErr)
    {
        return ret;
    }
    
    ret = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetAEAddressDesc,
                               kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);
    
    AEDisposeDesc(&targetAEAddressDesc);
    if (ret != noErr)
    {
        return ret;
    }
    
    ret = AESend(&appleEventToSend, &eventReply, kAENoReply,
                   kAENormalPriority, kAEDefaultTimeout, NULL, NULL);
    
    AEDisposeDesc(&appleEventToSend);
    if (ret != noErr)
    {
        return ret;
    }
    
    AEDisposeDesc(&eventReply);
    
    return ret;
}

int getBatteryPercentage(void)
{
    CFTypeRef  blob    = IOPSCopyPowerSourcesInfo();
    CFArrayRef sources = IOPSCopyPowerSourcesList(blob);
    int curCapacity;
    int maxCapacity;
    int batteryPercentage;
    
    CFDictionaryRef powerSource = NULL;
    const void *psValue;
    
    int refSources = CFArrayGetCount(sources);
    if (refSources == 0)
    {
        return 1;
    }
    
    for (int i = 0 ; i < refSources; ++i)
    {
        powerSource = IOPSGetPowerSourceDescription(blob, CFArrayGetValueAtIndex(sources, i));
        if (!powerSource)
        {
            return 2;
        }
        curCapacity = 0;
        maxCapacity = 0;
        
        psValue = (CFStringRef) CFDictionaryGetValue(powerSource, CFSTR(kIOPSNameKey));
        
        psValue = CFDictionaryGetValue(powerSource, CFSTR(kIOPSCurrentCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &curCapacity);
        
        psValue = CFDictionaryGetValue(powerSource, CFSTR(kIOPSMaxCapacityKey));
        CFNumberGetValue((CFNumberRef)psValue, kCFNumberSInt32Type, &maxCapacity);
        
        batteryPercentage = (int)(((double)curCapacity/(double)maxCapacity) * 100);
    }
    return batteryPercentage;
}
