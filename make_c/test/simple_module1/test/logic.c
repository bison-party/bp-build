
#include <stdbool.h>

#include "simple_module1/logic.h"

int test_logic(void) {
    int asm_res = do_asm_logic();

    if (do_logic(asm_res, asm_res) != 5) {
        return 1;
    }

    return 0;
}
