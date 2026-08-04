# DocumentInputSource — package & MVP crop decision

## Goal

One domain abstraction (`DocumentInputSource`) for camera capture **or** file upload.
Screens never branch on `kIsWeb` / platform — they call `captureOrPick(preference:)`.

## Packages

| Concern | Package | Notes |
|---|---|---|
| Camera probe + capture | `image_picker` | `ImageSource.camera`; works mobile + web (getUserMedia) |
| File upload fallback | `file_picker` | jpeg / png / pdf |
| Crop / edge-detect | `image_cropper` (**MVP**) | Interactive crop after camera (and optional after image pick). Not ML edge-detect |

## Capability probe

`CameraGateway.isAvailable` tries a lightweight permission/capability check via
`image_picker` (camera). Denied or unsupported → `isCameraAvailable == false` →
same `captureOrPick` API returns file-sourced bytes.

## Preference

- `auto` — camera when available, else file
- `camera` — force camera path (fails → Failure, does not silently switch unless auto)
- `file` — force file picker

## Crop policy (MVP)

- **Camera path:** always run `DocumentCropper` after capture (interactive crop UI from plugin).
- **File path:** crop only for image mime types; **skip** for PDF (bytes returned as picked).
- When cropper unavailable (e.g. some web/desktop builds), cropper returns original bytes (pass-through) and logs — documented MVP, not production edge-detect.

## File types

Accepted: `image/jpeg`, `image/png`, `application/pdf`.

## Web behavior

Same abstraction. Camera uses browser getUserMedia via `image_picker_for_web`.
File picker uses browser file input. Crop may pass through when UCrop/web cropper is limited.
