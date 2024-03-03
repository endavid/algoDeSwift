//
//  main.cpp
//  advent2023-cpp
//
//  Created by David Gavilan Ruiz on 12/02/2024.
//

#include <iostream>
#include <fstream>
#include <chrono>
#include <functional>
#include "jengatris.hpp"

using namespace std;
using namespace advent;

double measure(const std::function<void()>& fn)
{
    auto start_time = std::chrono::high_resolution_clock::now();
    fn();
    auto end_time = std::chrono::high_resolution_clock::now();
    auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end_time - start_time);
    return duration.count() * 1e-3; // microsecs to millisecs
}

int main(int argc, const char * argv[]) {
    if (argc <= 1)
    {
        cout << "Missing argument" << std::endl;
        return 1;
    }
    string filename(argv[1]);
    ifstream file(filename);
    if (!file.is_open()) {
        cerr << "Error opening file: " << filename << std::endl;
        return 1;
    }
    auto jenga = Jengatris(file);
    file.close();
    auto gameState = Jengatris::simulate(jenga.getState());
    auto essentials = Jengatris::findEssentials(*gameState);
    auto disposableCount = gameState->pieces.size() - essentials.size();
    cout << "There are " << disposableCount << " disposable pieces." << std::endl;
    // Part 2
    size_t n;
    auto elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFalls(*gameState, essentials);
    });
    cout << n << " bricks would fall. Took " << elapsed << " ms." << std::endl;
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsThreaded(*gameState, essentials);
    });
    cout << n << " bricks would fall. Took " << elapsed << " ms. (threads)" << std::endl;
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsAsync(*gameState, essentials);
    });
    cout << n << " bricks would fall. Took " << elapsed << " ms. (async)" << std::endl;
#ifndef __clang__
    // To test these, install TBB and compile with gcc, i.e.
    // > brew install tbb
    // > g++-13 -std=c++17 -O3 -Wall -Wextra -pedantic -o advent advent2023-cpp/*.cpp -ltbb -I/opt/homebrew/Cellar/tbb/2021.11.0/include/ -L/opt/homebrew/Cellar/tbb/2021.11.0/lib
    // > ./advent ../Resources/day22_input.txt
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsParallel(*gameState, essentials);
    });
    cout << n << " bricks would fall. Took " << elapsed << " ms. (parallel)" << std::endl;
    elapsed = measure([essentials, gameState, &n]() {
        n = Jengatris::countFallsTBB(*gameState, essentials);
    });
    cout << n << " bricks would fall. Took " << elapsed << " ms. (TBB)" << std::endl;
#endif
    return 0;
}
