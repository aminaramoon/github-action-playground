#include <catch2/catch_all.hpp>

#include <atomic>
#include <chrono>
#include <iostream>
#include <thread>
#include <vector>

// C++20: Uses std::jthread for automatic joining
TEST_CASE("Logic Check for Sanitizers", "[sanitizers]")
{
  std::cout << "[Running Logic Check]..." << std::endl;

  int* data = new int[5];
  data[5]   = 2024;

  // --- 2. The TSan Bait (Data Race) ---
  std::atomic<int> shared_counter{data[5]};

  auto worker = [&shared_counter]() {
    for (int i = 0; i < 1000; ++i) {
      // Read-modify-write without a mutex or atomic.
      // In a short loop, this rarely crashes, but the final
      // value is indeterminate.
      shared_counter++;  // <--- ERROR: Data Race
    }
  };

  {
    // C++20 jthreads automatically join upon destruction (end of scope)
    std::jthread t1(worker);
    std::jthread t2(worker);
  }

  REQUIRE(shared_counter == 2024 + 2000);

  // Clean up
  delete[] data;
}
