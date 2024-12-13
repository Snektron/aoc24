config var input_path = "input/13";

use IO;
use LinearAlgebra;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

record machine {
    var a: (int, int);
    var b: (int, int);
    var p: (int, int);
}

iter input() {
    while true {
        var a_x, a_y: int;
        var b_x, b_y: int;
        var p_x, p_y: int;

        reader.readf("Button A: X+%i, Y+%i\n", a_x, a_y);
        reader.readf("Button B: X+%i, Y+%i\n", b_x, b_y);
        reader.readf("Prize: X=%i, Y=%i\n", p_x, p_y);

        yield new machine((a_x, a_y), (b_x, b_y), (p_x, p_y));

        if !reader.matchNewline() {
            break;
        }
    }
}

var part1: int;
var part2: int;
for m in input() {
    var x = Matrix(
        [m.a(0):real, m.b(0):real],
        [m.a(1):real, m.b(1):real]
    );

    var y1 = solve(x, Vector(m.p(0):real, m.p(1):real));

    var a1 = round(y1(0)):int;
    var b1 = round(y1(1)):int;
    if m.a(0) * a1 + m.b(0) * b1 == m.p(0) && m.a(1) * a1 + m.b(1) * b1 == m.p(1) {
        part1 += a1 * 3 + b1;
    }

    var p0 = m.p(0) + 10000000000000;
    var p1 = m.p(1) + 10000000000000;

    var y2 = solve(x, Vector(p0:real, p1:real));

    var a2 = round(y2(0)):int;
    var b2 = round(y2(1)):int;
    if m.a(0) * a2 + m.b(0) * b2 == p0 && m.a(1) * a2 + m.b(1) * b2 == p1 {
        part2 += a2 * 3 + b2;
    }
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);
