cmake_minimum_required (VERSION 3.7)
project(Cuberite)
include(ExternalProject)

# Set up Android parameters
add_definitions(-DANDROID)
set(ANDROID TRUE)
set(CMAKE_POSITION_INDEPENDENT_CODE TRUE)
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fPIE -pie")

# We're crosscompiling for Android
set(NO_NATIVE_OPTIMIZATION TRUE)

# SYSTEM flag to silence warnings for external headers
include_directories(SYSTEM
	../lib/
	../src/
	../lib/jsoncpp/include/
	../lib/polarssl/include/
	../lib/sqlitecpp/include/
	../lib/sqlitecpp/sqlite3/
	../lib/libevent/include/
)

# Disable some compiler warnings (the lazy way out)
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-double-promotion")

# Compile a lua library for local architecture
externalproject_add(lua_native
	SOURCE_DIR ../lib/lua
	CMAKE_GENERATOR ${NATIVE_TOLUA_GENERATOR}
	CMAKE_ARGS
		-DANDROID_CROSSCOMPILE=TRUE
	BUILD_COMMAND
		${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
	INSTALL_COMMAND ""
)

# Get where it went in order to tell tolua
externalproject_get_property(lua_native BINARY_DIR)

# Compile a locally executable tolua binary
externalproject_add(tolua_native
	SOURCE_DIR ../lib/tolua++
	CMAKE_GENERATOR ${NATIVE_TOLUA_GENERATOR}
	CMAKE_ARGS
		-DANDROID_CROSSCOMPILE=TRUE
 		-DANDROID_LUA_DIR=${BINARY_DIR}
		-DCMAKE_RUNTIME_OUTPUT_DIRECTORY=<BINARY_DIR>
		-DCMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE=<BINARY_DIR>
	BUILD_COMMAND
		${CMAKE_COMMAND} --build <BINARY_DIR> --config Release
	INSTALL_COMMAND ""
)

# And get where it went in order to tell bindings generation
externalproject_get_property(tolua_native BINARY_DIR)

# Build the rest of the server
add_subdirectory(../ Cuberite)

get_directory_property(BindingOutputs DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../src/Bindings DEFINITION "BINDING_OUTPUTS")
add_custom_command(
	OUTPUT ${BindingOutputs}
	COMMAND ${BINARY_DIR}/tolua -L BindingsProcessor.lua -o Bindings.cpp -H Bindings.h AllToLua.pkg
	WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/../src/Bindings
)

# Perform gymnastics to be able to run bindings generation but with the tolua we just built
add_custom_target(BindingDependencies ALL DEPENDS ${BindingOutputs})

# Dependency order BindingDependencies (i.e. generation) -> tolua_native -> lua_native
add_dependencies(tolua_native lua_native)
add_dependencies(BindingDependencies tolua_native)
