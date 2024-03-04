//
//  util.cpp
//  advent2023-cpp
//
//  Created by David Gavilan Ruiz on 04/03/2024.
//

#include "util.hpp"
#include <chrono>

namespace advent
{

double measure(const std::function<void()>& fn)
{
    auto start_time = std::chrono::high_resolution_clock::now();
    fn();
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
    return duration.count() * 1e-3; // microsecs to millisecs
}

}
