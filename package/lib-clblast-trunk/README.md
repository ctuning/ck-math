URL: https://github.com/CNugteren/CLBlast
Branch: development

Grigori had problems compiling for Android target using Native Google NDK with GCC 4.9:
* some std:: functions are not available in NDK GCC 4.9
However seems that CrystaX NDK compiles this package fine.
