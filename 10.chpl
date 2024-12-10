config var input_path = "input/10";

use ParallelIO;
use List;
use Set;

var input = readLinesAsBlockArray(input_path);

var h = input.size;
var w = input[0].size;

var seen1: [input.domain][0..<w]set((int, int));
var seen2: [input.domain][0..<w]int;

var fringe: list((int, int));

for (row, y) in zip(input, 0..) {
    for (c, x) in zip(row, 0..) {
        if c == '9' {
            fringe.pushBack((x, y));
            seen1[y][x].add((x, y));
            seen2[y][x] = 1;
        }
    }
}

var next_fringe: list((int, int));

proc add(x, y, ref tops, count, height) {
    if x >= 0 && y >= 0 && x < w && y < h && input[y][x] != '.' && input[y][x]:int == height {
        if seen2[y][x] == 0 {
            next_fringe.pushBack((x, y));
        }

        seen1[y][x] |= tops;
        seen2[y][x] += count;
    }
}

for height in 0..8 by -1 {
    for (x, y) in fringe {
        add(x + 1, y, seen1[y][x], seen2[y][x], height);
        add(x - 1, y, seen1[y][x], seen2[y][x], height);
        add(x, y + 1, seen1[y][x], seen2[y][x], height);
        add(x, y - 1, seen1[y][x], seen2[y][x], height);
    }

    fringe = next_fringe;
    next_fringe.clear();
}

var part1 = + reduce [(x, y) in fringe] seen1[y][x].size;
writeln("part 1: ", part1);

var part2 = + reduce [(x, y) in fringe] seen2[y][x];
writeln("part 2: ", part2);
