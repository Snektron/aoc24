config var input_path = "input/08";

use ParallelIO;
use List;
use Map;
use Set;

var input = readLinesAsBlockArray(input_path, lineType=bytes);

var antennas: map(int(8), list((int, int)));

for (row, y) in zip(input, 0..) {
    for (c, x) in zip(row, 0..) {
        if c != b'.'.toByte() {
            antennas[c:int(8)].pushBack((x, y));
        }
    }
}

var h = input.size;
var w = input[0].size;

proc add((x, y), ref antinodes) {
    if x >= 0 && y >= 0 && x < w && y < h {
        if !antinodes.contains((x, y)) {
            antinodes.add((x, y));
        }
        return true;
    }
    return false;
}

var seen1: set((int, int));
var seen2: set((int, int));

for (freq, locations) in zip(antennas.keys(), antennas.values()) {
    for a in locations {
        for b in locations {
            if a != b {
                var d = a - b;

                add(a + d, seen1);

                for k in 0..max(w, h) {
                    if !add(a + d * k, seen2) {
                        break;
                    }
                }
            }
        }
    }
}

writeln("part 1: ", seen1.size);
writeln("part 2: ", seen2.size);
