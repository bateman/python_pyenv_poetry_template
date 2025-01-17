"""The main module of your application package."""

import argparse
import random
from typing import Optional, Tuple

from rich.console import Console

from python_pyenv_poetry_template.logger import logger


class OneClass:
    """The main class of your application package.

    This class is used to encapsulate the main functionality of your application.
    You can define methods and properties here to perform the main tasks of your application.

    """

    """An instance of rich console."""
    console = None

    def __init__(self) -> None:  # noqa: D107
        logger.debug("Initializing OneClass.")
        self.console = Console()

    def print(
        self,
        text: Optional[str] = "\nHello, world!",
        color: Optional[str] = f"rgb({128},{128},{128})",
    ) -> None:
        """Print a message in a specified color or in a random color if no color is specified.

        Args:
            text (Optional[str]): The message to print. Defaults to "Hello, world!".
            color (Optional[str]): The color to print the message in.
                                   This should be a string specifying a color recognized by the `rich` library,
                                   or an RGB color in the format "rgb(r,g,b)" where r, g, and b are integers between 0 and 255.
                                   If this argument is not provided, a mid-grey color rgb(128,128,128) will be generated.

        """
        console = Console()

        if color is None:
            r = random.randint(0, 255)  # noqa: S311
            g = random.randint(0, 255)  # noqa: S311
            b = random.randint(0, 255)  # noqa: S311
            color = f"rgb({r},{g},{b})"
        text = text or "\nHello, world!"

        console.print(text, style=color)


def run() -> None:
    """Run the main functionality of your application package.

    This function is called when your application is run as a package.
    You can use this function to perform the main tasks of your application.

    Example:
    ``` bash
    python -m python_pyenv_poetry_template -t "Ciao" -c "red"
    python -m python_pyenv_poetry_template --text "Mondo" --color "green"
    python -m python_pyenv_poetry_template -t "Ciao mondo"
    ```
    """
    logger.info("Running the main module.")
    text, color = parse_args()

    oc = OneClass()
    oc.print(text, color)


def parse_args() -> Tuple[str, str]:
    """Parse command line arguments.

    Returns:
        Tuple[str, str]: The text to print in color.

    """
    logger.debug("Parsing command line arguments.")
    parser = argparse.ArgumentParser(description="Prints any text in color.")
    parser.add_argument("-t", "--text", type=str, help="The text to print.")
    parser.add_argument(
        "-c", "--color", type=str, help="The color to print the text in."
    )
    args = parser.parse_args()
    return args.text, args.color


if __name__ == "__main__":
    run()
