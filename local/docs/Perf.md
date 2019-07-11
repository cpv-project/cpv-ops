# Perf examples

## record and report with call graph

``` text
perf record --call-graph dwarf -- ./CPVFrameworkTmp --task-quota-ms=20
perf report -g graph -n --sort=symbol
perf report -g graph -n --no-children --sort=symbol
```

