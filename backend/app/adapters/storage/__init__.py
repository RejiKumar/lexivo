"""Storage provider adapters."""

from app.adapters.storage.errors import StorageNotConfiguredError
from app.adapters.storage.r2_adapter import R2StorageAdapter
from app.adapters.storage.supabase_adapter import SupabaseStorageAdapter

__all__ = [
    "R2StorageAdapter",
    "StorageNotConfiguredError",
    "SupabaseStorageAdapter",
]
