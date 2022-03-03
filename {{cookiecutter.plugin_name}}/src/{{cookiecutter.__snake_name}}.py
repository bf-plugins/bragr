from bifrost.libbifrost import _check, _get, BifrostObject
from bifrost.ndarray import asarray

import {{cookiecutter.__snake_name}}_generated as _gen

class {{cookiecutter.__camel_name}}(BifrostObject):
    def __init__(self):
        BifrostObject.__init__(self, _gen.{{cookiecutter.__camel_name}}Create, 
                               _gen.{{cookiecutter.__camel_name}}Destroy)
    def init(self):
        _check(_gen.{{cookiecutter.__camel_name}}Init(self.obj))

    def execute(self, in_BFarray, out_BFarray):
        _check(_gen.{{cookiecutter.__camel_name}}Execute(self.obj, asarray(in_BFarray).as_BFarray(),
                                asarray(out_BFarray).as_BFarray()))
        return out_BFarray

    def set_stream(self, stream_ptr_generic):
        _check(_gen.{{cookiecutter.__camel_name}}SetStream(self.obj, stream_ptr_generic))

    def reset_state(self):
        _check(_gen.{{cookiecutter.__camel_name}}ResetState(self.obj))