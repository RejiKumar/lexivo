"""User profile request/response schemas."""

from datetime import datetime

from pydantic import BaseModel, ConfigDict


class UserProfileResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    external_id: str
    email: str | None = None
    display_name: str | None = None
    created_at: datetime | None = None
    updated_at: datetime | None = None


class UserProfileUpdateRequest(BaseModel):
    display_name: str | None = None
    email: str | None = None
