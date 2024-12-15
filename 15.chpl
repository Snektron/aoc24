config var input_path = "input/15";

use IO;
use List;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var grid: list(bytes);

var line: bytes;
while reader.readLine(line, stripNewline=true) {
    if line == b"" {
        break;
    }

    grid.pushBack(line);
}

var instructions: bytes;
while reader.readLine(line, stripNewline=true) {
    instructions += line;
}

var w = grid[0].size;
var h = grid.size;

enum tile {
    wall,
    box,
    empty,
    box_l,
    box_r,
}

var input: [0..<w, 0..<h]tile;
var pos: (int, int);

for (row, i) in zip(grid, 0..) {
    for (c, j) in zip(row, 0..) {
        select c {
            when b"O".toByte() do input[j, i] = tile.box;
            when b"#".toByte() do input[j, i] = tile.wall;
            when b".".toByte() do input[j, i] = tile.empty;
            when b"@".toByte() {
                input[j, i] = tile.empty;
                pos = (j, i);
            }
        }
    }
}

var wideinput: [0..<(w * 2), 0..<h]tile;
for (x, y) in input.domain {
    select input[x, y] {
        when tile.box {
            wideinput[x * 2, y] = tile.box_l;
            wideinput[x * 2 + 1, y] = tile.box_r;
        }
        otherwise {
            wideinput[x * 2, y] = input[x, y];
            wideinput[x * 2 + 1, y] = input[x, y];
        }
    }
}
var widepos = pos * (2, 1);

proc part1() {
    proc get((x, y)) {
        if x >= 0 && x < w && y >= 0 && y < h {
            return input[x, y];
        }

        return tile.wall;
    }

    proc push(p, d) {
        var x = p + d;

        while true {
            select get(x) {
                when tile.box {
                    x += d;
                }
                when tile.wall {
                    return false;
                }
                when tile.empty {
                    input[x] = tile.box;
                    break;
                }
            }
        }

        input[p + d] = tile.empty;

        return true;
    }

    proc tryPushAndMove(d) {
        if push(pos, d) {
            pos += d;
        }
    }

    proc draw() {
        for y in 0..<h {
            for x in 0..<w {
                select get((x, y)) {
                    when tile.box do write("O");
                    when tile.wall do write("#");
                    when tile.empty {
                        if (x, y) == pos {
                            write("@");
                        } else {
                            write(".");
                        }
                    }
                }
            }
            writeln("");
        }
    }

    for inst in instructions {
        select inst {
            when b"^".toByte() do tryPushAndMove((0, -1));
            when b">".toByte() do tryPushAndMove((1, 0));
            when b"<".toByte() do tryPushAndMove((-1, 0));
            when b"v".toByte() do tryPushAndMove((0, 1));
        }
    }

    var part1: int;
    for p in input.domain {
        if get(p) == tile.box {
            part1 += p(1) * 100 + p(0);
        }
    }

    writeln("part 1: ", part1);
}

proc part2() {
    proc get((x, y)) {
        if x >= 0 && x < 2 * w && y >= 0 && y < h {
            return wideinput[x, y];
        }

        return tile.wall;
    }

    proc draw() {
        for y in 0..<h {
            for x in 0..< w * 2 {
                select get((x, y)) {
                    when tile.box_l do write("[");
                    when tile.box_r do write("]");
                    when tile.wall do write("#");
                    when tile.empty {
                        if (x, y) == widepos {
                            write("@");
                        } else {
                            write(".");
                        }
                    }
                }
            }
            writeln("");
        }
    }

    proc canPush(p, d): bool {
        if d(0) != 0 {
            // Horizontal push.
            var x = p + d;
            select get(x) {
                when tile.box_l, tile.box_r do return canPush(x, d);
                when tile.wall do return false;
                when tile.empty do return true;
            }
            return false;
        } else {
            // Vertical push.
            var x = p + d;
            select get(x) {
                when tile.box_l do return canPush(x, d) && canPush(x + (1, 0), d);
                when tile.box_r do return canPush(x, d) && canPush(x - (1, 0), d);
                when tile.wall do return false;
                when tile.empty do return true;
            }
            return false;
        }
    }

    proc push(p, d) {
        if d(0) != 0 {
            // Horizontal push.
            var x = p + d;
            select get(x) {
                when tile.box_l, tile.box_r {
                    push(x, d);
                    wideinput[x] = wideinput[p];
                }
                when tile.empty {
                    wideinput[x] = wideinput[p];
                }
            }
        } else {
            // Vertical push.
            var x = p + d;
            select get(x) {
                when tile.box_l {
                    push(x, d);
                    push(x + (1, 0), d);
                    wideinput[x] = wideinput[p];
                    wideinput[x + (1, 0)] = tile.empty;
                }
                when tile.box_r {
                    push(x, d);
                    push(x - (1, 0), d);
                    wideinput[x] = wideinput[p];
                    wideinput[x - (1, 0)] = tile.empty;
                }
                when tile.empty {
                    wideinput[x] = wideinput[p];
                }
            }
        }
    }

    proc tryPushAndMove(d) {
        if canPush(widepos, d) {
            push(widepos, d);
            widepos += d;
        }
    }

    for inst in instructions {
        // draw();
        // writeln("");
        select inst {
            when b"^".toByte() do tryPushAndMove((0, -1));
            when b">".toByte() do tryPushAndMove((1, 0));
            when b"<".toByte() do tryPushAndMove((-1, 0));
            when b"v".toByte() do tryPushAndMove((0, 1));
        }
    }

    // draw();

    var part2: int;
    for p in wideinput.domain {
        if get(p) == tile.box_l {
            part2 += p(1) * 100 + p(0);
        }
    }

    writeln("part 2: ", part2);
}

part1();
part2();
