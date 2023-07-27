import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late AnimationController iconController;
  bool isAnimated = false;
  bool shopPause = false;
  double _volume = 1.0;
  bool isPlaying =false;
  Duration _duration= Duration.zero;
  Duration _position=Duration.zero;
  final player = AudioPlayer();
  String audioUrl =
   'https://media.radioinstore.in/songs/Tamil/1987/rettai%20val%20kuruvi/raja%20raja%20cholan_kj%20jesudoss.mp3';
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
}


  void playAudioFromURL(String audioUrl) async {
    await player.setSourceUrl(audioUrl);
    player.resume();
  }

  
String formatTime(int seconds){
  return '${(Duration(seconds: seconds))}'.split(".")[0].padLeft(8,'0');
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Audio player"),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Slider(
              min:0 ,
            max:_duration.inSeconds.toDouble(),
            value: _position.inSeconds.toDouble(),
             onChanged: (value){
            _position=Duration(seconds: value.toInt());
              player.seek(_position);
              player.resume();
             }
             ),
             Container(
              padding: const EdgeInsets.all(20),
             child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Text(formatTime(_position.inSeconds)),
                Text(formatTime((_duration -_position).inSeconds)),
              ],
               ),
             ),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 15),
                //backward button
             /*IconButton(
                  icon: Icon(CupertinoIcons.backward_fill),
                  onPressed: () {
              //      player.seek(Duration(seconds: player.duration.inSeconds - 30));
                  },
                ),*/
                SizedBox(width: 15),
                //play pause button
                GestureDetector(
                  onTap: () {
                    AnimateIcon();
                  },
                  child: AnimatedIcon(
                    icon: AnimatedIcons.play_pause,
                    progress: iconController,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
                SizedBox(width: 15),
                //forward button
         /*       IconButton(
                  icon: Icon(CupertinoIcons.forward_fill),
                  onPressed: () {
                //    player.seek(Duration(seconds: player.duration.inSeconds + 30));
                  },
                ),*/
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
          ],
        ),
      ),
    );
  }

 //animation icon for play/pause
  void AnimateIcon() {
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
