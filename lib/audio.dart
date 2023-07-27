import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
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
  String audioUrl =
      'https://media.radioinstore.in/songs/Tamil/1987/rettai%20val%20kuruvi/raja%20raja%20cholan_kj%20jesudoss.mp3';
  String filename = "audio.mp3";

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

    playAudioFromURL(audioUrl);
    requestPermissions();
  }
void playAudioFromURL(String audioUrl) async {
    await player.setSourceUrl(audioUrl);
    player.resume();
  }
  void requestPermissions() async {
  Map<Permission, PermissionStatus> statuses = await [
    Permission.storage,
  ].request();

}

  String formatTime(int seconds) {
    return '${Duration(seconds: seconds)}'.split(".")[0].padLeft(8, '0');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Audio player"),
        backgroundColor: Colors.lightGreen,
      ),
      body:

      SingleChildScrollView(
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
           _progress != null ? CircularProgressIndicator() :
            IconButton(
              onPressed: ()  {
            downloadAudioFile();
              },
              icon: Icon(Icons.download),
            ),
              ]
            ),
          ],
        ),
      ),
    );
  }
void downloadAudioFile() {
  FileDownloader.downloadFile(
    url: audioUrl.toString().trim(),
    onProgress: (name, progress) {
      setState(() {
        _progress = progress;
      });
    },
  ).then((value) {
    
    print("Download completed.");
    setState(() {
      _progress = null;
    });
  }).catchError((error) {
    print("Download failed: $error");
    setState(() {
      _progress = null;
    });
  });
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
