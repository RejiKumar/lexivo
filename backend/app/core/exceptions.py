"""Domain exceptions used across adapters and (later) services."""


class AuthenticationError(Exception):
    """Raised when AuthProvider cannot verify a bearer token."""

    def __init__(self, message: str = "Unauthorized") -> None:
        self.message = message
        super().__init__(message)
