
#include "FixedQueueUlong.h"


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
