# Advent of Gleam 2024

Solutions for [Advent of Code 2024](https://adventofcode.com/2024) in [Gleam](https://gleam.run).

## Running
From the `advent_gleam` directory, run one of:

```sh
gleam run     # Run the project with the puzzle for the current day (based on system date)
gleam run <n> # Run the project with the puzzle for day n
gleam test    # Run the tests
```

## Building to an executable
To make an executable that can run on any machine that has erlang installed, run the `build.sh`
script to generate an executable using escript. See the
[documentation](https://gleam.run/writing-gleam/#sharing-your-program) for details.

## Inputs
Inputs should be put into the directory "input" in the root of the repository, using
name format "day00.txt". These files are not checked in to git as the organizers of
the Advent of Code have specified they may not be shared in this way.