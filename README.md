# P3T - Python Pyenv Poetry Template

A template repository for Python projects using pyenv and Poetry.

## Makefile

The project relies heavily on `make`, which is used to run *all* commands. Run `make` to see the list of the available targets.

```console
$ make

Usage: make [target]

System
 help                 Show this help message
 info                 Show development box info
 clean                Clean the project - removes all cache dirs and stamp files
 reset                Reset the project - cleans plus removes the virtual enviroment)
 python               Check if python is installed - install it if not
 virtualenv           Check if virtualenv exists - create and activate it if not
 poetry/install       Check if Poetry is installed - install it if not
 poetry/update        Update Poetry
Project
 project/all          Install, build and generate the documentation
 project/install      Install the project for development
 project/update       Update the project
 project/production   Install the project for production
 project/export       Export the project's dependencies
 project/build        Build the project as a package
 project/docs         Generate the project documentation
Run
 run/project          Run the project
 run/tests            Run the tests
Release
 release/patch        Tag a new patch version release
 release/minor        Tag a new minor version release
 release/major        Tag a new major version release
 release/push         Push the release
Check
 check/precommit      Run the pre-commit checks
 check/format         Format the code
 check/lint           Lint the code
Docker
 docker/build         Build the Docker image
 docker/run           Run the Docker container
 docker/all           Build and run the Docker container
 docker/stop          Stop the Docker container
 docker/clean         Clean the Docker container
 docker/remove        Clean the Docker container and remove the image
```

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
6. Create the virtual environment, run `make virtualenv`.
7. To complete the installation for development purposes, run `make project/install` -- this will install all development dependencies. Otherwise, for production purposes only, run `make project/production`.

> [!NOTE]
> The installation step will install some 'default' dependencies, such as `rich` and `pretty-errors`, but also dev-dependecies, such as `ruff` and `pytest`.
> Edit the `pyproject.toml` to add/remove dependencies before running `make install`.

> [!WARNING]
> The `PROJECT_NAME` var will be converted to lowercase and whitespaces replaced by `_`. This value will be the name of your python module.

## Development

The project uses the following development libraries:
* `ruff`: for code linting and formatting.
* `mypy`: for static type-checking.
* `bandit`: for security analysis.
* `pre-commit`: for automating all the checks above before committing.

## Update

Run `make project/update` to update all the dependencies using `poetry`.

## Build

Run `make project/build` for building the project as a python package. The `*.tar.gz` and `*.whl` will be in the `BUILD` directory (by default `dist/`).

## Documentation

Run `make project/docs` for building the project documentation using `mkdocstrings`. The documentation will be generated from your project files' comments in doctring format.
The documenation files will be stored in the `DOCS` directory (by default `docs/`).

> [!NOTE]
> You will have to edit the files `mkdocs.yml` and `.readthedocs.yml` to adapt it to your project's specifics.

## Execution

* To run the project: `make run/project`
* To run the tests: `make run/tests`

> [!NOTE]
> Tests are executed using `pytest`. Test coverage is calculated using the plugin `pytest-cov`.

## Docker

* To build the Docker container: `make docker/build`
* To start the Dokcer container and run the application: `make docker/run`
* To build and run: `make docker/all`

## Contributing

Contributions are welcome! Follow these steps:
1. Fork the repository.
2. Create a new branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -m 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
