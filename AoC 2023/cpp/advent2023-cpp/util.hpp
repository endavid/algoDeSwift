//
//  util.hpp
//  advent2023-cpp
//
//  Created by David Gavilan Ruiz on 04/03/2024.
//

#ifndef util_hpp
#define util_hpp

#include <stdio.h>
#include <functional>

namespace advent {

double measure(const std::function<void()>& fn);

}

#endif /* util_hpp */
