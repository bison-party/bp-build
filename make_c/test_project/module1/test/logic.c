
#include <stdbool.h>

#include "module1/logic.h"
#include "other.h"

int run_mod1_test(void) {
    if (do_add(get_thing(), 1) != THING + 1) {
        return 1;
    }

    return 0;
}
