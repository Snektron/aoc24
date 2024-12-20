config var input_path = "input/20";

use ParallelIO;
use List;

var input = readLinesAsBlockArray(input_path, lineType=bytes);

var h = input.size;
var w = input[0].size;

var start: (int, int);
var end: (int, int);
for (x, y) in {0..<w, 0..<h} {
    var c = input[y][x];
    if c == b'S'.toByte() {
        start = (x, y);
    } else if c == b'E'.toByte() {
        end = (x, y);
    }
}

var dist: [0..<w, 0..<h]int = -1;
var path: list((int, int));
{
    var p = end;
    dist[p] = path.size;
    path.pushBack(p);
    while p != start {
        for d in [(-1, 0), (1, 0), (0, -1), (0, 1)] {
            var q = p + d;
            if input[q(1)][q(0)] != b'#'.toByte() && dist[q] == -1 {
                dist[q] = path.size;
                path.pushBack(q);
                p = q;
                break;
            }
        }
    }
}

var part1: atomic int;
var part2: atomic int;
forall i in 1..<path.size {
    var p = path[i];
    forall cheat in {-20..20, -20..20} {
        var cheat_time = abs(cheat(0)) + abs(cheat(1));
        if cheat_time <= 20 {
            var q = p + cheat;
            if q(0) >= 0 && q(0) < w && q(1) >= 0 && q(1) < h {
                var a = dist[q];
                var time_saved = i - a - cheat_time;
                if a != -1 && time_saved >= 100 {
                    if cheat_time <= 2 {
                        part1.add(1);
                    }
                    part2.add(1);
                }
            }
        }
    }
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);

// 2204978 - too high
