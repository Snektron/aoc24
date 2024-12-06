config var input_path = "input/05";

use IO;
use Sort;
use List;
use LinearAlgebra;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var mat = Matrix(100, 100, bool);
var x, y: int;
while !reader.matchNewline() && reader.readf("%i|%i\n", x, y) {
    mat(x, y) = true;
}

record comparator : relativeComparator { }

proc comparator.compare(x, y) {
    return if mat[y, x] then -1 else 1;
}

proc check(update) {
    for i in 0..<update.size - 1 {
        if !mat[update[i], update[i + 1]] {
            return false;
        }
    }

    return true;
}

var update: list(int);
var part1 = 0;
var part2 = 0;
while true {
    if !reader.readf("%i", x) {
        break;
    }
    update.pushBack(x);

    if !reader.matchLiteral(",") {
        if check(update) {
            part1 += update[update.size / 2];
        } else {
            var ux = update;
            sort(ux, comparator=new comparator());
            part2 += ux[update.size / 2];
        }


        reader.readNewline();
        update.clear();
    }
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);
