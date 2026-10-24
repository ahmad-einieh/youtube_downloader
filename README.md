
# YouTube Downloader

A Flutter download experiment with UI flows for individual YouTube videos, playlists, quality selection, and audio-only streams using `youtube_explode_dart`.

## Implemented flows

- Fetch muxed-stream quality labels for a video or the first playlist entry.
- Download a selected video quality or iterate through playlist videos.
- Download an audio-only stream separately.
- Desktop folder selection and fixed-size window configuration.
- Mobile storage/gallery and notification integration.

## Setup

[`pubspec.yaml`](pubspec.yaml) requires Dart `>=3.0.6 <4.0.0`; resolved dependencies may require a newer compatible Dart 3/Flutter SDK. Install the native toolchain for your target platform, then:

```bash
flutter pub get
flutter devices
flutter run -d <device-id>
```

Select a native device supported by the resolved plugins. The code uses `dart:io`, so it is not a working web implementation. Native scaffolding does not guarantee every plugin or download flow works on every platform.

## Intended usage

Paste a video or playlist URL, click **quality**, choose a quality, and click **download**. The audio action requests an audio-only stream. Non-Android targets open a directory picker; Android uses the app's external-storage directory.

## Known limitations

- Output paths use Windows-style backslashes, which are not portable path separators on Android, iOS, Linux, or macOS.
- Audio-only output is always named `.mp4`; no audio transcoding is performed and the actual stream container may differ.
- Incoming share-intent setup is commented out, but mobile disposal still cancels an uninitialized `late` subscription.
- Folder cancellation, stream availability, network failures, and permission denials are not handled consistently.
- Downloads open output files for writing; matching filenames can overwrite existing files. Use a separate download directory.
- The legacy extractor dependency may not work with current YouTube responses. This documentation refresh did not verify builds, downloads, notifications, or gallery access.

All download/UI logic is in [`lib/main.dart`](lib/main.dart). Only download material you own or have permission to download, in accordance with applicable terms and law.
