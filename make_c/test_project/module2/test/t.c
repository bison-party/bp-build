
#include <stdbool.h>
#include "other.h"
#include "module2/f2.h"

int run_mod2_test(void) {
    if (thing_plus_2() != THING + 2) {
        return 1;
    }

    return 0;
}
