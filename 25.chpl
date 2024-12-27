config var input_path = "input/25";

use IO;
use List;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var locks: list([0..4]int);
var keys: list([0..4]int);

var line: string;
while true {
    var is_lock = false;
    var lock_or_key: [0..4]int;
    for i in 0..6 {
        reader.readLine(line, stripNewline=true);
        if i == 0 && line[0] == '#' {
            is_lock = true;
        }
        for (j, k) in zip(line, 0..) {
            if j == '#' {
                lock_or_key[k] += 1;
            }
        }
    }

    [c in lock_or_key] c -= 1;

    if is_lock {
        locks.pushBack(lock_or_key);
    } else {
        keys.pushBack(lock_or_key);
    }

    if !reader.matchNewline() {
        break;
    }
}

var part1 = + reduce [l in locks] + reduce [k in keys] (&& reduce (l + k <= 5)):int;
writeln("part 1: ", part1);
