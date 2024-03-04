"""Provide information about the P3T project template."""

import toml

title = "P3T - Python Pyenv Poetry Template"
description = """
A template repository for Python projects using Pyenv and Poetry. 🚀

## Documentation

Check the documentation as [GitHub Pages](https://bateman.readthedocs.io/python_pyenv_poetry_template).
"""
toml_dict = toml.get_dict()
if toml_dict is None:
    version = ""
else:
    version = toml_dict["tool"]["poetry"]["version"]
terms_of_service = "None"
contact = {
    "name": "Made with 💖 by bateman",
    "url": "https://github.com/bateman/python_pyenv_poetry_template/issues",
}
license_info = {
    "name": "MIT License",
    "url": "https://github.com/bateman/python_pyenv_poetry_template/LICENSE",
}
