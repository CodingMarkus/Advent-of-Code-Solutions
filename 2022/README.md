# Advent of Code 2022 Solutions

See [Advent of Code 2022](https://https://adventofcode.com/2022/) for details.

This is a collection of puzzle solutions implemented entirely as [POSIX](https://pubs.opengroup.org/onlinepubs/9699919799)-compliant shell scripts. The scripts use only the shell script syntax that any POSIX shell interpreter must support, and use only command line utilities whose presence is required by the POSIX standard. Also, when using command line utilities, only options documented in the POSIX standard are used, so these scripts should run on any POSIX-compatible system (e.g. FreeBSD, macOS, Linux, etc.).


- **Q.** Why shell scripts? Wouldn't it be much easier to solve the puzzles in \
\<*... insert your favorite programming language here ...*\>?

  - **A.** Of course it would be easier, but where would the fun be if it wasn't challenging? Just using Bash scripts would already make it much easier, but I wanted to show how powerful simple POSIX scripts can be.

    I also want to indirectly illustrate the problem that programming actually is a skill that many self-proclaimed programmers lack today.

- **Q.** What do you mean by self-declared programmers lack a skill?

  - **A.** Today's "programmers" get celebrated for solving one of these puzzles in a modern programming language, and proudly present their solutions in sophisticated, professional looking blog posts. Yet their solutions sometimes require 5 to 30 minutes of computing time on their state-of-the-art computer, which is only 2 years old, and from a few hundred MB to several GB of RAM.

    In comparison: None of my solutions takes more than 60 seconds on an 8+ year old computer (most only take a few seconds) or uses more than a few MB of memory, and that's despite the fact that almost every other scripting language is at least 100 times faster than a shell script, not to mention compiled languages. If your JavaScript, Rust, Python or Java solution is outperformed by a shell script in terms of speed and memory consumption, then you are not a programmer. Your solution in any of those languages should blow my script out of the water with ease.

    And to make matters worse, sometimes their solution is not even correct. It works randomly for their input data, but only because they made arbitrary assumptions that happen to apply to their input data, but which were not stated anywhere in the problem description and which do not apply to all input data. Each participant is given personalized input data, and when I try to solve the puzzle with my data using their code, the result is often wrong, while my implementation gives the correct result even with their input data, because my scripts are based solely on the problem description.

- **Q.** Then how would you define what a real programmer is or does?

  - **A.** Just because someone is able to formulate coherent English sentences, that does not make him a writer. And just because someone can write a few lines of program code or has already produced a small application, does not make him a programmer. To be a programmer means to understand a problem or a task, to work out a computer-aided solution or implementation for it and then to convey this solution to the computer in the form of program code so that the computer does the actual work in the end. Even many computer scientists fail to do this because they lack practical programming skills, and most non-graduate programmers often lack the theoretical knowledge of algorithms and data structures to write meaningful code.


## Puzzle Runtimes

```
Running day 01, part 1
Processing sample data took 0.00 seconds.
Processing input data took 0.02 seconds.

Running day 01, part 2
Processing sample data took 0.01 seconds.
Processing input data took 0.03 seconds.


Running day 02, part 1
Processing sample data took 0.00 seconds.
Processing input data took 0.08 seconds.

Running day 02, part 2
Processing sample data took 0.00 seconds.
Processing input data took 0.06 seconds.


Running day 03, part 1
Processing sample data took 0.04 seconds.
Processing input data took 1.04 seconds.

Running day 03, part 2
Processing sample data took 0.01 seconds.
Processing input data took 0.45 seconds.


Running day 04, part 1
Processing sample data took 0.04 seconds.
Processing input data took 6.91 seconds.

Running day 04, part 2
Processing sample data took 0.04 seconds.
Processing input data took 6.90 seconds.


Running day 05, part 1
Processing sample data took 0.09 seconds.
Processing input data took 11.57 seconds.

Running day 05, part 2
Processing sample data took 0.07 seconds.
Processing input data took 4.28 seconds.


Running day 06, part 1
Processing sample data took 0.03 seconds.
Processing input data took 4.70 seconds.

Running day 06, part 2
Processing sample data took 0.04 seconds.
Processing input data took 9.50 seconds.


Running day 07, part 1
Processing sample data took 0.07 seconds.
Processing input data took 3.81 seconds.

Running day 07, part 2
Processing sample data took 0.08 seconds.
Processing input data took 4.10 seconds.


Running day 08, part 1
Processing sample data took 0.01 seconds.
Processing input data took 0.86 seconds.

Running day 08, part 2
Processing sample data took 0.00 seconds.
Processing input data took 1.89 seconds.


Running day 09, part 1
Processing sample data took 0.01 seconds.
Processing input data took 0.47 seconds.

Running day 09, part 2
Processing sample data took 0.05 seconds.
Processing input data took 3.92 seconds.


Running day 10, part 1
Processing sample data took 0.00 seconds.
Processing input data took 0.00 seconds.

Running day 10, part 2
Processing sample data took 0.01 seconds.
Processing input data took 0.01 seconds.


Running day 11, part 1
Processing sample data took 0.06 seconds.
Processing input data took 0.14 seconds.

Running day 11, part 
Processing sample data took 4.38 seconds.
Processing input data took 22.05 seconds.


Running day 12, part 1
Processing sample data took 0.05 seconds.
Processing input data took 5.17 seconds.

Running day 12, part 2
Processing sample data took 0.04 seconds.
Processing input data took 4.65 seconds.


Running day 13, part 1
Processing sample data took 0.05 seconds.
Processing input data took 0.99 seconds.

Running day 13, part 2
Processing sample data took 0.08 seconds.
Processing input data took 3.30 seconds.


Running day 14, part 1
Processing sample data took 0.00 seconds.
Processing input data took 1.97 seconds.

Running day 14, part 2
Processing sample data took 0.01 seconds.
Processing input data took 4.95 seconds.


Running day 15, part 1
Processing sample data took 0.04 seconds.
Processing input data took 0.09 seconds.

Running day 15, part 2
Processing sample data took 0.21 seconds.
Processing input data took 0.11 seconds.


Running day 16, part 1
Processing sample data took 0.13 seconds.
Processing input data took 10.62 seconds.

Running day 16, part 2
Processing sample data took 6.33 seconds.
Processing input data took 6.24 seconds.


Running day 17, part 1
Processing sample data took 3.43 seconds.
Processing input data took 4.72 seconds.

Running day 17, part 2
Processing sample data took 3.79 seconds.
Processing input data took 16.20 seconds.


Running day 18, part 1
Processing sample data took 0.00 seconds.
Processing input data took 0.60 seconds.

Running day 18, part 2
Processing sample data took 0.05 seconds.
Processing input data took 2.28 seconds.
```
