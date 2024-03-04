//
//  main.cpp
//  advent2023-cpp
//
//  Created by David Gavilan Ruiz on 12/02/2024.
//

#include <iostream>
#include <fstream>
#include <sstream>
#include <functional>
#include <map>
#include "jengatris.hpp"
#include "week4.hpp"

using namespace std;
using namespace advent;



string filename(const string& filepath)
{
    return filepath.substr(filepath.find_last_of('/') + 1);
}

string extractDay(const string& filepath)
{
    auto name = filename(filepath);
    return name.substr(0, name.find_last_of('_'));
}

int main(int argc, const char * argv[])
{
    if (argc <= 1)
    {
        cerr << "Missing argument" << std::endl;
        return 1;
    }
    string filepath(argv[1]);
    auto day = extractDay(filepath);
    if (day.empty())
    {
        cerr << "Can't parse day in " << filepath << ". File name should start with 'dayXX_'" << std::endl;
        return 1;
    }
    cout << "AoC 2023 " << day << std::endl;
    ifstream file(filepath);
    if (!file.is_open()) {
        cerr << "Error opening file: " << filepath << std::endl;
        return 1;
    }
    std::map<std::string, std::function<void(std::istream&)>> funcs = {
        { "day22", day22 }
    };
    if (funcs.find(day) == funcs.end()) {
        std::cerr << "Function not found: " << day << std::endl;
        file.close();
        return 1;
    }
    funcs[day](file);
    file.close();
    return 0;
}
