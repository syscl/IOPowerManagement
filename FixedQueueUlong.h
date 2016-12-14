
#ifndef _FIXED_QUEUE_ULONG_H_
#define _FIXED_QUEUE_ULONG_H_

#include <stdlib.h>
#include <stdio.h>

typedef struct
{
    int fixedSize;
    int length;
    int begin;
    int end;
    unsigned long *queue;
} FixedQueueUlong;

FixedQueueUlong *FixedQueueUlong_new(int ln);
void FixedQueueUlong_delete(FixedQueueUlong *obj);
void FixedQueueUlong_enqueue(FixedQueueUlong *obj, unsigned long cnt);
void FixedQueueUlong_forceEnqueue(FixedQueueUlong *obj, unsigned long cnt);
unsigned long FixedQueueUlong_dequeue(FixedQueueUlong *obj);
unsigned long FixedQueueUlong_get(FixedQueueUlong *obj, int i);
void FixedQueueUlong_printAll(FixedQueueUlong *obj);

#endif
