"""Contains the tests for the main module."""

from unittest.mock import MagicMock, patch

from python_pyenv_poetry_template.main import OneClass


@patch("python_pyenv_poetry_template.main.Console")
def test_print(mock_console):
    """Test the print method of the OneClass class.

    This test verifies that the print method of the OneClass class calls the print method of the Console class
    with the correct arguments.
    """
    # Arrange
    oc = OneClass()
    mock_console_instance = MagicMock()
    mock_console.return_value = mock_console_instance

    # Act
    oc.print("Hello, world!", "red")

    # Assert
    mock_console_instance.print.assert_called_once_with("Hello, world!", style="red")
