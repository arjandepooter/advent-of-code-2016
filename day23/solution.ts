import { readLines } from "https://deno.land/std@0.113.0/io/mod.ts";

type Register = "a" | "b" | "c" | "d";
type Opcode = "inc" | "dec" | "cpy" | "jnz" | "tgl";

type Instruction = {
  opcode: Opcode;
  arg1: Register | number;
  arg2: Register | number;
};

type Runtime = {
  pointer: number;
  program: Instruction[];
  registers: { [key in Register]: number };
};

const parseInstruction = (line: string): Instruction => {
  const parts = line.split(" ");
  const opcode = parts[0] as Opcode;
  const arg1 = parts[1];
  const arg2 = parts[2];
  const parsedArg1 = parseInt(arg1);
  const parsedArg2 = parseInt(arg2);

  return {
    opcode,
    arg1: isNaN(parsedArg1) ? (arg1 as Register) : parsedArg1,
    arg2: isNaN(parsedArg2) ? (arg2 as Register) : parsedArg2,
  };
};

const isRegister = (x: any): x is Register => typeof x !== "number";

const step = (runtime: Runtime) => {
  const instruction = runtime.program[runtime.pointer];

  switch (instruction.opcode) {
    case "dec": {
      if (isRegister(instruction.arg1)) {
        runtime.registers[instruction.arg1]--;
      }
      runtime.pointer++;
      break;
    }
    case "inc": {
      if (isRegister(instruction.arg1)) {
        runtime.registers[instruction.arg1]++;
      }
      runtime.pointer++;
      break;
    }
    case "cpy": {
      const value = isRegister(instruction.arg1)
        ? runtime.registers[instruction.arg1]
        : instruction.arg1;
      if (isRegister(instruction.arg2)) {
        runtime.registers[instruction.arg2] = value;
      }
      runtime.pointer++;
      break;
    }
    case "jnz": {
      const value = isRegister(instruction.arg1)
        ? runtime.registers[instruction.arg1]
        : instruction.arg1;
      const jump = isRegister(instruction.arg2)
        ? runtime.registers[instruction.arg2]
        : instruction.arg2;
      runtime.pointer += value !== 0 ? jump : 1;
      break;
    }
    case "tgl": {
      const idx =
        runtime.pointer +
        (isRegister(instruction.arg1)
          ? runtime.registers[instruction.arg1]
          : instruction.arg1);
      if (idx >= 0 && idx < runtime.program.length) {
        const dest = runtime.program[idx];
        if (dest.opcode === "inc") dest.opcode = "dec";
        else if (dest.opcode === "dec" || dest.opcode === "tgl")
          dest.opcode = "inc";
        else if (dest.opcode === "cpy") dest.opcode = "jnz";
        else dest.opcode = "cpy";
      }
      runtime.pointer++;
      break;
    }
    default:
      break;
  }
};

const runUntilFinished = (
  instructions: Instruction[],
  registerA: number
): number => {
  const runtime: Runtime = {
    pointer: 0,
    program: instructions,
    registers: {
      a: registerA,
      b: 0,
      c: 0,
      d: 0,
    },
  };

  while (runtime.pointer < runtime.program.length) {
    step(runtime);
  }

  return runtime.registers.a;
};

const cloneProgram = (program: Instruction[]): Instruction[] => [
  ...program.map((instruction) => ({ ...instruction })),
];

const program: Instruction[] = [];
for await (const instruction of readLines(Deno.stdin)) {
  program.push(parseInstruction(instruction));
}

console.log(runUntilFinished(cloneProgram(program), 7));
console.log(runUntilFinished(cloneProgram(program), 12));
