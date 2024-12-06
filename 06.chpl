config var input_path = "input/06";

use IO;
use ParallelIO;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var input = readLinesAsBlockArray(input_path);

// Find the location of the guard
var sx, sy: int;
for (row, y) in zip(input, 0..) {
    for (c, x) in zip(row, 0..) {
        if c == '^' {
            sx = x;
            sy = y;
        }
    }
}

enum dir { n = 0, e = 1, s = 2, w = 3 };

var h = input.size;
var w = input[0].size;
var d = dir.n;
var seen: [input.domain][0..<w]bool;
var part1: int;
var gx = sx;
var gy = sy;

while true {
    if !seen[gy][gx] {
        seen[gy][gx] = true;
        part1 += 1;
    }

    var nx, ny: int;
    select d {
        when dir.n {
            nx = gx;
            ny = gy - 1;
        }
        when dir.e {
            nx = gx + 1;
            ny = gy;
        }
        when dir.s {
            nx = gx;
            ny = gy + 1;
        }
        when dir.w {
            nx = gx - 1;
            ny = gy;
        }
    }

    if nx < 0 || nx >= w || ny < 0 || ny >= h {
        break;
    }

    if input[ny][nx] == '#' {
        select d {
            when dir.n do d = dir.e;
            when dir.e do d = dir.s;
            when dir.s do d = dir.w;
            when dir.w do d = dir.n;
        }
    } else {
        gx = nx;
        gy = ny;
    }
}

writeln("part 1: ", part1);

proc hasLoop(x, y) {
    var gx = sx;
    var gy = sy;
    var seen: [input.domain][0..<w][dir.n..dir.w]bool;
    var d = dir.n;

    while true {
        if !seen[gy][gx][d] {
            seen[gy][gx][d] = true;
        } else {
            return true;
        }

        var nx, ny: int;
        select d {
            when dir.n {
                nx = gx;
                ny = gy - 1;
            }
            when dir.e {
                nx = gx + 1;
                ny = gy;
            }
            when dir.s {
                nx = gx;
                ny = gy + 1;
            }
            when dir.w {
                nx = gx - 1;
                ny = gy;
            }
        }

        if nx < 0 || nx >= w || ny < 0 || ny >= h {
            return false;
        }

        if (nx, ny) == (x, y) || input[ny][nx] == '#' {
            select d {
                when dir.n do d = dir.e;
                when dir.e do d = dir.s;
                when dir.s do d = dir.w;
                when dir.w do d = dir.n;
            }
        } else {
            gx = nx;
            gy = ny;
        }
    }

    return false;
}

var part2: atomic int;
coforall (y, x) in {0..<h, 0..<w} {
    if seen[y][x] && (sx, sy) != (x, y) && hasLoop(x, y) {
        part2.add(1);
    }
}

writeln("part 2: ", part2);
