
#include "module1/test/logic.h"
#include "module2/test/t.h"

int main(void) {
    return run_mod1_test() | run_mod2_test();
}
