class struct_BFarray_(Structure):
    pass

struct_BFarray_.__slots__ = [
    'data',
    'space',
    'dtype',
    'ndim',
    'shape',
    'strides',
    'immutable',
    'big_endian',
    'conjugated',
]
struct_BFarray_._fields_ = [
    ('data', POINTER(None)),
    ('space', BFspace),
    ('dtype', BFdtype),
    ('ndim', c_int),
    ('shape', c_long * int(BF_MAX_DIMS)),
    ('strides', c_long * int(BF_MAX_DIMS)),
    ('immutable', BFbool),
    ('big_endian', BFbool),
    ('conjugated', BFbool),
]
