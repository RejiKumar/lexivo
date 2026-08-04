# Lexivo

Lexivo AI Document Assistant (Flutter + FastAPI).

## Flutter setup

```bash
flutter pub get
```

### Environment

Copy `.env.example` and supply (via `--dart-define` or your loader):

| Variable | Purpose |
|---|---|
| `SUPABASE_URL` | Supabase project URL |
| `SUPABASE_ANON_KEY` | Supabase anon key (public) |
| `API_BASE_URL` | FastAPI base URL (e.g. `http://localhost:8000`) |

Never commit real secrets.

### Platform permissions (document scan)

- **Android:** `CAMERA`, `READ_MEDIA_IMAGES` / storage as required by `image_picker` / `file_picker` (see `AndroidManifest.xml`).
- **iOS:** `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` in `Info.plist`.
- Input strategy: [docs/document_input_source.md](docs/document_input_source.md).

### API client

See [docs/api_client.md](docs/api_client.md). OpenAPI snapshot: `openapi/lexivo.openapi.json`. Regen: `./tool/generate_api_client.sh`.

### Design system showcase

```bash
flutter run --dart-define=LEXIVO_SHOWCASE=true
```

## Getting Started

This project is a starting point for a Flutter application. See the
[Flutter documentation](https://docs.flutter.dev/) for tooling help.
