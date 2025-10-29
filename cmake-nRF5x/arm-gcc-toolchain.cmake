# cmake-nRF5x/arm-gcc-toolchain.cmake
# Stabilna konfiguracja ARM GCC (arm-none-eabi) dla nRF52 + FreeRTOS/NimBLE.

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Root toolchainu
if(NOT DEFINED ARM_NONE_EABI_TOOLCHAIN_PATH)
  set(ARM_NONE_EABI_TOOLCHAIN_PATH "/usr")
endif()

# Kompilatory
set(CMAKE_C_COMPILER   "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc")
set(CMAKE_CXX_COMPILER "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-g++")
set(CMAKE_ASM_COMPILER "${ARM_NONE_EABI_TOOLCHAIN_PATH}/bin/arm-none-eabi-gcc")

# Wykryj sysroot i folder include GCC (może być pusty sysroot w debian/ubuntu)
execute_process(COMMAND "${CMAKE_C_COMPILER}" -print-sysroot
                OUTPUT_VARIABLE _GCC_SYSROOT
                OUTPUT_STRIP_TRAILING_WHITESPACE)
if("${_GCC_SYSROOT}" STREQUAL "")
  if(EXISTS "/usr/arm-none-eabi")
    set(_GCC_SYSROOT "/usr/arm-none-eabi")
  elseif(EXISTS "/usr/lib/arm-none-eabi")
    set(_GCC_SYSROOT "/usr/lib/arm-none-eabi")
  endif()
endif()

execute_process(COMMAND "${CMAKE_C_COMPILER}" -print-file-name=include
                OUTPUT_VARIABLE _GCC_INCLUDE
                OUTPUT_STRIP_TRAILING_WHITESPACE)

set(ARM_GCC_SYSROOT "${_GCC_SYSROOT}" CACHE INTERNAL "ARM GCC sysroot")
set(ARM_GCC_INCLUDE "${_GCC_INCLUDE}" CACHE INTERNAL "ARM GCC include")

# Jeśli caller nie narzucił sysroota, użyj wykrytego
if(NOT CMAKE_SYSROOT AND ARM_GCC_SYSROOT)
  set(CMAKE_SYSROOT "${ARM_GCC_SYSROOT}")
endif()

# Upewnij się, że try_compile nie linkuje exe
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

# Dołącz poprawne ścieżki nagłówków standardowych C/C++
foreach(lang C CXX ASM)
  set(_FLAGS_VAR "CMAKE_${lang}_FLAGS")
  set(${_FLAGS_VAR}
      "${${_FLAGS_VAR}} --sysroot=${CMAKE_SYSROOT} -isystem ${ARM_GCC_SYSROOT}/include -isystem ${ARM_GCC_INCLUDE} -isystem /usr/arm-none-eabi/include -isystem /usr/lib/arm-none-eabi/include"
      CACHE STRING "" FORCE)
endforeach()

# Flaga pomocnicza
set(ARM_GCC_TOOLCHAIN "${ARM_NONE_EABI_TOOLCHAIN_PATH}" CACHE INTERNAL "Toolchain root")
