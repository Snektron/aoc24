config var input_path = "input/24";

use IO;
use Errors;
use Map;
use Set;
use Random;
use BitOps;
use Sort;
use List;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();
var bits: int;

var x, y: int;

while true {
    var gate: string;
    var value: int;
    reader.readf("%s %i\n", gate, value);
    gate = gate[0..<gate.size - 1];
    var bit = gate[1..]:int;

    if bit > bits {
        bits = bit;
    }

    if value == 1 {
        if gate[0] == 'x' {
            x |= 1 << bit;
        } else if gate[0] == 'y' {
            y |= 1 << bit;
        }
    }

    if reader.matchNewline() {
        break;
    }
}

bits += 1;

var exprs: map(string, (string, string, string));

{
    var a, op, b, trash, c: string;
    while reader.read(a, op, b, trash, c) {
        exprs[c] = (a, op, b);
    }
}

proc eval(x, y) {
    var state: map(string, int);
    var seen: set(string);

    proc get(gate): int {
        var result: int;
        if seen.contains(gate) {
            return -1;
        }

        if state.contains(gate) {
            result = state[gate];
        } else if gate[0] == 'x' {
            return (x >> gate[1..]:int) & 1;
        } else if gate[0] == 'y' {
            return (y >> gate[1..]:int) & 1;
        } else {
            seen.add(gate);
            var (a, op, b) = exprs[gate];
            var aa = get(a);
            var bb = get(b);
            if aa < 0 || bb < 0 {
                return -1;
            }
            select op {
                when "AND" do result = aa & bb;
                when "XOR" do result = aa ^ bb;
                when "OR" do result = aa | bb;
            }
            state[gate] = result;
            seen.remove(gate);
        }

        return result;
    }

    var result: int;
    for gate in exprs.keys() {
        if gate[0] == 'z' {
            var x = get(gate);
            if x < 0 {
                return -1;
            }
            result += x << gate[1..]:int;
        }
    }

    return result;
}

proc gatesOnPath(src, dst) {
    var seen: set(string);
    var gates: set(string);

    proc step(gate): bool {
        if seen.contains(gate) {
            return gates.contains(gate);
        }
        seen.add(gate);

        if gate == dst {
            return true;
        }

        if exprs.contains(gate) {
            var (a, _, b) = exprs[gate];
            var ok = false;
            ok = step(a) || ok;
            ok = step(b) || ok;
            if ok {
                gates.add(gate);
            }
            return ok;
        }

        return false;
    }

    step(src);
    return gates;
}

proc getGate(kind, bit) {
    return "%s%02i".format(kind, bit);
    // for gate in exprs.keys() {
    //     if gate[0] == kind && gate[1..]:int == bit {
    //         return gate;
    //     }
    // }

    // halt("unreachable");
}

proc check(minbits, maxbits=bits) {
    // for i in (minbits-2)..<bits by -1 {
    //     for j in i..<bits by -1 {
    //         var a = 1 << i;
    //         var b = 1 << j;
    //         var c = eval(a, b);
    //         if c != a + b {
    //             return false;
    //         }
    //     }
    // }

    for i in 0..<1000 {
        var values: [0..<2]int;
        fillRandom(values);
        var a = values[0];
        var b = values[1];
        a <<= minbits;
        b <<= minbits;
        a &= (1 << maxbits) - 1;
        b &= (1 << maxbits) - 1;
        var c = eval(a, b);
        if c != a + b {
            // writeln(a, " ", b, " | ", a + b, " ", c);
            return false;
        }
    }

    return true;
}

exprs["z38"] <=> exprs["dvq"];
exprs["z31"] <=> exprs["dmh"];
exprs["rpb"] <=> exprs["ctg"];
exprs["z11"] <=> exprs["rpv"];

writeln(check(0));

// for (z, (a, op, b)) in zip(exprs.keys(), exprs.values()) {
//     writeln(op, "_", a, "_", b, " [label=", op, ", shape=box];");
//     writeln(op, "_", a, "_", b, " -> ", z, ";");
//     writeln(a, " -> ", op, "_", a, "_", b, ";");
//     writeln(b, " -> ", op, "_", a, "_", b, ";");
// }

// var keys = exprs.keys();

// for k in (0)..<(keys.size - 1) {
//     for l in (k + 1)..<keys.size {
//         // exprs[keys[i]] <=> exprs[keys[j]];
//         exprs[keys[k]] <=> exprs[keys[l]];
//         if check(0) {
//             writeln("!!!! swapping ", keys[k], " ", keys[l]);
//             break;
//         }
//         exprs[keys[k]] <=> exprs[keys[l]];
//         // exprs[keys[i]] <=> exprs[keys[j]];
//     }
// }

// for i in 0..<bits by -1 {
//     for j in 0..<bits {
//         var a = 1 << i;
//         var b = 1 << j;
//         a <=> b;
//         var c = eval(a, b);
//         if c != a + b {
//             writeln("--- ", i);
//             var d = c ^ (a + b);
//             var bit_a = -1;
//             var bit_b = -1;
//             for k in 0..<bits {
//                 if d & (1 << k) {
//                     if bit_a == -1 {
//                         bit_a = k;
//                     } else {
//                         bit_b = k;
//                         break;
//                     }
//                 }
//             }

//             var gates_a = gatesOnPath(getGate('z', bit_a), getGate('x', i)) | gatesOnPath(getGate('z', bit_a), getGate('y', j)) | gatesOnPath(getGate('z', bit_a), getGate('y', i)) | gatesOnPath(getGate('z', bit_a), getGate('x', j));
//             var gates_b = gatesOnPath(getGate('z', bit_b), getGate('x', i)) | gatesOnPath(getGate('z', bit_b), getGate('y', j)) | gatesOnPath(getGate('z', bit_b), getGate('y', i)) | gatesOnPath(getGate('z', bit_b), getGate('x', j));
//             writeln(i, " ", j, " | ", a + b, " ", c, " -> ", bit_a, " ", bit_b);
//             writeln("gates a: ", gates_a);
//             writeln("gates b: ", gates_b);

//             var candidates: list((string, string));
//             for gate_a in gates_a {
//                 for gate_b in gates_b {
//                     if gate_a != gate_b {
//                         exprs[gate_a] <=> exprs[gate_b];

//                         if check(min(i, j)) {
//                             // writeln("aaaa ", gate_a, " ", gate_b);
//                             candidates.pushBack((gate_a, gate_b));
//                         }

//                         exprs[gate_a] <=> exprs[gate_b];
//                     }
//                 }
//             }

//             writeln("candidates: ", candidates);

//             if candidates.size == 1 {
//                 var a = candidates[0][0];
//                 var b = candidates[0][1];
//                 writeln("!!!! swapping ", a, " <=> ", b);
//                 // exprs[a] <=> exprs[b];
//             }
//         }
//     }
// }
