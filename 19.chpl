config var input_path = "input/19";

use IO;
use List;
use Sort;
use Map;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var patterns: list(string);

{
    var pattern: string;
    while !reader.matchNewline() {
        reader.read(pattern);
        if pattern.endsWith(",") {
            pattern = pattern[0..<pattern.size - 1];
        }
        patterns.pushBack(pattern);
    }
}

var designs: list(string);
{
    var design: string;
    while reader.read(design) {
        designs.pushBack(design);
    }
}

proc check(ref design, offset, ref seen): int {
    if seen.contains(offset) {
        return seen[offset];
    }

    if design.size == offset {
        return 1;
    }

    var a: int;
    for pattern in patterns {
        if design[offset..].startsWith(pattern) {
            a += check(design, offset + pattern.size, seen);
        }
    }

    seen[offset] = a;

    return a;
}

var part1: atomic int;
var part2: atomic int;
forall design in designs {
    var seen: map(int, int);
    var n = check(design, 0, seen);
    part1.add((n != 0):int);
    part2.add(n);
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);
