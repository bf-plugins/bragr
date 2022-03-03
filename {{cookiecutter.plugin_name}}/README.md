## {{cookiecutter.plugin_name}}

{{cookiecutter.plugin_description}}

Author: {{cookiecutter.plugin_author}}

### Compiling your plugin

To build your plugin:

0) Setup your build environment (on topaz, run `source setup_env.sh`).
1) Add your source code to `src/`. Names must be `{{cookiecutter.__snake_name}}.h` and `{{cookiecutter.__snake_name}}.cu`.
2) compile with meson by running:

```
meson setup build
cd build
meson compile
```

### Using your plugin

```python
from build import {{cookiecutter.__snake_name}}_generated as _bf
_bf.init()
_bf.execute(data_in.as_BFarray(), data_out.as_BFarray())
```