config var input_path = "input/03";

import IO;
use Regex;

var infile = IO.open(input_path, IO.ioMode.r);
var reader = infile.reader();

var re = new regex("do\\(\\)|don't\\(\\)|mul\\b\\((\\d{1,3}),(\\d{1,3})\\)");

var input: string;
var part1: int = 0;
var part2: int = 0;
var enabled = true;
while reader.readLine(input, stripNewline = true) {
    for item in re.matches(input, numCaptures = 2) {
        select input[item[0]] {
            when "do()" {
                enabled = true;
            }
            when "don't()" {
                enabled = false;
            }
            otherwise {
                var x = (input[item[1]] : int) * (input[item[2]] : int);
                part1 += x;
                if enabled {
                    part2 += x;
                }
            }
        }
    }
}

writeln("part 1: ", part1);
writeln("part 2: ", part2);
