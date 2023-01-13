import 'dart:io';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main() async {
  var yt = YoutubeExplode();
  StreamManifest manifest = await yt.videos.streamsClient.getManifest('ZxPRVaMmkrk');
  StreamInfo streamInfo = manifest.audioOnly.first;
  if (streamInfo != null) {
    // Get the actual stream
    var stream = yt.videos.streamsClient.get(streamInfo);

    // Open a file for writing.
    var file = File("test.mp4");
    var fileStream = file.openWrite();

    // Pipe all the content of the stream into the file.
    await stream.pipe(fileStream);

    // Close the file.
    await fileStream.flush();
    await fileStream.close();
  }
  print(streamInfo.url);
}