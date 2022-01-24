import numpy as np
import bifrost as bf
from build import {{cookiecutter.plugin_name}}_generated as _bf

def generate_gold_comparison():
    """ Generate a 'gold' known-good comparison array """
    return np.ones((10, 2, 2))

def test_{{cookiecutter.plugin_name}}():
    # Create known 'gold' output
    d_gold_cpu = generate_gold_comparison()

    # Create input and output data
    input_dims = (10, 10, 10)
    output_dims = (10, 2, 2)

    d_in_cpu = np.zeros(input_dims, dtype='float32')
    d_in_gpu = bf.ndarray(d_in_cpu, dtype='f32', space='cuda')

    d_out_zeros_cpu = np.zeros(input_dims, dtype='float32')
    d_out_gpu       = bf.ndarray(d_out_zeros_cpu, dtype='f32', space='cuda')

    # Run main functions
    _bf.XcorrLite(d_gpu.as_BFarray(), xcorr_bf.as_BFarray(), np.int32(reset))

    # Test output matches gold CPU standard
    print("Copy result from GPU...")
    dout_cpu = np.array(d_out_gpu.copy('system'))
        
    print("Comparing CPU to GPU...")
    assert np.allclose(dout_cpu, dout_gold)


if __name__ == "__main__":
    test_{{cookiecutter.plugin_name}}()