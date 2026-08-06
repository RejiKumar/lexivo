# DocumentInputSource — package & MVP crop decision

## Goal

One domain abstraction (`DocumentInputSource`) for camera capture **or** file upload.
Screens never branch on `kIsWeb` / platform — they call `captureOrPick(preference:)`.

## Packages

| Concern | Package | Notes |
|---|---|---|
| Camera probe + capture | `image_picker` | `ImageSource.camera`; works mobile + web (getUserMedia) |
| Gallery pick | `image_picker` | `ImageSource.gallery` for photos from the device library |
| File upload | `file_picker` | jpeg / png / pdf |
| Crop / edge-detect | `image_cropper` (**MVP**) | Interactive crop after camera/gallery (and optional after image file pick). Not ML edge-detect |

## Capability probe

`CameraGateway.isAvailable` tries a lightweight permission/capability check via
`image_picker` (camera). Denied or unsupported → `isCameraAvailable == false` →
same `captureOrPick` API returns file-sourced bytes.

## Preference

- `auto` — camera when available, else gallery (scan UI uses explicit actions)
- `camera` — force camera path (fails → Failure, does not silently switch unless auto)
- `gallery` — device photo library via `image_picker`
- `file` — force file picker (PDF or image)

## Crop policy (MVP)

- **Camera / gallery path:** always run `DocumentCropper` after pick (interactive crop UI from plugin).
- **File path:** crop only for image mime types; **skip** for PDF (bytes returned as picked).
- When cropper unavailable (e.g. some web/desktop builds), cropper returns original bytes (pass-through) and logs — documented MVP, not production edge-detect.

## File types

Accepted: `image/jpeg`, `image/png`, `application/pdf`.

## Web behavior

Same abstraction. Camera uses browser getUserMedia via `image_picker_for_web`.
File picker uses browser file input. Crop may pass through when UCrop/web cropper is limited.
