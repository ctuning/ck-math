/*
 * Copyright (c) 2017 cTuning foundation.
 * See CK COPYRIGHT.txt for copyright details.
 *
 * SPDX-License-Identifier: BSD-3-Clause.
 * See CK LICENSE.txt for licensing details.
 */

// This is a test for Boost compiled under CK:
//
//  ck virtual `ck search env --tags=compiler,llvm,v5` `ck search env --tags=lib,boost` --shell_cmd='$CK_CXX_FULL_PATH $CK_COMPILER_FLAG_CPP11 boost_test.cpp -I$CK_ENV_LIB_BOOST_INCLUDE $CK_CXX_COMPILER_STDLIB -L$CK_ENV_LIB_BOOST_LIB $CK_ENV_LIB_BOOST_LFLAG_FILESYSTEM ; a.out'
//
//


#include <iostream>
#include <iomanip>
#include <boost/version.hpp>
#include <boost/filesystem.hpp>


int main()
{
    // Report the current Boost version
    std::cout
        << std::endl
        << "Currently using Boost version: "
        << BOOST_VERSION / 100000
        << "."
        << BOOST_VERSION / 100 % 1000
        << "."
        << BOOST_VERSION % 100
        << std::endl
        << std::endl;

    // Get the current directory
    auto path = boost::filesystem::current_path();
    std::cout << path << std::endl;

    // Print the content of the current directory
    for(auto &entry : boost::filesystem::directory_iterator(path))
    {
        std::cout << entry << std::endl;
    }

    return 0;
}
