import sys
from collections import defaultdict
from itertools import count, cycle, islice
from typing import Dict, Iterator, List, Optional, Tuple, Union

Arg = Union[int, str, None]
Program = List[Tuple[str, Arg, Arg]]
Registers = Dict[str, int]
Pointer = int
Runtime = Tuple[Program, Registers, Pointer]


def parse_arg(c: str) -> Arg:
    try:
        return int(c)
    except:
        return c


def parse_input() -> Program:
    instructions = []

    for line in sys.stdin.readlines():
        parts = line.strip().split(" ")
        instructions.append(
            (
                parts[0],
                parse_arg(parts[1]),
                parse_arg(parts[2]) if len(parts) > 2 else None,
            )
        )

    return instructions


def is_valid(l1):
    return all(a == b for a, b in zip(l1, islice(cycle([0, 1]), 10)))


def run(runtime: Runtime) -> Iterator[int]:
    program, registers, pointer = runtime

    while 0 <= pointer < len(program):
        opcode, arg1, arg2 = program[pointer]
        if opcode == "cpy":
            value = arg1 if isinstance(arg1, int) else registers[arg1]
            registers[arg2] = value
            pointer += 1
        elif opcode == "inc":
            registers[arg1] += 1
            pointer += 1
        elif opcode == "dec":
            registers[arg1] -= 1
            pointer += 1
        elif opcode == "jnz":
            value = arg1 if isinstance(arg1, int) else registers[arg1]
            pointer += arg2 if value != 0 else 1
        elif opcode == "out":
            value = arg1 if isinstance(arg1, int) else registers[arg1]
            yield value
            pointer += 1
        else:
            pointer += 1


def solve_a(program: Program) -> int:
    for i in count():
        registers = defaultdict(int)
        registers["a"] = i
        result = run((program, registers, 0))

        if is_valid(result):
            return i


program = parse_input()
print(solve_a(program))
