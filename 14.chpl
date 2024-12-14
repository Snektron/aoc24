config var input_path = "input/14";

use IO;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

record robot {
    var p: (int, int);
    var v: (int, int);
}

iter input() {
    while true {
        var p_x, p_y: int;
        var v_x, v_y: int;

        if !reader.readf("p=%i,%i v=%i,%i\n", p_x, p_y, v_x, v_y) {
            break;
        }

        yield new robot((p_x, p_y), (v_x, v_y));
    }
}

var robots = input();
var steps = 100;

var w, h: int;
if robots.size != 500 {
    w = 11;
    h = 7;
} else {
    w = 101;
    h = 103;
}

var q0, q1, q2, q3: int;
for r in robots {
    var x = (r.p + r.v * steps + (w, h) * steps) % (w, h);

    if x(0) < w / 2 {
        if x(1) < h / 2 {
            q0 += 1;
        } else if x(1) > h / 2 {
            q1 += 1;
        }
    } else if x(0) > w / 2 {
        if x(1) < h / 2 {
            q2 += 1;
        } else if x(1) > h / 2 {
            q3 += 1;
        }
    }
}

writeln("part 1: ", q0 * q1 * q2 * q3);

proc score(i) {
    var img: [0..<w, 0..<h]bool;

    proc get((x, y)) {
        if x < 0 || x >= w || y < 0 || y >= h {
            return false;
        }

        return img[x, y];
    }

    for r in robots {
        var x = ((r.p + r.v * i) % (w, h) + (w, h)) % (w, h);
        img[x] = true;
    }

    var s: int;
    for x in img.domain {
        if get(x) {
            if get(x + (0, -1)) {
                s += 1;
            }
            if get(x + (0, 1)) {
                s += 1;
            }
            if get(x + (-1, 0)) {
                s += 1;
            }
            if get(x + (1, 0)) {
                s += 1;
            }
        }
    }

    return s;
}

var (_, part2) = maxloc reduce zip([i in 0..<(w * h)] score(i), 0..<(w * h));
writeln("part 2: ", part2);

// var img: [0..<w, 0..<h]bool = false;
// for r in robots {
//     var x = ((r.p + r.v * part2) % (w, h) + (w, h)) % (w, h);
//     img[x] = true;
// }

// for y in 0..<h {
//     for x in 0..<w {
//         if img[x, y] {
//             write("#");
//         } else {
//             write(" ");
//         }
//     }
//     writeln("");
// }
