config var input_path = "input/16";

use ParallelIO;
use Heap;
use Sort;
use List;

var input = readLinesAsBlockArray(input_path, lineType=bytes);

var start: (int, int);
var end: (int, int);
for (row, y) in zip(input, 0..) {
    for (c, x) in zip(row, 0..) {
        if c == b'S'.toByte() {
            start = (x, y);
        } else if c == b'E'.toByte() {
            end = (x, y);
        }
    }
}

var h = input.size;
var w = input[0].size;

record entry {
    var p: (int, int);
    var d: (int, int);
    var score: int;
    var path: int;
}

record entryComparator: relativeComparator { }

proc entryComparator.compare(x, y) {
    return y.score - x.score;
}

record node {
    var p: (int, int);
    var next: int;
}

proc isEmpty((x, y)) {
    if x < 0 || x >= w || y < 0 || y >= h {
        return false;
    }

    return input[y][x] != b'#'.toByte();
}

var H = new heap(entry, comparator=new entryComparator());
H.push(new entry(start, (1, 0), 0, 0));

var nodes: list(node);
nodes.pushBack(new node(start, -1));

var dist: [0..<w, 0..<h, 0..<4]int = max(int);

var paths: list(entry);

while !H.isEmpty() {
    var e = H.pop();
    if e.p == end {
        paths.pushBack(e);
        continue;
    }

    for d in [(0, 1), (0, -1), (1, 0), (-1, 0)] {
        var p = e.p + d;
        var rr = (p(0), p(1), (d(0) + 1) * 2 + (d(1) + 1));
        if isEmpty(p) {
            var new_score = e.score + if d == e.d then 1 else 1001;
            if new_score <= dist[rr] {
                dist[rr] = new_score;
                nodes.pushBack(new node(p, e.path));
                H.push(new entry(p, d, new_score, nodes.size - 1));
            }
        }
    }
}

var part1 = min reduce dist[end(0), end(1), ..];
writeln("part 1: ", part1);

var g: [0..<w, 0..<h]bool;
for e in paths {
    if e.score != part1 {
        continue;
    }

    var n = e.path;
    while n >= 0 {
        g[nodes[n].p] = true;
        n = nodes[n].next;
    }
}

var part2: int = + reduce ([x in g] x:int);
writeln("part 2: ", part2);
