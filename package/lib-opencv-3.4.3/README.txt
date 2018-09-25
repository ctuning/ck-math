Grigori had problems compiling OpenCV 3.2.0 for Android using CLANG from Android NDK 13 (issues with neon) ...

TBD:
 Windows path to lib is currently hardwired in meta as following:
   "win": "install\\x64\\vc14\\lib\\opencv_core.a"

 We should add x64 and vc14 definition via CK ...
