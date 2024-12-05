"""Module for handling configuration file.

Condigurations are loaded from a JSON file and can be accessed as attributes of the `Config` class.


``` py title="Example"
config = Config("path/to/config.json")
config.some_attribute
```

"""

import json


class Config:
    """The configuration class that handles configuration files."""

    def __init__(self, filename: str) -> None:
        """Initialize the Config class by loading configurations from a given file.

        Args:
            filename (str): The name of the configuration file.

        """
        # ensure a file exists and is actually read
        if filename:
            try:
                with open(filename, "r") as f:
                    _config = json.load(f)
                    for key, val in _config.items():
                        if isinstance(val, dict):
                            for subkey, subval in val.items():
                                if str(subval).isdigit():
                                    subval = float(subval)
                                setattr(self, subkey, subval)
                        else:
                            if str(val).isdigit():
                                val = float(val)
                            setattr(self, key, val)
            except FileNotFoundError:
                raise FileNotFoundError(f"Config file {filename} not found.")

    def __getattr__(self, _):
        """Get the value of an attribute.

        Returns:
            `None` if the attribute is not found.

        """
        return None
