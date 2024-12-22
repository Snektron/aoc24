config var input_path = "input/22";

use ParallelIO;

var input = readLinesAsBlockArray(input_path);

proc next(v) {
    var x = v;
    x ^= x << 6;
    x &= 0xffffff;
    x ^= x >> 5;
    x &= 0xffffff;
    x ^= x << 11;
    x &= 0xffffff;
    return x;
}

var D = {-9..9, -9..9, -9..9, -9..9};
var part1: atomic int;
var total: [D] atomic int;
forall line in input {
    var seen: [D]bool;
    var seed = line:int;
    var b, c, d: int;
    for i in 0..<2000 {
        var prev = seed;
        seed = next(seed);
        var a = seed % 10 - prev % 10;
        var x = (d, c, b, a);
        if i >= 3 && !seen[x] {
            seen[x] = true;
            total[x].add(seed % 10);
        }

        d = c;
        c = b;
        b = a;
    }
    part1.add(seed);
}

writeln("part 1: ", part1);
writeln("part 2: ", max reduce [t in total] t.read());
