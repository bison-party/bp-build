#include "other.h"

    .text

.globl get_thing
get_thing:
    mov $THING, %eax
    ret

