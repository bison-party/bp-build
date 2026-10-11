#pragma once

#ifndef MODULE1_OFFSET
#define MODULE1_OFFSET 0
#endif

/**
 * @brief An addition function.
 *
 * Performs addition of `x`, `y`, and `MODULE1_OFFSET`.
 *
 * @param x a number
 * @param y 
 *  another number
 *  __NOTE:__ A quick little note!
 * @return `x + y + MODULE1_OFFSET`
 */
int do_add(int x, int y);

/**
 * @brief get `THING`.
 * @return `THING`
 */
int get_thing(void);
