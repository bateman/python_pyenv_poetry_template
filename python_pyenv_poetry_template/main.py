"""The main module of your application package."""

import random
from typing import Optional

from rich.console import Console


def run(text: Optional[str] = "\nHello, world!", color: Optional[str] = None) -> None:
    """Print a message in a specified color or in a random color if no color is specified.

    Args:
    ----
        text (Optional[str]): The message to print. Defaults to "Hello, world!".
        color (Optional[str]): The color to print the message in. This should be a string specifying a color recognized by the `rich` library, or an RGB color in the format "rgb(r,g,b)" where r, g, and b are integers between 0 and 255. If this argument is not provided, a random RGB color will be generated.

    Returns:
    -------
        None

    """
    console = Console()
    if color is None:
        r = random.randint(0, 255)  # nosec
        g = random.randint(0, 255)  # nosec
        b = random.randint(0, 255)  # nosec
        console.print(text, style=f"rgb({r},{g},{b})")
    else:
        console.print(text, style=color)


if __name__ == "__main__":
    run()
