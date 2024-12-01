config var input_path = "input/01";

import IO;
import Sort;

var infile = IO.open(input_path, IO.ioMode.r);
var reader = infile.reader(locking=false);

iter input() {
    var x, y: int;

    while reader.readf("%i %i", x, y) {
      yield (x, y);
    }
}

var inp = input();

var ls = Sort.sorted([(l, r) in inp] l);
var rs = Sort.sorted([(l, r) in inp] r);
var dists = abs(rs - ls);
writeln("part 1: ", + reduce dists);

var max = max reduce([max reduce ls, max reduce rs]);
var hist: [0..max] int = 0;
[r in rs] hist[r] += 1;
[l in ls] l *= hist[l];

writeln("part 2: ", + reduce ls);
