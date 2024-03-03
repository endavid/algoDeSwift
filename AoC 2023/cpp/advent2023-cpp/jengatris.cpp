//
//  jengatris.cpp
//  advent2023-cpp
//
//  Created by David Gavilan Ruiz on 12/02/2024.
//

#include "jengatris.hpp"
#include <iostream>
#include <fstream>
#include <string>
#include <regex>
#include <vector>
#include <thread>
#include <numeric>
#include <future>
#include <algorithm>
#include <execution>
#ifndef __clang__
#include <tbb/parallel_reduce.h>
#include <tbb/blocked_range.h>
#endif

using namespace advent;

namespace
{
    Vec3<int> findMaxes(const IntAABBList& list)
    {
        Vec3<int> out { 0, 0, 0 };
        for (const auto& aabb : list)
        {
            if (aabb.x1 > out.x)
            {
                out.x = aabb.x1;
            }
            if (aabb.y1 > out.y)
            {
                out.y = aabb.y1;
            }
            if (aabb.z1 > out.z)
            {
                out.z = aabb.z1;
            }
        }
        return out;
    }
} // end anonymous namespace

template <typename T>
AABB<T>::AABB(T x0, T y0, T z0, T x1, T y1, T z1)
    : x0(x0), y0(y0), z0(z0), x1(x1), y1(y1), z1(z1)
{}

template <typename T>
void AABB<T>::moveDown() {
    y0 -= static_cast<T>(1);
    y1 -= static_cast<T>(1);
}

template <typename T>
VoxelVolume<T>::VoxelVolume(int width, int depth, int height)
: width(width)
, depth(depth)
, height(height)
, data(new T[width * depth * height])
{}

template <typename T>
VoxelVolume<T>::~VoxelVolume()
{
    delete[] data;
}

template <typename T>
std::shared_ptr<VoxelVolume<T> > VoxelVolume<T>::copy() const
{
    auto out = std::make_shared<VoxelVolume<T> >(width, depth, height);
    size_t size = width * depth * height;
    std::copy(data, data+size, out->data);
    return out;
}

template <typename T>
void VoxelVolume<T>::place(T value, AABB<int> aabb)
{
    for (int y = aabb.y0; y <= aabb.y1; y++)
    {
        for (int x = aabb.x0; x <= aabb.x1; x++)
        {
            for (int z = aabb.z0; z <= aabb.z1; z++)
            {
                data[index(x,y,z)] = value;
            }
        }
    }
}

template <typename T>
std::unordered_set<T> VoxelVolume<T>::collionsBelow(AABB<int> aabb) const
{
    int y = aabb.y0 - 1;
    if (y == 0) {
        return {0};
    }
    std::unordered_set<int> colliders;
    for (int x = aabb.x0; x <= aabb.x1; x++)
    {
        for (int z = aabb.z0; z <= aabb.z1; z++)
        {
            auto c = data[index(x, y, z)];
            if (c != 0)
            {
                colliders.insert(c);
            }
        }
    }
    return colliders;
}

Jengatris::GameState::GameState(IntAABBList pieces, std::shared_ptr<VoxelVolume<int> > volume)
: pieces(pieces)
, volume(volume)
{}

std::shared_ptr<Jengatris::GameState> Jengatris::GameState::copy() const
{
    std::vector<AABB<int> > p(pieces.begin(), pieces.end());
    return std::make_shared<Jengatris::GameState>(p, volume->copy());
}

Jengatris::Jengatris(std::istream& input)
: state({}, nullptr)
{
    std::string line;
    std::regex pattern(R"((\d+),(\d+),(\d+)~(\d+),(\d+),(\d+))");
    while (std::getline(input, line)) {
        std::smatch matches;
        if (std::regex_match(line, matches, pattern) && matches.size() == 7) {
            int x0 = std::stoi(matches[1]);
            int z0 = std::stoi(matches[2]);
            int y0 = std::stoi(matches[3]);
            int x1 = std::stoi(matches[4]);
            int z1 = std::stoi(matches[5]);
            int y1 = std::stoi(matches[6]);
            state.pieces.emplace_back(AABB(x0, y0, z0, x1, y1, z1));
        }
    }
    auto maxes = findMaxes(state.pieces);
    state.volume = std::make_shared<VoxelVolume<int>>(maxes.x + 1, maxes.z + 1, maxes.y + 1);
    for (size_t i = 0; i < state.pieces.size(); i++)
    {
        int pieceId = static_cast<int>(i + 1);
        state.volume->place(pieceId, state.pieces[i]);
    }
}

