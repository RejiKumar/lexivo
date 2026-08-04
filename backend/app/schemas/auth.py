"""Auth session / identity response schemas."""

from pydantic import BaseModel


class AuthSessionResponse(BaseModel):
    """Identity-backed session payload for /auth/me."""

    subject: str
    email: str | None = None
    display_name: str | None = None
