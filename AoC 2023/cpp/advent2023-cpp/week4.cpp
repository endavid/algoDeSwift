//
//  week4.cpp
//  advent2023-cpp
//
//  Created by David Gavilan Ruiz on 04/03/2024.
//

#include <stdio.h>
#include <iostream>
#include "week4.hpp"
#include "jengatris.hpp"
#include "util.hpp"

namespace advent
{

void day22(std::istream& input)
{
    auto jenga = Jengatris(input);
    auto gameState = Jengatris::simulate(jenga.getState());
    auto essentials = Jengatris::findEssentials(*gameState);
    auto disposableCount = gameState->pieces.size() - essentials.size();
    std::cout << "There are " << disposableCount << " disposable pieces." << std::endl;
    // Part 2
    size_t n;
    auto elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFalls(*gameState, essentials);
    });
    std::cout << n << " bricks would fall. Took " << elapsed << " ms." << std::endl;
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsThreaded(*gameState, essentials);
    });
    std::cout << n << " bricks would fall. Took " << elapsed << " ms. (threads)" << std::endl;
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsAsync(*gameState, essentials);
    });
    std::cout << n << " bricks would fall. Took " << elapsed << " ms. (async)" << std::endl;
#ifndef __clang__
    // To test these, install TBB and compile with gcc, i.e.
    // > brew install tbb
    // > g++-13 -std=c++17 -O3 -Wall -Wextra -pedantic -o advent advent2023-cpp/*.cpp -ltbb -I/opt/homebrew/Cellar/tbb/2021.11.0/include/ -L/opt/homebrew/Cellar/tbb/2021.11.0/lib
    // > ./advent ../Resources/day22_input.txt
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsParallel(*gameState, essentials);
    });
    std::cout << n << " bricks would fall. Took " << elapsed << " ms. (parallel)" << std::endl;
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsTBB(*gameState, essentials);
    });
    std::cout << n << " bricks would fall. Took " << elapsed << " ms. (TBB)" << std::endl;
#endif
}

}
