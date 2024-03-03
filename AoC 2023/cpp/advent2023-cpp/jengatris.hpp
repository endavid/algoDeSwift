//
//  jengatris.hpp
//  advent2023-cpp
//
//  Created by David Gavilan Ruiz on 12/02/2024.
//

#ifndef jengatris_hpp
#define jengatris_hpp

#include <stdio.h>
#include <memory>
#include <vector>
#include <iostream>
#include <unordered_set>

namespace advent
{

template <typename T>
struct Vec3 {
    T x, y, z;
};

template <typename T>
struct AABB {
    T x0, y0, z0, x1, y1, z1;

    AABB(T x0, T y0, T z0, T x1, T y1, T z1);
    void moveDown();
};

template <typename T>
class VoxelVolume {
public:
    VoxelVolume(int width, int depth, int height);
    ~VoxelVolume();
    std::shared_ptr<VoxelVolume> copy() const;
    
    size_t index(int x, int y, int z) const {
        return y * width * depth + z * width + x;
    }
    void place(T value, AABB<int> aabb);
    void remove(AABB<int> aabb) {
        place(0, aabb);
    }
    std::unordered_set<T> collionsBelow(AABB<int> aabb) const;
private:
    VoxelVolume(const VoxelVolume&) = delete;
    VoxelVolume& operator=(const VoxelVolume&) = delete;
    
    int width, depth, height;
    T* data;
};

typedef std::vector< AABB<int> > IntAABBList;

class Jengatris
{
public:
    struct GameState
    {
        IntAABBList pieces;
        std::shared_ptr<VoxelVolume<int> > volume;
        
        GameState(IntAABBList pieces, std::shared_ptr<VoxelVolume<int> > volume);
        std::shared_ptr<GameState> copy() const;
        GameState(const GameState&) = delete;
        GameState& operator=(const GameState&) = delete;
    };
    
    Jengatris(std::istream& input);
    
    const GameState& getState() const {
        return state;
    }
    
    static std::shared_ptr<GameState> simulate(const GameState& start,
                                               const int removedId = 0,
                                               std::unordered_set<int>* outMoved = nullptr);
    static std::unordered_set<int> findEssentials(const GameState& state);
    // Part 2
    static size_t countFalls(const GameState& state, const std::unordered_set<int>& ids);
    static size_t countFallsThreaded(const GameState& state, const std::unordered_set<int>& ids);
    static size_t countFallsAsync(const GameState& state, const std::unordered_set<int>& ids);
    static size_t countFallsParallel(const GameState& state, const std::unordered_set<int>& ids);
    static size_t countFallsTBB(const GameState& state, const std::unordered_set<int>& ids);
    
private:
    GameState state;
};

}
#endif /* jengatris_hpp */
