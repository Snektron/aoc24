config var input_path = "input/11";

use IO;
use Map;

var infile = IO.open(input_path, IO.ioMode.r);
var reader = infile.reader();

iter input() {
    var x: int;
    while reader.read(x) {
        yield x;
    }
}

proc halfbase(x) {
    if x < 10 {
        return 0;
    } else if x < 100 {
        return 10;
    } else if x < 1000 {
        return 0;
    } else if x < 10000 {
        return 100;
    } else if x < 100000 {
        return 0;
    } else if x < 1000000 {
        return 1000;
    } else if x < 10000000 {
        return 0;
    } else if x < 100000000 {
        return 10000;
    } else if x < 1000000000 {
        return 0;
    } else if x < 10000000000 {
        return 100000;
    } else if x < 100000000000 {
        return 0;
    } else if x < 1000000000000 {
        return 1000000;
    } else {
        return 0;
    }
}

proc stones(x: int, blinks: int, ref seen: map((int, int), int)): int {
    if blinks == 0 {
        return 1;
    }

    var y: int;
    var b = halfbase(x);
    if x == 0 {
        y = stones(1, blinks - 1, seen);
    } else if b != 0 {
        if seen.contains((x, blinks)) {
            return seen[(x, blinks)];
        }

        y = stones(x / b, blinks - 1, seen) + stones(x % b, blinks - 1, seen);

        seen[(x, blinks)] = y;
    } else {
        y = stones(x * 2024, blinks - 1, seen);
    }

    return y;
}

var part1: int;
var part2: int;

var seen: map((int, int), int);

for x in input() {
    part1 += stones(x, 25, seen);
    part2 += stones(x, 75, seen);
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);
