config var input_path = "input/09";

use IO;
use List only list;
use Sort only sort;
use Heap only heap, defaultComparator, reverseComparator;

var infile = open(input_path, ioMode.r);
var reader = infile.reader();

var input: string;
reader.readLine(input, stripNewline=true);

// writeln(input);
var disk_map = [c in input] c : int;

// Calculate the total size first.
var n = + reduce disk_map;
var N = {0..<n};

var m = disk_map.size / 2;

// Create the disk explicitly
var disk: [N]int;
var file_offset: [0..m]int;
var gap_offset: [0..<m]int;
var i: int;
var j: int;
var is_file: bool = true;
for x in disk_map {
    if is_file {
        file_offset[i] = j;
        for k in 1..x {
            disk[j] = i;
            j += 1;
        }
        is_file = false;
    } else {
        gap_offset[i] = j;
        for k in 1..x {
            disk[j] = -1;
            j += 1;
        }
        is_file = true;
        i += 1;
    }
}
// writeln(disk);

// Now defrag the disk
i = 0;
j = n - 1;

while i < j {
    if disk[i] == -1 && disk[j] != -1 {
        disk[i] = disk[j];
        disk[j] = -1;
        i += 1;
        j -= 1;
    } else if disk[i] == -1 && disk[j] == -1 {
        j -= 1;
    } else /* disk[i] != -1 */ {
        i += 1;
    }
}

// Compute the checksum
var part1: int = + reduce [(x, i) in zip(disk[0..j], 0..)] x * i;
writeln("part 1: ", part1);

var file_size = disk_map[0.. by 2].reindex(0..m);
var gaps = disk_map[1.. by 2].reindex(0..<m);

// Create a free list of gaps.
var max_gap = max reduce gaps;

// For some reason creating an array of heaps doesn't work very well, so just use
// a list instead.
var free_lists: list(heap(int, false, reverseComparator(defaultComparator)));
for i in 0..max_gap {
    free_lists.pushBack(new heap(int, comparator=new reverseComparator()));
}

for (gap, go) in zip(gaps, gap_offset) {
    if gap > 0 {
        free_lists[gap].push(go);
    }
}

// Defrag from the free list.
var file = m;
var part2: int = 0;
while file >= 0 {
    var fz = file_size[file];
    var fo = file_offset[file];

    var offset = fo;
    var az: int;
    for z in fz..max_gap {
        if free_lists[z].size > 0 {
            var o = free_lists[z].top();
            if o < offset {
                offset = o;
                az = z;
            }
        }
    }

    if offset != fo {
        free_lists[az].pop();

        var remaining = az - fz;
        if remaining > 0 {
            free_lists[remaining].push(offset + fz);
        }

        free_lists[fz].push(fo);
    }

    for i in 0..<fz {
        part2 += (offset + i) * file;
    }

    file -= 1;
}

writeln("part 2: ", part2);
