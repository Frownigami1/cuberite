#!/bin/bash

# This script cross-compiles cuberite for the android platform. It uses
# the following enviroment variables
#   CMAKE: Should be the path to a cmake executable of version 3.7+
#   NDK: Should be the path to the android ndk root
#   (optional) TYPE: either Release or Debug, sets the build type

function usage() {
	echo "Usage: NDK=<path-to-ndk> CMAKE=<cmake-binary> $0 (clean|<ABI>)";
	exit 1
}

BASEDIR="$(realpath $(dirname $0))"
SELF="./$(basename $0)"

# Clean doesn't need CMAKE and NDK, so it's handled here
if [ "$1" == "clean" ]; then
	cd $BASEDIR
	rm -rf ../android-build/
	exit 0
fi

if [ -z "$CMAKE" -o -z "$NDK" ];then
	usage;
fi

# CMake wants absolute path
CMAKE="$(realpath $CMAKE)"
NDK="$(realpath $NDK)"

if [ -z "$TYPE" ]; then
	TYPE="Release"
fi

cd $BASEDIR

case "$1" in
	armeabi)
	APILEVEL=16
	;;

	armeabi-v7a)
	APILEVEL=16
	;;

	arm64-v8a)
	APILEVEL=21
	;;

	mips)
	APILEVEL=16
	;;

	mips64)
	APILEVEL=21
	;;

	x86)
	APILEVEL=16
	;;

	x86_64)
	APILEVEL=21
	;;

	all)
	echo "Packing server.zip"
	mkdir -p Server
	cd ../Server
	zip -r ../android/Server/server.zip *

	for arch in armeabi armeabi-v7a arm64-v8a mips mips64 x86 x86_64; do
		echo "Doing ... $arch ..." && \
		cd $BASEDIR && \
		"$SELF" clean && \
		"$SELF" "$arch" && \
		cd ../android-build && \
		make -j2 && \
		cd ../android/Server && \
		zip "$arch".zip Cuberite && \
		rm Cuberite
	done

	echo "Done! The built zip files await you in the Server/ directory"
	exit;
	;;

	*)
	usage;
	;;
esac

mkdir -p ../android-build
cd ../android-build
"$CMAKE" ../android -DCMAKE_SYSTEM_NAME=Android -DCMAKE_SYSTEM_VERSION="$APILEVEL" -DCMAKE_BUILD_TYPE="$TYPE" -DCMAKE_ANDROID_ARCH_ABI="$1" -DNATIVE_TOLUA_GENERATOR="Unix Makefiles" -DCMAKE_ANDROID_NDK="$NDK"