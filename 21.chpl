config var input_path = "input/21";

use ParallelIO;
use List;
use Errors;
use Map;

var input = readLinesAsBlockArray(input_path);

var A = 10;

var keypad = [
    [ 7, 8, 9],
    [ 4, 5, 6],
    [ 1, 2, 3],
    [-1, 0, A],
];

var dirpad = [
    [-1, 0, A],
    [ 1, 2, 3]
];

proc keytomove(key) {
    select key {
        when 0 do return (0, -1);
        when 1 do return (-1, 0);
        when 2 do return (0, 1);
        when 3 do return (1, 0);
    }

    halt("invalid key for move");
}

proc getkeystart(const ref pad, key) {
    for (row, y) in zip(pad, 0..) {
        for (c, x) in zip(row, 0..) {
            if c == key {
                return (x, y);
            }
        }
    }

    return (-1, -1);
}

proc inbounds(const ref pad, (x, y)) {
    return x >= 0 && x < pad[0].size && y >= 0 && y < pad.size;
}

proc render(code) {
    for num in code {
        select num {
            when 0 do write("^");
            when 1 do write("<");
            when 2 do write("v");
            when 3 do write(">");
            when A do write("A");
        }
    }
    writeln("");
}

iter paths(p, const ref pad, key, ref seen, ref moves): list(int) {
    var (px, py) = p;
    var k = pad[py][px];

    if k == key {
        moves.pushBack(A);
        yield moves;
        moves.popBack();
    }

    seen[k] = true;
    for d in [0, 1, 2, 3] {
        var q = p + keytomove(d);
        var (qx, qy) = q;
        if inbounds(pad, q) && pad[qy][qx] >= 0 && !seen[pad[qy][qx]] {
            moves.pushBack(d);
            for m in paths(q, pad, key, seen, moves) {
                yield m;
            }
            moves.popBack();
        }
    }
    seen[k] = false;
}

proc allshortestpaths(start, end, const ref pad) {
    var p = getkeystart(pad, start);
    var shortest: list(list(int));
    if !inbounds(pad, p) {
        return shortest;
    }

    var seen: [0..A]bool;
    var moves: list(int);
    for m in paths(p, pad, end, seen, moves) {
        if shortest.size > 0 && m.size < shortest[0].size {
            shortest.clear();
        }

        if shortest.size == 0 || m.size <= shortest[0].size {
            shortest.pushBack(m);
        }
    }
    return shortest;
}

var allpaths_keypad = [(start, end) in {0..A, 0..A}] allshortestpaths(start, end, keypad);
var allpaths_dirpad = [(start, end) in {0..A, 0..A}] allshortestpaths(start, end, dirpad);

proc hashmoves(const ref moves) {
    var hash: int = moves.size;
    for m in moves {
        hash = hash * 12 + (m + 1);
    }
    return hash;
}

proc checkcodes(const ref moves, const ref allpaths_pad, depth, ref cache, first): int {
    var h = hashmoves(moves);
    if !first && cache.contains((h, depth)) {
        return cache[(h, depth)];
    }

    if depth == 0 {
        return moves.size;
    }

    var key = A;
    var total: int;
    for next in moves {
        var shortest = max(int);
        for nextmoves in allpaths_pad[key, next] {
            var count = checkcodes(nextmoves, allpaths_dirpad, depth - 1, cache, false);
            if count < shortest {
                shortest = count;
            }
        }
        total += shortest;
        key = next;
    }

    cache[(h, depth)] = total;
    return total;
}

var cache: map((int, int), int);
var part1: int;
var part2: int;
for code in input {
    var digits: list(int);
    for key in code[0..<code.size - 1] {
        digits.pushBack(key:int);
    }
    digits.pushBack(A);

    var value = code[0..<code.size - 1]:int;
    part1 += value * checkcodes(digits, allpaths_keypad, 3, cache, true);
    part2 += value * checkcodes(digits, allpaths_keypad, 26, cache, true);
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);
