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
// import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:starlight_notification/starlight_notification.dart';
import 'package:window_manager/window_manager.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:youtube_parser/youtube_parser.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (io.Platform.isWindows || io.Platform.isLinux || io.Platform.isMacOS) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(444, 888),
      maximumSize: Size(444, 888),
      minimumSize: Size(444, 888),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      // titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

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

enum DOWNLOADTYPES { video, playlist, sound }

class _MyHomePageState extends State<MyHomePage> {
  List<String> a = [];
  String? value;
  TextEditingController linkC = TextEditingController();
  bool x = true;
  bool isNotDownload = false;
  bool showNotify = false;
  bool isNotDownloadedPlaylist = false;
  String fileSize = "";
  bool isNotDownloadAudio = false;

  late StreamSubscription _intentData;
  String? data;

  // @override
  // void initState() {
  //   super.initState();
  //   if (io.Platform.isAndroid || io.Platform.isIOS) {
  //     _intentData = ReceiveSharingIntent.getTextStream().listen((String value) {
  //       setState(() {
  //         data = value;
  //       });
  //     });
  //     ReceiveSharingIntent.getInitialText()
  //         .then((String? value) => data = value);
  //   }
  // }

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
                          style: BorderStyle.solid),
                    ),
                    child: TextField(
                      controller: linkC,
                      decoration: const InputDecoration(
                          hintText: 'Youtube Video Link',
                          contentPadding: EdgeInsets.all(15),
                          border: InputBorder.none),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(fileSize),
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
                      ? Column(
                          children: [
                            ElevatedButton(
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
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  fixedSize: const Size(200, 50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50))),
                              child: const Text("quality"),
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                            ),
                            TextButton(
                              onPressed: () async {
                                await downloadAudio(
                                    linkC.text, await getPath());
                              },
                              child: const Text(
                                "download it as audio",
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            if (!linkC.text.contains("playlist")) {
                              if (linkC.text.isEmpty) {
                                if (data!.isNotEmpty) {
                                  await download(data!, value!, await getPath(),
                                      DOWNLOADTYPES.video);
                                }
                              } else {
                                await download(linkC.text, value!,
                                    await getPath(), DOWNLOADTYPES.video);
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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              fixedSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50))),
                          child: const Text("download"),
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
                  isNotDownloadAudio
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

  downloadAudio(String url, String externalPath) async {
    if (io.Platform.isAndroid || io.Platform.isIOS) {
      await Permission.manageExternalStorage.request();
      await Permission.storage.request();
      await Permission.accessMediaLocation.request();
      await Permission.photos.request();
      await Permission.photosAddOnly.request();
      await Permission.mediaLibrary.request();
    }
    setState(() {
      isNotDownloadAudio = true;
    });
    String? vidID = getIdFromUrl(url);
    var yt = YoutubeExplode();
    StreamManifest manifest = await yt.videos.streamsClient.getManifest(vidID);
    StreamInfo streamInfo = manifest.audioOnly.first;
    var stream = yt.videos.streamsClient.get(streamInfo);
    var videoName = await getVideoName(url);
    String fullPath = "$externalPath\\$videoName.mp4";
    var file = io.File(fullPath);
    var fileStream = file.openWrite();
    await stream.pipe(fileStream);
    await fileStream.flush();
    await fileStream.close();
    yt.close();
    MotionToast.success(
      title: const Text("download done on"),
      description: Text(externalPath),
      width:
          io.Platform.isWindows ? 500 : MediaQuery.of(context).size.width * 0.9,
      height: 55,
      //toastDuration: const Duration(seconds: 5),
    ).show(context);
    setState(() {
      isNotDownloadAudio = false;
    });
    if (kDebugMode) {
      print("finish");
    }
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

    String? vidID = getIdFromUrl(link);
    if (vidID == null) {
      MotionToast.error(
        title: const Text("Error"),
        description: Text("$outlink not valid"),
        height: 75,
        width: MediaQuery.of(context).size.width * 0.9,
      ).show(context);
      return;
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
    yt.close();
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

  getVideoName(String url) async {
    YoutubeExplode yt = YoutubeExplode();
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
        .replaceAll('+', " plus ")
        .replaceAll(':', ' - ')
        .replaceAll('\t', ' - ')
        .replaceAll(' 0    ', ' - ');
    yt.close();
    return videoName;
  }

  download(String url, String quality, String externalPath,
      DOWNLOADTYPES type) async {
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

    String? vidID = getIdFromUrl(url);
    if (vidID == null) {
      MotionToast.error(
        title: const Text("Error"),
        description: Text("$url not valid"),
        height: 75,
        width: MediaQuery.of(context).size.width * 0.9,
      ).show(context);
      return;
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
    setState(() {
      fileSize = streamInfo.size.toString();
    });

    Future.delayed(const Duration(seconds: 15));

    Stream<List<int>> stream = yt.videos.streams.get(streamInfo);

    var videoName = await getVideoName(url);
    String fullPath = "$externalPath\\$videoName.${streamInfo.codec.subtype}";
    setState(() {
      isNotDownload = true;
      linkC.clear();
    });
    if (type == DOWNLOADTYPES.video) {
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
      fileSize = "";
    });
    if (type == DOWNLOADTYPES.video) {
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
        height: 75,
        width: MediaQuery.of(context).size.width * 0.9,
      ).show(context);
      if (kDebugMode) {
        print("finish");
      }
    }
    yt.close();
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
          videos[i].url, quality, externalPath, DOWNLOADTYPES.playlist);
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
      width:
          io.Platform.isWindows ? 500 : MediaQuery.of(context).size.width * 0.9,
      height: 55,
      //toastDuration: const Duration(seconds: 5),
    ).show(context);
    if (kDebugMode) {
      print("finish");
    }
    yt.close();
  }
}
