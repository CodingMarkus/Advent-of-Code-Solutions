# Advent of Code 2022 Solutions

See [Advent of Code 2022](https://https://adventofcode.com/2022/) for details.

This is a collection of puzzle solutions implemented entirely as [POSIX](https://pubs.opengroup.org/onlinepubs/9699919799)-compliant shell scripts. The scripts use only the shell script syntax that any POSIX shell interpreter must support, and use only command line utilities whose presence is required by the POSIX standard. Also, when using command line utilities, only options documented in the POSIX standard are used, so these scripts should run on any POSIX-compatible system (e.g. FreeBSD, macOS, Linux, etc.).


- **Q.** Why shell scripts? Wouldn't it be much easier to solve the puzzles in \
\<*... insert your favorite programming language here ...*\>?

  - **A.** Of course it would be easier, but where would the fun be if it wasn't challenging? Just using Bash scripts would already make it much easier, but I wanted to show how powerful simple POSIX scripts can be.

    I also want to indirectly illustrate the problem that programming actually is a skill that many self-proclaimed programmers lack today.

- **Q.** What do you mean by self-declared programmers lack a skill?

  - **A.** Today's "programmers" get celebrated for solving one of these puzzles in a modern programming language, and proudly present their solutions in sophisticated, professional looking blog posts. Yet their solutions sometimes require 5 to 30 minutes of computing time on their state-of-the-art computer, which is only 2 years old, and from a few hundred MB to several GB of RAM.

    In comparison: None of my solutions takes more than 30 seconds on an 8+ year old computer or uses more than a few MB of memory, and that's despite the fact that almost every other scripting language is at least 100 times faster than a shell script, not to mention compiled languages. If your JavaScript, Rust, Python or Java solution is outperformed by a shell script in terms of speed and memory consumption, then you are not a programmer. Your solution in any of those languages should blow my script out of the water with ease.

    And to make matters worse, sometimes their solution is not even correct. It works randomly for their input data, but only because they made arbitrary assumptions that happen to apply to their input data, but which were not stated anywhere in the problem description and which do not apply to all input data. Each participant is given personalized input data, and when I try to solve the puzzle with my data using their code, the result is often wrong, while my implementation gives the correct result even with their input data, because my scripts are based solely on the problem description.

- **Q.** Then how would you define what a real programmer is or does?

  - **A.** Just because someone is able to formulate coherent English sentences, that does not make him a writer. And just because someone can write a few lines of program code or has already produced a small application, does not make him a programmer. To be a programmer means to understand a problem or a task, to work out a computer-aided solution or implementation for it and then to convey this solution to the computer in the form of program code so that the computer does the actual work in the end. Even many computer scientists fail to do this because they lack practical programming skills, and most non-graduate programmers often lack the theoretical knowledge of algorithms and data structures to write meaningful code.