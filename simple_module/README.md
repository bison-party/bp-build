# Simple Module

A simple module can be used to create a static archive files from a group of `.c`, `.S`, and `.h`
files.

## Organization

A simple module expects the following structure.

```
<module name>/
    include/
        <module name>/
            test/
                test_header_1.h
                test_header_2.h
                ...
            header_1.h
            header_2.h
            ...
    src/
        c_src_1.c
        c_src_2.c
        ...
        s_src_1.S
        s_src_2.S
        ...
    test/
        test_src_1.c
        test_src_2.c
        ...
    Makefile (includes simple_module.mk)
```

Some things to note:
* The module name of a simple module is inferred from its directory name.
* A simple module needs at least 1 source file. (This can be an assembly or C file)
* A simple module needs at least 1 test source file. (Test sources are always C files)
* When objects are compiled, their names are mangled to prevent collision of object files. 
A `src/file.c`, `src/file.S`, and `test/file.c` can all be declared within a single module without
any issues!

