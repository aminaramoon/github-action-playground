add_executable(my_tests tests.cpp)

target_link_libraries(my_tests PRIVATE Catch2::Catch2WithMain Threads::Threads)
enable_sanitizers(my_tests)