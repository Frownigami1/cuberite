# Configure command:
# cmake . -DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION=16 -DCMAKE_BUILD_TYPE=Release -DCMAKE_ANDROID_ARCH_ABI=armeabi -DNATIVE_TOLUA_GENERATOR="" -DCMAKE_ANDROID_NDK=""
# -G "MinGW Makefiles" -DCMAKE_MAKE_PROGRAM="" may also be required on Windows

# Build command:
# cmake --build .

For additional ABI options, visit https://cmake.org/cmake/help/latest/variable/CMAKE_ANDROID_ARCH_ABI.html

The parameter NATIVE_TOLUA_GENERATOR should be a recognised CMake compiler, installed on the current system. It is used to compile a native (rather than Android) version of tolua which is used to generate bindings.

Windows users may make use of Visual Studio to compile for Android, but CMake requires the presence of Nvidia CodeWorks/Nsight Tegra, which can be a hassle to install. The easiest generator to use seems to be the NDK-bundled Make, to be specified as shown in the configure command above.

The minimum API level is 16 in the verbatim copy of this folder, due to the inclusion of position independent compilation. This can be changed.

On Linux, one may make use of one Compile.sh, which will insert these parameters into the configuration command and perform builds.