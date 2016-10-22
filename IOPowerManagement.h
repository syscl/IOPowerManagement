//
//
// IOPowerManagement.h
// IOPowerManagement
//
//  Created by lighting on 10/2/16.
//  Copyright © 2016 syscl. All rights reserved.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial
// 4.0 Unported License => http://creativecommons.org/licenses/by-nc/4.0
//

#include <CoreServices/CoreServices.h>

//
// define main variables
//
const int bufferSize           = 256;
unsigned int hookIntervalTime  = 30;   // seconds unit;
unsigned int hookIntervalSleep = 150;  // seconds unit, must be 30 * n (n = 1, 2, ... )
int timeRemaining_seconds;
int batPercentage;                    // for int compare, elimante %
int lowBatPercentage           = 6;   // system default percentage
bool releaseLock     = false;
//
// Ohter variables that use to output
//
int timeRemaining_minutes;
int timeRemaining_hours;
int timeToSleep_seconds = 600;
int timeToSleep_minutes = 10;  // minutes unit
