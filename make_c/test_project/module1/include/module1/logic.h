#pragma once

#ifndef MODULE1_OFFSET
#define MODULE1_OFFSET 0
#endif

/**
 * Returns `x + y + MODULE1_OFFSET`
 */
int do_add(int x, int y);

/**
 * Returns `THING` as defined in `other.h`.
 */
int get_thing(void);
