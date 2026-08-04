"""Auth provider adapters."""

from app.adapters.auth.clerk_adapter import (
    CLERK_STUB_EMAIL,
    CLERK_STUB_SUBJECT,
    CLERK_STUB_TOKEN,
    ClerkAuthAdapter,
)
from app.adapters.auth.supabase_adapter import SupabaseAuthAdapter

__all__ = [
    "CLERK_STUB_EMAIL",
    "CLERK_STUB_SUBJECT",
    "CLERK_STUB_TOKEN",
    "ClerkAuthAdapter",
    "SupabaseAuthAdapter",
]
