## plugger

A plugin template for the bifrost stream processing framework. 


### Compiling your plugin

To build your plugin:

0) Setup your build environment (on topaz, run `source setup_env.sh`).
1) add your source code to `src/`. Names must be `{plugin}.h` and `{plugin}.cu`.
2) compile with meson by running:

```
meson setup build
cd build
meson compile
```

### Using your plugin

```python
from build import {plugin}_generated as _bf
_bf.XcorrLite(data_in.as_BFarray(), data_out.as_BFarray())
```