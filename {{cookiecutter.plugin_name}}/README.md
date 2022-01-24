## {{cookiecutter.plugin_name}}

{{cookiecutter.plugin_name}}

### Compiling your plugin

To build your plugin:

0) Setup your build environment (on topaz, run `source setup_env.sh`).
1) Add your source code to `src/`. Names must be `{{cookiecutter.project_name}}.h` and `{{cookiecutter.project_name}}.cu`.
2) compile with meson by running:

```
meson setup build
cd build
meson compile
```

### Using your plugin

```python
from build import {{cookiecutter.plugin_name}}_generated as _bf
_bf.ExampleFunction(data_in.as_BFarray(), data_out.as_BFarray())
```