std::shared_ptr<Jengatris::GameState> Jengatris::simulate(const GameState &start,
                                                          const int removedId,
                                                          std::unordered_set<int>* outMoved)
{
    auto out = start.copy();
    if (removedId > 0)
    {
        // Part 2
        auto aabb = out->pieces[removedId - 1];
        out->volume->remove(aabb);
    }
    int fallCount = 0;
    do {
        fallCount = 0;
        for (size_t i = 0; i<out->pieces.size(); i++)
        {
            int pieceId = static_cast<int>(i + 1);
            if (pieceId == removedId)
            {
                // Part 2
                continue;
            }
            auto aabb = out->pieces[i];
            auto colliders = out->volume->collionsBelow(aabb);
            if (colliders.empty())
            {
                fallCount += 1;
                out->volume->remove(aabb);
                out->pieces[i].moveDown();
                out->volume->place(pieceId, out->pieces[i]);
                if (outMoved != nullptr)
                {
                    // for Part 2
                    outMoved->insert(pieceId);
                }
            }
        }
    } while (fallCount > 0);
    return out;
}

/// These are pieces that if removed, something else will fall
std::unordered_set<int> Jengatris::findEssentials(const GameState& state)
{
    std::unordered_set<int> out;
    for (const auto& aabb : state.pieces)
    {
        auto colliders = state.volume->collionsBelow(aabb);
        if (colliders.size() == 1 && colliders.find(0) == colliders.end())
        {
            int pieceId = *colliders.begin();
            out.insert(pieceId);
        }
    }
    return out;
}

// MARK: Part 2

size_t Jengatris::countFalls(const GameState& state, const std::unordered_set<int>& ids)
{
    size_t sum = 0;
    for (const auto& id : ids)
    {
        std::unordered_set<int> moved;
        auto s = state.copy();
        auto _ = Jengatris::simulate(*s, id, &moved);
        sum += moved.size();
    }
    return sum;
}

size_t Jengatris::countFallsThreaded(const GameState &state, const std::unordered_set<int> &ids)
{
    std::vector<int> idArray(ids.begin(), ids.end());
    std::vector<size_t> counts(ids.size());
    std::vector<std::thread> threads;
    auto parallelWork = [&state, &idArray, &counts](int iteration) {
        int id = idArray[iteration];
        std::unordered_set<int> moved;
        auto s = state.copy();
        auto _ = Jengatris::simulate(*s, id, &moved);
        counts[iteration] = moved.size();
    };
    // this will start MANY threads!! (974 threads for my input)
    for (size_t i = 0; i < idArray.size(); i++)
    {
        threads.emplace_back(parallelWork, i);
    }
    // Wait for threads to finish
    for (auto& thread : threads) {
        thread.join();
    }
    return std::accumulate(counts.begin(), counts.end(), 0);
}

size_t Jengatris::countFallsAsync(const GameState &state, const std::unordered_set<int> &ids)
{
    std::vector<int> idArray(ids.begin(), ids.end());
    std::vector<std::future<size_t>> futures;
    auto parallelWork = [&state, &idArray](int iteration) {
        int id = idArray[iteration];
        std::unordered_set<int> moved;
        auto s = state.copy();
        auto _ = Jengatris::simulate(*s, id, &moved);
        return moved.size();
    };
    // Start asynchronous tasks
    for (size_t i = 0; i < idArray.size(); ++i) {
        futures.push_back(std::async(std::launch::async, parallelWork, i));
    }
    // Wait for tasks to finish and accumulate the results
    // When I put a breakpoint here, Xcode says there are 372 threads.
    // Still lots, but less than 974...
    size_t total = 0;
    for (auto& future : futures) {
        total += future.get();
    }
    return total;
}

size_t Jengatris::countFallsParallel(const GameState &state, const std::unordered_set<int> &ids)
{
#ifdef __clang__
    return 0;
#else
    return std::transform_reduce(
        std::execution::par,
        ids.begin(),
        ids.end(),
        size_t(0),
        std::plus<>(),
        [&state](int id) {
            std::unordered_set<int> moved;
            auto s = state.copy();
            auto _ = Jengatris::simulate(*s, id, &moved);
            return moved.size();
        }
    );
#endif
}

size_t Jengatris::countFallsTBB(const GameState &state, const std::unordered_set<int> &ids)
{
#ifdef __clang__
    return 0;
#else
    std::vector<int> idArray(ids.begin(), ids.end());
    size_t sum = tbb::parallel_reduce(
         tbb::blocked_range<size_t>(0, idArray.size()),
         size_t(0),
         [&](const tbb::blocked_range<size_t>& range, size_t localSum) {
             for (size_t i = range.begin(); i != range.end(); ++i) {
                 int id = idArray[i];
                 std::unordered_set<int> moved;
                 auto s = state.copy();
                 auto _ = Jengatris::simulate(*s, id, &moved);
                 localSum += moved.size();
             }
             return localSum;
         },
         std::plus<>()
     );
     return sum;
#endif
}
