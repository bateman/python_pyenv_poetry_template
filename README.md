# P3T - Python Pyenv Poetry Template

![GitHub Release](https://img.shields.io/github/v/release/bateman/python_pyenv_poetry_template?style=flat-square)
![GitHub top language](https://img.shields.io/github/languages/top/bateman/python_pyenv_poetry_template?style=flat-square)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/bateman/python_pyenv_poetry_template/release.yml?style=flat-square)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/bateman/python_pyenv_poetry_template/docker.yml?style=flat-square&label=docker)
![Codecov](https://img.shields.io/codecov/c/github/bateman/python_pyenv_poetry_template?style=flat-square)
![GitHub Pages Status](https://img.shields.io/badge/docs-passing-46cc14?style=flat-square)
![GitHub License](https://img.shields.io/github/license/bateman/python_pyenv_poetry_template?style=flat-square)

A template repository for Python projects using Pyenv and Poetry.

## Makefile

The project relies heavily on `make`, which is used to run *all* commands. Run `make` to see the list of the available targets.

```console
$ make

Usage: make [target]

Info
 help                  Show this help message
 info                  Show development environment info
System
 clean                 Clean the project - removes all cache dirs and stamp files
 reset                 Reset the project - cleans plus removes the virtual environment
 python                Check if Python is installed - install it if not
 virtualenv            Check if virtualenv exists and activate it - create it if not
 update                Update Poetry
Project
 project/all           Install and build the project, generate the documentation
 project/install       Install the project for development
 project/update        Update the project
 project/run           Run the project (pass arguments with ARGS="...")
 project/tests         Run the tests (pass arguments with ARGS="...")
 project/production    Install the project for production
 project/deps-export   Export the project's dependencies
 project/build         Build the project as a package
Check
 check/precommit       Run the pre-commit checks
 check/format          Format the code
 check/lint            Lint the code
Docker
 docker/build          Build the Docker image
 docker/run            Run the Docker container
 docker/all            Build and run the Docker container
 docker/stop           Stop the Docker container
 docker/clean          Clean the Docker container
 docker/remove         Clean the Docker container and remove the image
Tag
 tag/patch             Tag a new patch version release
 tag/minor             Tag a new minor version release
 tag/major             Tag a new major version release
 tag/push              Push the tag to origin - triggers the release action
Documentation
 docs/build            Generate the project documentation
 docs/serve            Serve the project documentation
 docs/deploy           Deploy the project documentation
```

## Installation

This is a template repository, so first things first, you create a new GitHub repository and choose this as its template. After that, follow the installation steps below.

1. Clone the repository: `git clone https://github.com/<your-github-name>/<your-project-name>.git `
2. Navigate to the project directory: `cd <your-project-name>`
3. Check the status of the dev environment: `make show` will list the tools currently installed and the default value of project vars, as in the example below:
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
  Project description: 'Override default values of project variables in Makefile.env'
Python info:
  Python version: 3.12.1
  Pyenv version: pyenv 2.3.36
  Pyenv root: /Users/fabio/.pyenv
  Pyenv virtualenv name: venv-python_pyenv_poetry_template
  Poetry version: Poetry (version 1.8.1)
Docker info:
  Docker: Docker version 25.0.3, build 4debf41
  Docker Compose: Docker Compose version v2.24.6-desktop.1
  Docker image name: p3t
  Docker container name: p3t
```
4. If any of the needed tools is missing, it will be marked as '*not installed*'. Install them and re-run `make info` to ensure the tools are now correctly installed and in your PATH.
5. Update the project variables values by editing the file `Makefile.env`. The file content should look like this:
```bash
PROJECT_DESCRIPTION='Override default values of project variables in Makefile.env'
PROJECT_NAME=Python Pyenv Poetry template
DOCKER_CONTAINER_NAME=p3t
DOCKER_IMAGE_NAME=p3t
```
6. To create the virtual environment, run `make virtualenv`. Note that this will also check for the requested Python version; if not available, it will use `pyenv` to install it.
7. To complete the installation for development purposes, run `make project/install` -- this will install all development dependencies. Otherwise, for production purposes only, run `make project/production`.

> [!NOTE]
> The installation step will install some 'default' dependencies, such as `rich` and `pretty-errors`, but also dev-dependecies, such as `ruff` and `pytest`.
> Edit the `pyproject.toml` to add/remove dependencies before running `make install`. Otherwise, you can add and remove dependencies later using `poetry add` and `poetry remove` commands.

> [!WARNING]
> The `PROJECT_NAME` var will be converted to lowercase and whitespaces will be replaced by `_`. This value will be the name of your project module.

## Development

The project uses the following development libraries:
* `ruff`: for code linting and formatting.
* `mypy`: for static type-checking.
* `bandit`: for security analysis.
* `pre-commit`: for automating all the checks above before committing.

> [!NOTE]
> To manually run code formatting and linting, run `make check/format` and `make check/lint`, respectively.
> To execute all the checks, stage your changes, then run `make check/precommit`.

## Execution

* To run the project: `make run/project`
* To run the tests: `make run/tests`

> [!NOTE]
> Tests are executed using `pytest`. Test coverage is calculated using the plugin `pytest-cov`.

> [!WARNING]
> Pushing new commits to GitHub, will trigger the GitHub Action defined in `test.yml`, which will try to upload the coverage report to [Codecov](https://about.codecov.io/). To ensure correct execution, first log in to Codecov and enable the coverage report for your repository; this will generate a `CODECOV_TOKEN`. Then, add the `CODECOV_TOKEN` to your repository's 'Actions secrets and variables' settings page.

## Update

Run `make project/update` to update all the dependencies using `poetry`.

## Release

* Add your pending changes to the staging, commit, and push them to the origin.
* Apply a semver tag to your repository by updating the current project version (note that this will update `pyproject.toml` accordingly):
  - `make tag/patch` - e.g., 0.1.0 -> 0.1.1
  - `make tag/minor` - e.g., 0.1.1 -> 0.2.1
  - `make tag/major` - e.g., 0.2.1 -> 1.0.1
* Run `make tag/push` to trigger the upload of a new release by excuting the GitHub Action `release.yml`.

> [!WARNING]
> Before uploading a new release, you need to add a `RELEASE_TOKEN` to your repository's 'Actions secrets and variables' settings page. The `RELEASE_TOKEN` is generated from your GitHub 'Developer Settings' page. Make sure to select the full `repo` scope when generating it.

## Build

Run `make project/build` to build the project as a Python package.
The `*.tar.gz` and `*.whl` will be placed in the `BUILD` directory (by default `dist/`).

## Documentation

* Run `make docs/build` to build the project documentation using `mkdocstrings`. The documentation will be generated from your project files' comments in doctring format.
The documentation files will be stored in the `DOCS_SITE` directory (by default `site/`).
* Run `make docs/server` to browse the built site locally, at http://127.0.0.1:8000/your-github-name/your-project-name/
* Run `make docs/deploy` to publish the documentation site as GitHub pages. The content will be published to a separate branch, name `gh-pages`. Access the documentation online at https://your-github-name.github.io/your-project-name/

> [!NOTE]
> You will have to edit the `mkdocs.yml` file to adapt it to your project's specifics. For example, it uses by default the `readthedocs` theme.

> [!WARNING]
> After the first deployment to your GitHub repository, your repository Pages settings (Settings > Pages) will be automatically updated to point to the documentation site content stored in the `gh-pages` branch.

## Docker

* To build the Docker container: `make docker/build`
* To start the Docker container and run the application: `make docker/run`
* To build and run: `make docker/all`

> [!NOTE]
> Before building the container, edit `Dockerfile` and change the name of the folder containing your Python module (by default `python_pyenv_poetry_template`).

> [!WARNING]
> Pushing a new release to GitHub, will trigger the GitHub Action defined in `docker.yml`. To ensure correct execution, you first need to add the `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` secrets to your repository's 'Actions secrets and variables' settings page.

## Contributing

Contributions are welcome! Follow these steps:
1. Fork the repository.
2. Create a new branch: `git checkout -b feature-name`
3. Make your changes and commit: `git commit -m 'Add feature'`
4. Push to the branch: `git push origin feature-name`
5. Submit a pull request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
