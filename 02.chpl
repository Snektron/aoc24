config var input_path = "input/02";

import IO;
import Sort;
use List;

var infile = IO.open(input_path, IO.ioMode.r);
var reader = infile.reader();

iter input() {
    while true {
        var items: list(int(32));
        while !reader.matchNewline() {
            var x: int(32);
            if !reader.read(x) {
                return;
            }

            items.pushBack(x);
        }

        yield [i in items] i;
    }
}

proc is_safe(report) {
    var a = report[1..];
    var b = report[..report.size - 2];
    var ok_3 = && reduce ((abs(a - b) <= 3) & (abs(a - b) >= 1));
    var increasing = && reduce (a > b);
    var decreasing = && reduce (a < b);

    return ok_3 && (increasing || decreasing);
}

var inp = input();

var part1: atomic int(32) = 0;
var part2: atomic int(32) = 0;

coforall report in inp {
    var n = report.size;

    if is_safe(report) {
        part1.add(1);
        part2.add(1);
    } else {
        var actually_ok: atomic bool = false;
        coforall i in 0..n-1 {
            var z = for j in report.domain do if j != i then report[j];
            if is_safe(z) {
                actually_ok.write(true);
            }
        }

        part2.add(actually_ok.read());
    }
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);
