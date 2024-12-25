config var input_path = "input/23";

use IO;
use List;
use Errors;
use LinearAlgebra;
use Map;
use Set;
use Sort;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var nodes: map(string, int);
var inv_nodes: list(string);
var edges: list((int, int));

{
    try {
        while true {
            var x = reader.readThrough("-", stripSeparator=true);
            var y = reader.readThrough("\n", stripSeparator=true);

            var xx = nodes.size;
            if !nodes.add(x, xx) {
                xx = nodes[x];
            } else {
                inv_nodes.pushBack(x);
            }

            var yy = nodes.size;
            if !nodes.add(y, yy) {
                yy = nodes[y];
            } else {
                inv_nodes.pushBack(y);
            }

            edges.pushBack((xx, yy));

        }
    } catch e: EofError {
        // ignore
    } catch e {
        halt("unexpected error: ", e);
    }
}

var N: [0..<nodes.size]set(int);

var A = Matrix(nodes.size, nodes.size, int);
var B = Matrix(nodes.size, nodes.size, int);
var C = Matrix(nodes.size, nodes.size, int);
for (x, y) in edges {
    N[x].add(y);
    N[y].add(x);

    var xt = inv_nodes[x][0] == 't';
    var yt = inv_nodes[y][0] == 't';

    if xt && !yt || !xt && yt {
        A[x, y] = 1;
        A[y, x] = 1;
    } else if !xt && !yt {
        B[x, y] = 1;
        B[y, x] = 1;
    } else if xt && yt {
        C[x, y] = 1;
        C[y, x] = 1;
    }
}

var t_nt_nt = dot(dot(A, B), A);
var t_t_nt = dot(dot(C, A), A);
var t_t_t = dot(dot(C, C), C);

var part1 = 0;
part1 += + reduce diag(t_nt_nt) / 2;
part1 += + reduce diag(t_t_nt) / 2;
part1 += + reduce diag(t_t_t) / 2;
writeln("part 1: ", part1);

proc bk1(ref R, ref P, ref X, ref L) {
    if P.isEmpty() && X.isEmpty() {
        if R.size > L.size {
            L = R;
        }
    }

    for v in 0..<nodes.size {
        if !P.contains(v) {
            continue;
        }

        var PP = P;
        var XX = X;

        var added = !R.contains(v);
        R.add(v);

        XX &= N[v];
        PP &= N[v];

        bk1(R, PP, XX, L);

        if added {
            R.remove(v);
        }

        P.remove(v);
        X.add(v);
    }
}

var R: set(int);
var P: set(int);
var X: set(int);
var L: set(int);
for v in 0..<nodes.size {
    P.add(v);
}
bk1(R, P, X, L);

var clique = [v in L] inv_nodes[v];
sort(clique);

writeln(",".join(clique));
