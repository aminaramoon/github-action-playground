
function(enable_sanitizers target_name)

    if(NOT TARGET ${target_name})
        message(FATAL_ERROR "enable_sanitizers called on undefined target: ${target_name}")
    endif()

  message(STATUS "enabling stuff:")
  # 1. Define the option
  set(SANITIZERS "none" CACHE STRING "Select sanitizer: address, thread, undefined, leak, none")
  set_property(CACHE SANITIZERS PROPERTY STRINGS "none" "address" "thread" "undefined" "leak")

  if(SANITIZERS STREQUAL "none")
    message(STATUS "nothing was added:")
    return()
  endif()

  message(STATUS "Enabling sanitizer: ${SANITIZERS}")

  # 2. Define flags based on compiler
  set(SANITIZER_FLAGS "")
  
  if(CMAKE_CXX_COMPILER_ID MATCHES "Clang" OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    if(SANITIZERS STREQUAL "address")
        message(STATUS "adding asan")
      # ASan usually pairs well with UBSan
      list(APPEND SANITIZER_FLAGS "-fsanitize=address,undefined" "-fno-omit-frame-pointer")
    elseif(SANITIZERS STREQUAL "thread")
        message(STATUS "adding tsan")
      list(APPEND SANITIZER_FLAGS "-fsanitize=thread")
    elseif(SANITIZERS STREQUAL "undefined")
        message(STATUS "adding ubsan")
      list(APPEND SANITIZER_FLAGS "-fsanitize=undefined")
    elseif(SANITIZERS STREQUAL "leak")
        message(STATUS "adding lsan")
      list(APPEND SANITIZER_FLAGS "-fsanitize=leak")
    endif()
  else()
    message(FATAL_ERROR "Sanitizers are not supported with MSVC")
  endif()


    get_target_property(target_type ${target_name} TYPE)

    if(target_type STREQUAL "INTERFACE_LIBRARY")
        # Interface libraries cannot use PUBLIC, they must use INTERFACE
        target_compile_options(${target_name} INTERFACE ${SANITIZER_FLAGS})
        target_link_options(${target_name} INTERFACE ${SANITIZER_FLAGS})
    else()
        # Standard Executables / Static / Shared Libs
        target_compile_options(${target_name} PUBLIC ${SANITIZER_FLAGS})
        
        # Link options should be applied to the linker, NOT for Static libraries 
        # (Static libs are archives, they don't link).
        if(NOT target_type STREQUAL "STATIC_LIBRARY")
            target_link_options(${target_name} PUBLIC ${SANITIZER_FLAGS})
        else()
             # For static libs, we still want to pass the link flags to the consumer
             # via INTERFACE so the final executable links ASan correctly.
             target_link_options(${target_name} INTERFACE ${SANITIZER_FLAGS})
        endif()
    endif()

endfunction()