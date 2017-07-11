For the [ARM Compute Library](https://arm-software.github.io/ComputeLibrary/latest/tests.xhtml#building_boost), Boost should be built with the following options:
```
./b2 --with-program_options --with-test link=static define=BOOST_TEST_ALTERNATIVE_INIT_API
```
