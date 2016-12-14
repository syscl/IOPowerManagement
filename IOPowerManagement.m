//
//  IOPowerManagement.m
//  IOPowerManagement
//
//  Created by lighting on 10/2/16.
//  Copyright ? 2016 syscl. All rights reserved.
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
void timeprint(LinkEntry *);
LinkEntry *addtmstamp(void);


typedef struct
{
    int fixedSize;
    int length;
    int begin;
    int end;
    unsigned long *queue;
} FixedQueueUlong;

FixedQueueUlong *FixedQueueUlong_new(int ln)
{
    FixedQueueUlong *obj = malloc(sizeof(FixedQueueUlong));
    obj->queue = malloc(ln * sizeof(unsigned long));
    obj->fixedSize = ln;
    obj->length = 0;
    obj->begin = 0;
    obj->end = 0;
    
    return obj;
}

void FixedQueueUlong_delete(FixedQueueUlong *obj)
{
    free(obj->queue);
    free(obj);
}

void FixedQueueUlong_enqueue(FixedQueueUlong *obj, unsigned long cnt)
{
    if (obj->length >= obj->fixedSize)
    {
        return;
    }
    
    obj->queue[obj->end] = cnt;
    obj->end = (obj->end + 1) % obj->fixedSize;
    obj->length += 1;
}

void FixedQueueUlong_forceEnqueue(FixedQueueUlong *obj, unsigned long cnt)
{
    if (obj->length < obj->fixedSize)
    {
        FixedQueueUlong_enqueue(obj, cnt);
        return;
    }
    
    obj->begin = (obj->begin + 1) % obj->fixedSize;
    obj->queue[obj->end] = cnt;
    obj->end = (obj->end + 1) % obj->fixedSize;
}

unsigned long FixedQueueUlong_dequeue(FixedQueueUlong *obj)
{
    if (obj->length <= 0)
    {
        return 0;
    }
    
    unsigned long r = obj->queue[obj->begin];
    obj->begin = (obj->begin + 1) % obj->fixedSize;
    obj->length -= 1;
    
    return r;
}

unsigned long FixedQueueUlong_get(FixedQueueUlong *obj, int i)
{
    if (i < 0)
    {
        i = obj->length + i;
    }
    if (i >= obj->length)
    {
        return 0;
    }
    
    int ri = (obj->begin + i) % obj->fixedSize;
    return obj->queue[ri];
}

void FixedQueueUlong_printAll(FixedQueueUlong *obj)
{
    for (int i = 0; i < obj->length; i += 1)
    {
        int j = (obj->begin + i) % obj->fixedSize;
        printf("%lu, ", obj->queue[j]);
    }
    putchar('\n');
}


int main(int argc, char **argv)
{
    const char *operatorIOPM[] = { "sleep", "shutdown", "restart", "logout" };
    unsigned int kIOPMEvents[] = { kAESleep, kAEShutDown, kAERestart, kAEReallyLogOut };
    const char **poperatorIOPM = operatorIOPM;
    unsigned int *pkIOPMEvents = kIOPMEvents;
    unsigned int *kPMEventPass;
    OSStatus ret               = noErr;
    unsigned long timeslic     = 0;
    FixedQueueUlong *queue     = FixedQueueUlong_new(CLOCKSIZE);
    
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
        // curr = addtmstamp();
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
            
            //altered 20161214
            //addtmstamp();
            FixedQueueUlong_forceEnqueue(queue, CFAbsoluteTimeGetCurrent());
            puts("queue contents: \n");
            FixedQueueUlong_printAll(queue);
            
            cntNotify++;
            
            //altered 20161214
            /*if (tail != head)
            {
                timeslic = curr->ticks - curr->prev->ticks;

            }*/
            timeslic = FixedQueueUlong_get(queue, -1) - FixedQueueUlong_get(queue, -2);
            
            if (timeslic > PREVENT_SLEEP_SLIC)  // no "=" included, for a more flexible/weak situation
            {
                ret = TransportEventSystemCall(*kPMEventPass);
                if (ret == noErr)
                {
                    printf("Computer is going to %s.\n", *poperatorIOPM);
                }
                else
                {
                    printf("Computer wouldn't %s.\n", *poperatorIOPM);
                }
            }
            
            sleep(hookIntervalSleep);
        }
        // timeprint(head);
    }
    
    printf("Usage:\n");
    printf("-shutdown:   halt system\n");
    printf("-sleep:      sleep system\n");
    printf("-logout:     logout system\n");
    printf("-restart:    restart system\n");
    
    FixedQueueUlong_delete(queue);
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

//
// Time management function
//
void timeprint(LinkEntry *time)
{
    if (isEmpty())
        return;

    if (tail->next == NULL)
    {
        //
        // not a circle
        //
        if (time != NULL)
        {
            if (time->next != NULL)
            {
                timeprint(time->next);
            }
        }
    }
    else
    {
        if (time->next != curr)
        {
            timeprint(time->next);
        }
    }
    printf("Time tick now is %lu\n", time->ticks);
}

LinkEntry *addtmstamp(void)
{
    if (isFull())
    {
        if (tail->next == NULL)
        {
            tail->next = head;
            head->prev = tail;
            curr       = head;
        }
        else
        {
            //
            // is circle
            //
            curr = curr->next;
        }
    }
    else
    {
        curr = malloc(sizeof(LinkEntry));
        
        if (head == NULL)
        {
            head = tail = curr;
            curr->prev  = NULL;
            curr->next  = NULL;
        }
        else
        {
            curr->next = NULL;
            curr->prev = tail;
            tail->next = curr;
            tail       = curr;
        }
    }
    //
    // update ticks
    //
    curr->ticks = CFAbsoluteTimeGetCurrent();
    cnt_add++;
    
    return curr;
}

bool isFull(void)
{
    return (cnt_add >= CLOCKSIZE);
}

bool isEmpty(void)
{
    return ((head == tail) && (cnt_add == 0));
}

unsigned int size(LinkEntry *tmp)
{
    if (tmp == NULL)
    {
        return 0;
    }
    return (1 + size(tmp->next));
}