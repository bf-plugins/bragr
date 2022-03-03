
#include <bifrost/common.h>
#include <bifrost/array.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {{cookiecutter.__class_name}}* bfplugin;

BFstatus {{cookiecutter.__camel_name}}Create(bfplugin* plan_ptr);
BFstatus {{cookiecutter.__camel_name}}Init(bfplugin  plan,
                  int   n_param1,
                  int   n_param2);
BFstatus {{cookiecutter.__camel_name}}SetStream(bfplugin plan,
                       void const* stream);
BFstatus {{cookiecutter.__camel_name}}ResetState(bfplugin plan);
BFstatus {{cookiecutter.__camel_name}}Execute(bfplugin plan,
                     BFarray const* in,
                     BFarray*       out);
BFstatus {{cookiecutter.__camel_name}}Destroy(bfplugin plan);

#ifdef __cplusplus
} // extern "C"
#endif
