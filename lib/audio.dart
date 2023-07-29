import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController iconController;
  bool isAnimated = false;
  double _volume = 1.0;
  bool isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double? _progress;
  final player = AudioPlayer();
 List <String> audioUrl = [
  "https://media.radioinstore.in/songs/Tamil/2011/Yengeyum%20kadhal/thee%20Illai_Naresh%20Iyer%2C%20Mukesh%2C%20Gopal%20Rao%2C%20Mahathi%2C%20Ranina%20Reddy.mp3",
  "https://media.radioinstore.in/songs/Tamil/1990/Keladi%20Kanmani/nee%20pathi%20nanpathi_jesu.mp3",
  "https://media.radioinstore.in/songs/Tamil/1995/Sathi%20leelavathy/Maharajanodo_NA.mp3",
  "https://media.radioinstore.in/songs/Tamil/1991/maanagara%20kaaval/thodi%20raagam_NA.mp3",
  "https://media.radioinstore.in/songs/Tamil/1997/Periya%20thambi/Tajmahale%20nee.mp3"
 ];
  String filename = "audio.mp3";
  int currentAudioIndex=0;

  @override
  void initState() {
    super.initState();
    player.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
    player.onDurationChanged.listen((newDuration) {
      setState(() {
        _duration = newDuration;
      });
    });
    player.onPositionChanged.listen((newPosition) {
      setState(() {
        _position = newPosition;
      });
    });

    iconController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
    );

    playAudioFromURL(audioUrl[currentAudioIndex]);
    requestPermissions();
    startBackgroundDownloading();
  }
 void startBackgroundDownloading() async {
  List<Future<void>> downloads =[];
  for (int i = 0; i < audioUrl.length; i++) {
    String audioUrlToDownload = audioUrl[i].trim();
    String filename = audioUrlToDownload.split('/').last;
    String? localFilePath = await findLocalFilePath(audioUrlToDownload);

    if (localFilePath == null) {
      downloads.add(downloadAudioFiles(audioUrlToDownload));
    }
  }
  await Future.wait(downloads);
  playAudioFromURL(audioUrl[currentAudioIndex]);
}
Future<void> playAudioFromURL(String audioUrl) async {
  String? localFilePath = await findLocalFilePath(audioUrl);
  if (localFilePath != null) {
 await player.setSourceDeviceFile(localFilePath);
  } else {
    await player.setSourceUrl(audioUrl);
  }
  player.resume();
  player.onPlayerStateChanged.listen((PlayerState state) {
    if (state == PlayerState.completed) {
      playNextAudio();
    }
  });
}
Future<void> playAudioFromLocalFile(String localFilePath) async {
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String fullPath = '${appDocDir.path}/$localFilePath';
  await player.setSourceDeviceFile(fullPath);
  player.resume();
}

  Future<String?> findLocalFilePath(String audioUrl) async{
    String filename =audioUrl.split('/').last;
    String localFilePath = '$filename';
    if(await File(localFilePath).exists()){
      return localFilePath;
    }
    return null;
  }
  Future<void> downloadAudioFiles(String audioUrl) async {
      try {
        setState(() {
          _progress = 0.0;
        });
        String filename = audioUrl.split('/').last;
        await FileDownloader.downloadFile(
           url: audioUrl.trim(),
          onProgress: (name, progress) {
            setState(() {
              _progress = progress;
            });
          },
        );
        print("Download completed: $filename");

        setState(() {
          _progress = null;
        });
      } catch (error) {
        print("Download failed: $error");

        setState(() {
          _progress = null;
        });
      }
  }
  
 void playNextAudio() async {
  if (currentAudioIndex < audioUrl.length - 1) {
    currentAudioIndex++;
    String? localFilePath = await findLocalFilePath(audioUrl[currentAudioIndex]);
    if (localFilePath != null) {
      await playAudioFromLocalFile(localFilePath);
    } else {
      await playAudioFromURL(audioUrl[currentAudioIndex]);
    }
  } else {
    String? localFilePath = await findLocalFilePath(audioUrl[currentAudioIndex]);
    if (localFilePath != null) {
      await playAudioFromLocalFile(localFilePath);
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Audio player"),
        backgroundColor: Colors.lightGreen,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 100,),
            Slider(
              min: 0,
              max: _duration.inSeconds.toDouble(),
              value: _position.inSeconds.toDouble(),
              onChanged: (value) {
                _position = Duration(seconds: value.toInt());
                player.seek(_position);
                player.resume();
              },
            ),
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(formatTime(_position.inSeconds)),
                  Text(formatTime((_duration - _position).inSeconds)),
                ],
              ),
            ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    animateIcon();
                  },
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: iconController,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 15),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                SizedBox(width: 20),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.volume_down_outlined),
                ),
                Slider(
                  value: _volume,
                  onChanged: (newValue) {
                    setState(() {
                      _volume = newValue;
                    });
                    player.setVolume(_volume);
                  },
                  min: 0.0,
                  max: 1.0,
                  activeColor: Colors.lightGreen,
                  inactiveColor: Colors.grey,
                ),
              ],
            ),
            Row(
               children:[
                 SizedBox(width: 60),
                            Text("Download click button"),
           _progress != null
           ? CircularProgressIndicator() :
            IconButton(
              onPressed: ()  {
            downloadAudioFiles(audioUrl[currentAudioIndex]);
              },
              icon: Icon(Icons.download),
            ),

      IconButton(
        onPressed: ()  {
       },
       icon: Icon(Icons.file_copy),
          ),
              ]
            ),
          ],
        ),
      ),
    );
  }
  void requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();
}
  String formatTime(int seconds) {
    return '${Duration(seconds: seconds)}'.split(".")[0].padLeft(8, '0');
  }
  void animateIcon() {
    setState(() {
      isAnimated = !isAnimated;

      if (isAnimated) {
        iconController.forward();
        
        player.resume();
        
      } else {
        iconController.reverse();
        player.pause();
      }
    });
  }
  @override
  void dispose() {
    iconController.dispose();
    player.dispose();
    super.dispose();
  }

}
