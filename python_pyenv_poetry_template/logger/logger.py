"""Module for logging messages with rich formatting.

It also includes `pretty_errors` configuration for better error visualization.
"""

import logging
from enum import Enum

import pretty_errors
from rich.logging import RichHandler

pretty_errors.configure(
    separator_character="*",
    filename_display=pretty_errors.FILENAME_EXTENDED,
    line_number_first=True,
    display_link=True,
    lines_before=5,
    lines_after=2,
    line_color=pretty_errors.RED + "> " + pretty_errors.default_config.line_color,
    code_color="  " + pretty_errors.default_config.line_color,
    truncate_code=True,
    display_locals=True,
)


class Format(Enum):
    """The format class for the logger.

    Attributes
    ----------
        DEBUG (str): Grey
        INFO (str): Grey
        WARN (str): Yellow
        ERROR (str): Bold red
        CRITICAL (str): Bold red

    """

    DEBUG = "[dim][grey]"
    INFO = "[dim][grey]"
    WARN = "[yellow]"
    ERROR = "[bold][red]"
    CRITICAL = ERROR


class Logger(object):
    """The logger class for logging messages with rich formatting."""

    _instance = None

    def __new__(cls):
        """Create a new instance of the logger class."""
        if cls._instance is None:
            cls._instance = super(Logger, cls).__new__(cls)
            cls._instance.logger = logging.getLogger("rich")
        return cls._instance

    def debug(self, message: str) -> None:
        """Log a debug message with rich formatting.

        Args:
        ----
            message (str): The message to log.

        """
        if self._instance is not None:
            self._instance.logger.debug(Format.DEBUG.value + message + "[/]")

    def info(self, message: str) -> None:
        """Log an info message with rich formatting.

        Args:
        ----
            message (str): The message to log.

        """
        if self._instance is not None:
            self._instance.logger.info(Format.INFO.value + message + "[/]")

    def warn(self, message: str) -> None:
        """Log a warning message with rich formatting.

        Args:
        ----
            message (str): The message to log.

        """
        if self._instance is not None:
            self._instance.logger.warning(Format.WARN.value + message + "[/]")

    def error(self, message: str) -> None:
        """Log an error message with rich formatting.

        Args:
        ----
            message (str): The message to log.

        """
        if self._instance is not None:
            self._instance.logger.error(Format.ERROR.value + message + "[/]")

    def critical(self, message: str) -> None:
        """Log a critical message with rich formatting.

        Args:
        ----
            message (str): The message to log.

        """
        if self._instance is not None:
            self._instance.logger.critical(Format.CRITICAL.value + message + "[/]")

    @staticmethod
    def set_log_level(log_level: str = "") -> None:
        """Set the log level for the logger."""
        if log_level == "debug":
            level = logging.DEBUG
        elif log_level == "info":
            level = logging.INFO
        elif log_level == "warning":
            level = logging.WARNING
        elif log_level == "error":
            level = logging.ERROR
        elif log_level == "critical":
            level = logging.CRITICAL
        elif log_level == "none":
            level = logging.CRITICAL + 1
        else:
            level = logging.WARNING

        logging.basicConfig(
            level=level,
            format="%(message)s",
            handlers=[RichHandler(rich_tracebacks=True, markup=True)],
        )
