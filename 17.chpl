config var input_path = "input/17";

use IO;
use List;
use Errors;
use BitOps;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var a, b, c: int;
reader.readf("Register A: %i\n", a);
reader.readf("Register B: %i\n", b);
reader.readf("Register C: %i\n\n", c);
reader.readLiteral("Program: ");

var program: list(int);
var x: int;
while reader.read(x) {
    program.pushBack(x);
    if !reader.matchLiteral(",") {
        break;
    }
}

proc combo(pc, a, b, c) {
    select program[pc + 1] {
        when 0, 1, 2, 3 {
            return program[pc + 1];
        }
        when 4 do return a;
        when 5 do return b;
        when 6 do return c;
    }

    halt("invalid operand");
}

var output: list(int);
var pc: int;
while pc < program.size {
    select program[pc] {
        when 0 do a >>= combo(pc, a, b, c);
        when 1 do b ^= program[pc + 1];
        when 2 do b = combo(pc, a, b, c) % 8;
        when 3 {
            if a != 0 {
                pc = program[pc + 1];
                continue;
            }
        }
        when 4 do b ^= c;
        when 5 do output.pushBack(combo(pc, a, b, c) % 8);
        when 6 do b = a >> combo(pc, a, b, c);
        when 7 do c = a >> combo(pc, a, b, c);
    }

    pc += 2;
}

writeln("part 1: ", ",".join([o in output] o:string));

proc iforo(off, ia) {
    var i = 0;

    while true {
        var a = i + (ia << 3);
        var b = 0;
        var c = 0;
        var pc = 0;
        var shift = 0;

        var j = off;
        while pc < program.size {
            select program[pc] {
                when 0 {
                    var s = combo(pc, a, b, c);
                    a >>= s;
                    shift += s;
                }
                when 1 do b ^= program[pc + 1];
                when 2 do b = combo(pc, a, b, c) % 8;
                when 3 {
                    if a == 0 {
                        return i + (ia << 3);
                    }
                    pc = 0;
                    continue;
                }
                when 4 do b ^= c;
                when 5 {
                    var x = combo(pc, a, b, c) % 8;
                    if program[j] != combo(pc, a, b, c) % 8 {
                        break;
                    }
                    j += 1;
                }
                when 6 do b = a >> combo(pc, a, b, c);
                when 7 do c = a >> combo(pc, a, b, c);
            }

            pc += 2;
        }

        i += 1;
    }

    halt("");
}

var part2: int;
for i in 0..<program.size by -1 {
    part2 = iforo(i, part2);
}

writeln("part 2: ", part2);
