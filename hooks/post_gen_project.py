# Post generation script
# Delete conditional files after generation
# https://cookiecutter.readthedocs.io/en/latest/advanced/hooks.html#example-conditional-files-directories
import os
import sys

REMOVE_PATHS = [
    '{% if cookiecutter.requires_cuda == "y" %} src/{{cookiecutter.__snake_name}}.c {% endif %}',
    '{% if cookiecutter.requires_cuda == "n" %} src/{{cookiecutter.__snake_name}}.cu {% endif %}',
]

for path in REMOVE_PATHS:
    path = path.strip()
    if path and os.path.exists(path):
        if os.path.isdir(path):
            os.rmdir(path)
        else:
            os.unlink(path)
