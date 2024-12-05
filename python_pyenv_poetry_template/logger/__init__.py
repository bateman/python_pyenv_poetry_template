"""Logger module."""

from python_pyenv_poetry_template.config import config

from .logger import Logger

logger = Logger()
logger.set_log_level(config.log_level)
