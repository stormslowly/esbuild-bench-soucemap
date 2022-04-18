## how to bench

### install esbuild

```bash
pnpm i
```

## bench

the same way of benching esbuild with [typescript](https://esbuild.github.io/faq/#benchmark-details)

### bench with sourcemap

```bash
make bench-sourcemap 2>&1  | grep Done -A 3
# or to view all output
make bench--sourcemap
```

### bench-without sourcemap

```bash
make bench-no-sourcemap 2>&1  | grep Done -A 3
# or to view all output
make bench-no-sourcemap
```

## result

* Model: MacBook Pro (13-inch, 2019, Four Thunderbolt 3 ports)
* CPU: 2.4 GHz Quad-Core Intel Core i5
* memory: 16 GB 2133 MHz LPDDR3


| Sourcemap |    Time |
|----------|--------:|
| use      |   0.18s |
| no-use   |   0.17s |



