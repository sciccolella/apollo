### rotate.c
Simple utility to rotate a set of queries w.r.t. a **single** reference sequence.
Based on non-optimized dynamic programming between the reference sequence and query·query (where · is string concatenation).
Checks for reverse-and-complement by aligning both versions of the query and selecting the best one (the one with lower score).

Time/RAM for 28 ~15kbp queries against a ~15kbp sequence: 5 minutes, 2GB.

```
gcc -O3 -Wall rotate.c -o rotate -lz
./rotate ref.fa queries.fa
```
