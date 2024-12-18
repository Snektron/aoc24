config var input_path = "input/18";

use IO;
use List;
use Heap;
use Sort;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var input: list((int, int));
{
    var x, y: int;
    while reader.readf("%i,%i\n", x, y) {
        input.pushBack((x, y));
    }
}

var is_example = input.size == 25;
var dim = if is_example then 7 else 71;
var n = if is_example then 12 else 1024;

record solution {
    var p: (int, int);
    var score: int;
}

record solutionComparator: relativeComparator { }

proc solutionComparator.compare(x, y) {
    return y.score - x.score;
}

proc isEmpty(grid, (x, y)) {
    if x < 0 || x >= dim || y < 0 || y >= dim {
        return false;
    }

    return !grid[y, x];
}

var part2: atomic int = max(int);
forall j in n..<input.size {
    var grid: [0..<dim, 0..<dim]bool;
    for i in 0..<j {
        grid[input[i]] = true;
    }

    var H = new heap(solution, comparator = new solutionComparator());
    H.push(new solution((0, 0), 0));
    var dist: [0..<dim, 0..<dim]int = max(int);
    while !H.isEmpty() {
        var s = H.pop();

        for d in [(0, 1), (0, -1), (1, 0), (-1, 0)] {
            var p = s.p + d;
            var score = s.score + 1;
            if isEmpty(grid, p) && score < dist[p] {
                dist[p] = score;
                H.push(new solution(p, score));
            }
        }
    }

    if dist[dim - 1, dim - 1] == max(int) {
        part2.min(j - 1);
    }

    if j == n {
        writeln("part 1: ", dist[dim - 1, dim - 1]);
    }
}

var (x, y) = input[part2.read()];
writeln("part 2: ", x, ",", y);
