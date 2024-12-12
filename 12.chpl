config var input_path = "input/12";

use ParallelIO;
use Errors;
use Map;
use List;

var input = readLinesAsBlockArray(input_path);

var h = input.size;
var w = input[0].size;

var seen: [0..<h, 0..<w]int = -1;
var size: [0..<h, 0..<w]int = 0;

proc dfs(id: int, y: int, x: int): (int, int) {
    if seen[y, x] >= 0 {
        return (0, 0);
    }

    seen[y, x] = id;

    var state: (int, int) = (0, 1);

    if x > 0 && input[y][x - 1] == input[y][x] {
        state += dfs(id, y, x - 1);
    } else {
        state[0] += 1;
    }

    if x < w - 1 && input[y][x + 1] == input[y][x] {
        state += dfs(id, y, x + 1);
    } else {
        state[0] += 1;
    }

    if y > 0 && input[y - 1][x] == input[y][x] {
        state += dfs(id, y - 1, x);
    } else {
        state[0] += 1;
    }

    if y < h - 1 && input[y + 1][x] == input[y][x] {
        state += dfs(id, y + 1, x);
    } else {
        state[0] += 1;
    }

    return state;
}

enum dir { n, w, s, e };

proc check(x, y, c) {
    if x >= 0 && x < w && y >= 0 && y < h {
        return input[y][x] == c;
    }

    return false;
}

var seen2: [0..h, 0..w][dir.n..dir.e]int;

proc border(sy, sx, c) {
    var x = sx;
    var y = sy;

    var m = 1 << (c.toByte() - 'A'.toByte());

    var fences = 0;

    var mask = 0;
    mask += check(x - 1, y - 1, c):int * 1;
    mask += check(x, y - 1, c):int * 2;
    mask += check(x - 1, y, c):int * 4;
    mask += check(x, y, c):int * 8;

    var d: dir;
    select mask {
        when 0b0111 do d = dir.w;
        when 0b1000 do d = dir.n;
        when 0b1001 do d = dir.n;
        otherwise {
            return 0;
        }
    }

    if (seen2[y, x][d] & m) != 0 {
        return 0;
    }

    do {
        mask = 0;
        mask += check(x - 1, y - 1, c):int * 1;
        mask += check(x, y - 1, c):int * 2;
        mask += check(x - 1, y, c):int * 4;
        mask += check(x, y, c):int * 8;

        seen2[y, x][d] |= m;

        var pd = d;

        select mask {
            when 0b0001 do d = dir.w;
            when 0b0010 do d = dir.n;
            when 0b0011 do d = dir.w;
            when 0b0100 do d = dir.s;
            when 0b0101 do d = dir.s;
            when 0b0110 {
                if d == dir.e {
                    d = dir.s;
                } else {
                    d = dir.n;
                }
            }
            when 0b0111 do d = dir.s;
            when 0b1000 do d = dir.e;
            when 0b1001 {
                if d == dir.n {
                    d = dir.e;
                } else {
                    d = dir.w;
                }
            }
            when 0b1010 do d = dir.n;
            when 0b1011 do d = dir.w;
            when 0b1100 do d = dir.e;
            when 0b1101 do d = dir.e;
            when 0b1110 do d = dir.n;
            otherwise {
                halt("oei");
            }
        };

        if d != pd {
            fences += 1;
        }

        select d {
            when dir.n do y -= 1;
            when dir.e do x += 1;
            when dir.s do y += 1;
            when dir.w do x -= 1;
        }
    } while (x, y) != (sx, sy);

    seen2[y, x][d] |= m;

    return fences;
}

var borders: list(int);
var regions: list(int);

var part1: int;
var id = 0;
for y in 0..<h {
    for x in 0..<w {
        if seen[y, x] < 0 {
            var (fences, region) = dfs(id, y, x);
            part1 += region * fences;

            borders.pushBack(border(y, x, input[y][x]));
            regions.pushBack(region);

            if x > 0 {
                borders[seen[y, x - 1]] += border(y, x, input[y][x - 1]);
            }

            id += 1;
        }
    }
}

var part2: int = + reduce [(b, r) in zip(borders, regions)] b * r;

writeln("part 1: ", part1);
writeln("part 2: ", part2);
