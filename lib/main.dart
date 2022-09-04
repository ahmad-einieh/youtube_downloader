import 'dart:async';
import 'dart:io' as io;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:starlight_notification/starlight_notification.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  if (io.Platform.isAndroid || io.Platform.isIOS) {
    await StarlightNotificationService.setup();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

enum DOWNLOAD_TYPE { video, playlist, sound }

class _MyHomePageState extends State<MyHomePage> {
  List<String> a = [];
  String? value;
  TextEditingController linkC = TextEditingController();
  bool x = true;
  bool isNotDownload = false;
  bool showNotify = false;
  bool isNotDownloadedPlaylist = false;

  late StreamSubscription _intentData;
  String? data;

  @override
  void initState() {
    super.initState();
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      _intentData = ReceiveSharingIntent.getTextStream().listen((String value) {
        setState(() {
          data = value;
        });
      });
      ReceiveSharingIntent.getInitialText()
          .then((String? value) => data = value);
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      _intentData.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('The System Back Button is Deactivated')));
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade500,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Container(
                    color: Colors.green,
                    height: 35,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                    width: 333,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            width: 1,
                            color: Colors.green,
                            style: BorderStyle.solid)),
                    child: TextField(
                      controller: linkC,
                      decoration: const InputDecoration(
                          hintText: 'Youtube Video Link',
                          contentPadding: EdgeInsets.all(15),
                          border: InputBorder.none),
                    ),
                  ),
                  data == null || data!.isEmpty
                      ? Container()
                      : SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                  data == null || data!.isEmpty ? Container() : Text(data!),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  Container(
                    width: 300,
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                        color: a.isEmpty ? Colors.transparent : Colors.green,
                        borderRadius: BorderRadius.circular(30)),
                    child: a.isEmpty
                        ? Container()
                        : DropdownButton(
                            value: value ?? a.last,
                            items: a.map((String e) {
                              return DropdownMenuItem<String>(
                                value: e,
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    e,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontStyle: FontStyle.italic,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                value = newValue!;
                              });
                            },
                          ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  x
                      ? ElevatedButton(
                          onPressed: () async {
                            if (linkC.text.isNotEmpty) {
                              getQuality(linkC.text);
                            } else if (linkC.text.isEmpty &&
                                data != null &&
                                data!.isNotEmpty) {
                              getQuality(data);
                            } else {
                              if (kDebugMode) {
                                print("nothing");
                              }
                            }
                          },
                          child: const Text("quality"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              fixedSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            if (!linkC.text.contains("playlist")) {
                              if (linkC.text.isEmpty) {
                                if (data!.isNotEmpty) {
                                  await download(data!, value!, await getPath(),
                                      DOWNLOAD_TYPE.video);
                                }
                              } else {
                                await download(linkC.text, value!,
                                    await getPath(), DOWNLOAD_TYPE.video);
                              }
                            } else {
                              if (linkC.text.isEmpty) {
                                if (data!.isNotEmpty) {
                                  await downloadPlaylist(
                                      data!, value!, await getPath());
                                }
                              } else {
                                await downloadPlaylist(
                                    linkC.text, value!, await getPath());
                              }
                            }
                          },
                          child: const Text("download"),
                          style: ElevatedButton.styleFrom(
                              primary: Colors.green,
                              fixedSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                        ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  isNotDownloadedPlaylist
                      ? const SpinKitWave(
                          color: Colors.green,
                        )
                      : Container(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  isNotDownload
                      ? const SpinKitFadingCircle(
                          color: Colors.green,
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  getQuality(String? outlink) async {
    String link;
    YoutubeExplode yt = YoutubeExplode();
    if (outlink!.contains("playlist")) {
      Playlist playlist = await yt.playlists.get(outlink);
      List<Video> videos = await yt.playlists.getVideos(playlist.id).toList();

      link = videos[0].url;
    } else {
      link = outlink;
    }

    String vidID;
    if (!link.contains("&list=")) {
      vidID = link.substring(link.indexOf("?v=") + 3);
    } else {
      vidID = link.substring(link.indexOf("?v=") + 3, link.indexOf("&list="));
    }
    StreamManifest manifest = await yt.videos.streamsClient.getManifest(vidID);

    var streamInfo = manifest.muxed.getAllVideoQualitiesLabel();
    setState(() {
      a.clear();
    });
    a.clear();
    for (var i in streamInfo) {
      if (kDebugMode) {
        print(i);
      }
      setState(() {
        a.add(i);
      });
    }
    setState(() {
      x = false;
      value = a.last;
    });
  }

  getPath() async {
    String? selectedDirectory;

    if (io.Platform.isAndroid) {
      var d = await getExternalStorageDirectory();
      selectedDirectory = d!.path;
    } else {
      selectedDirectory = await FilePicker.platform.getDirectoryPath();
    }
    if (kDebugMode) {
      print(selectedDirectory);
    }
    return selectedDirectory;
  }

  download(String url, String quality, String externalPath,
      DOWNLOAD_TYPE type) async {
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      await Permission.accessMediaLocation.request();
      await Permission.photos.request();
      await Permission.photosAddOnly.request();
      await Permission.mediaLibrary.request();
    }
    var newQuality = "720";
    if (quality.isNotEmpty || quality == "144p") newQuality = quality;
    if (url.isEmpty) {
      return;
    }
    String vidID;
    if (!url.contains("&list=")) {
      vidID = url.substring(url.indexOf("?v=") + 3);
    } else {
      vidID = url.substring(url.indexOf("?v=") + 3, url.indexOf("&list="));
    }
    YoutubeExplode yt = YoutubeExplode();

    StreamManifest manifest = await yt.videos.streamsClient.getManifest(vidID);

    StreamInfo streamInfo;
    try {
      streamInfo = manifest.muxed
          .where((element) => element.qualityLabel == newQuality)
          .last;
      if (kDebugMode) {
        print(streamInfo.qualityLabel);
      }
    } catch (e) {
      streamInfo = manifest.muxed.last;
      if (kDebugMode) {
        print(streamInfo.qualityLabel);
      }
      if (kDebugMode) {
        print(e);
      }
    }

    Stream<List<int>> stream = yt.videos.streams.get(streamInfo);
    var video = await yt.videos.get(url);
    if (kDebugMode) {
      print(video.title);
    }
    String videoName = video.title
        .replaceAll('/', " - ")
        .replaceAll('||', " -- ")
        .replaceAll('|', " - ")
        .replaceAll('\\', " - ")
        .replaceAll('&&', " -- ")
        .replaceAll('&', " - ")
        .replaceAll('\$', ' - ')
        .replaceAll('#', ' - ')
        .replaceAll('.', ' - ')
        .replaceAll('&', ' and ')
        .replaceAll('?', ' ')
        .replaceAll('%', ' - ')
        .replaceAll('*', ' - ')
        .replaceAll('!', ' - ')
        .replaceAll('~', ' - ')
        .replaceAll('\'', ' - ')
        .replaceAll("\"", ' - ')
        .replaceAll('+', " plus ");
    String fullPath;
    fullPath = "$externalPath\\$videoName.mp4";
    setState(() {
      isNotDownload = true;
      linkC.clear();
    });
    if (type == DOWNLOAD_TYPE.video) {
      if (io.Platform.isAndroid || io.Platform.isIOS) {
        await StarlightNotificationService.show(
          StarlightNotification(
            title: 'DOWNLOADING',
            body: 'Download IS Running',
          ),
        );
      }
    }
    var file = io.File(fullPath);
    var fileStream = file.openWrite();
    await stream.pipe(fileStream);
    if (io.Platform.isIOS || io.Platform.isAndroid) {
      if (kDebugMode) {
        print("enter here");
      }
      try {
        final result = await ImageGallerySaver.saveFile(fullPath);
        if (kDebugMode) {
          print("done");
          print(result);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
          print("error on gallery");
        }
      }
    }
    await fileStream.flush();
    await fileStream.close();
    setState(() {
      isNotDownload = false;
      x = true;
      data = '';
      a.clear();
    });
    if (type == DOWNLOAD_TYPE.video) {
      if (io.Platform.isAndroid || io.Platform.isIOS) {
        await StarlightNotificationService.cancel('DOWNLOADING');
        await StarlightNotificationService.show(
          StarlightNotification(
            title: 'Download Done',
            body: '$videoName is downloaded',
          ),
        );
      }
      MotionToast.success(
        title: const Text("download done on"),
        description: Text(externalPath),
        width: io.Platform.isWindows
            ? MediaQuery.of(context).size.width * 0.5
            : MediaQuery.of(context).size.width * 0.9,
      ).show(context);
      if (kDebugMode) {
        print("finish");
      }
    }
  }

  downloadPlaylist(String url, String quality, String externalPath) async {
    YoutubeExplode yt = YoutubeExplode();
    Playlist playlist = await yt.playlists.get(url);
    List<Video> videos = await yt.playlists.getVideos(playlist.id).toList();
    setState(() {
      isNotDownloadedPlaylist = true;
    });
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      await StarlightNotificationService.show(
        StarlightNotification(
          title: 'DOWNLOADING',
          body: 'Download Is Running',
        ),
      );
    }
    for (int i = 0; i < videos.length; i++) {
      if (kDebugMode) {
        print(videos[i].url);
      }
    }
    for (int i = 0; i < videos.length; i++) {
      if (kDebugMode) {
        print(videos[i].url);
      }
      await download(
          videos[i].url, quality, externalPath, DOWNLOAD_TYPE.playlist);
    }
    setState(() {
      isNotDownloadedPlaylist = false;
    });
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      await StarlightNotificationService.cancel('DOWNLOADING');
      await StarlightNotificationService.show(
        StarlightNotification(
          title: 'Download Done',
          body: 'playlist is downloaded',
        ),
      );
    }
    MotionToast.success(
      title: const Text("download done on"),
      description: Text(externalPath),
      width: io.Platform.isWindows
          ? 500
          : MediaQuery.of(context).size.width * 0.9,
      //toastDuration: const Duration(seconds: 5),
    ).show(context);
    if (kDebugMode) {
      print("finish");
    }
  }
}
