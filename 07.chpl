config var input_path = "input/07";

use IO;
use ParallelIO;
use List;

record equation : readDeserializable {
    var target: int;
    var values: list(int);
}

proc ref equation.deserialize(reader, ref deserializer) throws {
    reader.read(this.target);
    reader.readLiteral(b":");
    var values: list(int);
    while reader.matchLiteral(b" ", ignoreWhitespace=false) {
        var x: int;
        reader.read(x);
        values.pushBack(x);
    }
    this.values = values;
}

proc check1(target, ref values, current, i): bool {
    if i == values.size {
        return current == target;
    }

    if current > target {
        // No way to make the target, so stop the search early.
        return false;
    }

    return
        check1(target, values, current * values[i], i + 1) ||
        check1(target, values, current + values[i], i + 1);
}

proc check2(target, ref values, current, i): bool {
    if i == values.size {
        return current == target;
    }

    if current > target {
        // No way to make the target, so stop the search early.
        return false;
    }

    var w: int;
    if values[i] < 10 {
        w = 10;
    } else if values[i] < 100 {
        w = 100;
    } else if values[i] < 1000 {
        w = 1000;
    } else {
        writeln("oef");
    }

    return
        check2(target, values, current * values[i], i + 1) ||
        check2(target, values, current + values[i], i + 1) ||
        check2(target, values, current * w + values[i], i + 1);
}


var input = readDelimitedAsBlockArray(input_path, t=equation);
var part1: atomic int;
var part2: atomic int;
coforall eq in input {
    if (check1(eq.target, eq.values, eq.values[0], 1)) {
        part1.add(eq.target);
    }
    if (check2(eq.target, eq.values, eq.values[0], 1)) {
        part2.add(eq.target);
    }
}
writeln("part 1: ", part1);
writeln("part 2: ", part2);
