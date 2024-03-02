# P3T - Python Pyenv Poetry Template

A template repository for Python projects using pyenv and Poetry.

## Installation

1. Clone the repository: `git clone https://github.com/bateman/python_pyenv_poetry_template.git`
2. Navigate to the project directory: `cd python_pyenv_poetry_template`
3. Show the the status of your dev environment: `make show`. This will list the tools currently installed and the default project vars value, as in the example below.
```console
$ make info

System info:
  OS: Darwin
  Shell: /bin/bash - GNU bash, version 3.2.57(1)-release (arm64-apple-darwin23)
  Make: GNU Make 3.81
  Git: git version 2.39.3 (Apple Git-145)
Project info:
  Project name: python_pyenv_poetry_template
  Project directory: /Users/fabio/Dev/git/python_pyenv_poetry_template
  Project version: 0.1.0
  Project license: MIT
  Project description: 'Override default values of project variables in makefile.env'
Python info:
  Python version: 3.12.1
  Pyenv version: pyenv 2.3.36
  Pyenv root: /Users/fabio/.pyenv
  Pyenv virtualenv name: venv-python_pyenv_poetry_template
  Poetry version: Poetry (version 1.8.1)
Dokcer info:
  Docker: Docker version 25.0.3, build 4debf41
  Docker Compose: Docker Compose version v2.24.6-desktop.1
  Docker image name: p3t
  Docker container name: p3t
```
4. If some needed tool is missing, it will be marked as '*not installed*'. Install them and re-run `make info`.
5. Update the project variables values  by editing the file `makefile.env`. The file content should look like this:
```bash
PROJECT_DESCRIPTION='Override default values of project variables in makefile.env'
PROJECT_NAME=Python Pyenv Poetry template
DOCKER_CONTAINER_NAME=p3t
DOCKER_IMAGE_NAME=p3t
```
6. To complete the installation, run `make project/install`.

> [!NOTE]
> The installation step will install some 'default' dependencies, such as `rich` and `pretty-errors`, but also dev-dependecies, such as `ruff` and `pytest`.
> Edit the `pyproject.toml` to add/remove dependencies before running `make install`.

> [!WARNING]
> The `PROJECT_NAME` var will be converted to lowercase and whitespaces replaced by `_`. This value will be the name of your python module.

## Usage

Explain how to use your project. Provide examples, code snippets, or screenshots.

## Contributing

Contributions are welcome! Follow these steps:
1. Fork the repository.
2. Create a new branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -m 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
