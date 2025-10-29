# cmake-nRF5x/arm-gcc-toolchain.cmake
# Minimal, robust toolchain for ARM GCC (arm-none-eabi)

# Tell CMake we're cross-compiling for a bare-metal target.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# If user provides ARM_NONE_EABI_TOOLCHAIN_PATH, use it; otherwise default to /usr
if(NOT DEFINED ARM_NONE_EABI_TOOLCHAIN_PATH)
  set(ARM_NONE_EABI_TOOLCHAIN_PATH "/usr")
endif()

# Compilers
set(CMAKE_C_COMPILER   "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-g++")
set(CMAKE_ASM_COMPILER "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc")

# Detect real sysroot and gcc include folder from the compiler itself
execute_process(COMMAND "${CMAKE_C_COMPILER}" -print-sysroot
                OUTPUT_VARIABLE _GCC_SYSROOT
                OUTPUT_STRIP_TRAILING_WHITESPACE)
execute_process(COMMAND "${CMAKE_C_COMPILER}" -print-file-name=include
                OUTPUT_VARIABLE _GCC_INCLUDE
                OUTPUT_STRIP_TRAILING_WHITESPACE)

# Export for parent CMakeLists if needed
set(ARM_GCC_SYSROOT "${_GCC_SYSROOT}" CACHE INTERNAL "ARM GCC sysroot")
set(ARM_GCC_INCLUDE "${_GCC_INCLUDE}" CACHE INTERNAL "ARM GCC include")

# Use detected sysroot (only if not already forced by the caller)
if(NOT CMAKE_SYSROOT)
  set(CMAKE_SYSROOT "${ARM_GCC_SYSROOT}")
endif()

# Make sure try_compile does not try to link executables
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Global flags fix: inject proper sysroot and standard header paths once
foreach(lang C CXX ASM)
  set(_FLAGS_VAR "CMAKE_${lang}_FLAGS")
  set(${_FLAGS_VAR} "${${_FLAGS_VAR}} --sysroot=${CMAKE_SYSROOT} -isystem ${ARM_GCC_SYSROOT}/include -isystem ${ARM_GCC_INCLUDE}" CACHE STRING "" FORCE)
endforeach()

# Convenience var used by top-level CMakeLists
set(ARM_GCC_TOOLCHAIN "${ARM_NONE_EABI_TOOLCHAIN_PATH}" CACHE INTERNAL "Toolchain root")
