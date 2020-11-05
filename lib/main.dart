/*import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';*/
import 'package:flutter/material.dart';

typedef void OnError(Exception exception);

void main() {
  runApp(new MaterialApp(home: new ExampleApp()));
}

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => new _ExampleAppState();
}


class _ExampleAppState extends State<ExampleApp> {
  String localFilePath;
/*
  AudioPlayer advancedPlayer;
  AudioCache audioCache;*/

  Duration _duration = new Duration();
  Duration _position = new Duration();
  double _volume = .5;

  Widget _tab(List<Widget> children) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: children
              .map((w) => Container(child: w, padding: EdgeInsets.all(6.0)))
              .toList(),
        ),
      ),
    );
  }

  @override
  void initState(){
    super.initState();
    initPlayer();
  }

  void initPlayer(){
/*    advancedPlayer = new AudioPlayer();
    audioCache = new AudioCache(fixedPlayer: advancedPlayer);
    advancedPlayer.setReleaseMode(ReleaseMode.LOOP);

    advancedPlayer.durationHandler = (d) => setState(() {
      _duration = d;
    });

    advancedPlayer.positionHandler = (p) => setState(() {
      _position = p;
    });*/
  }

  Widget _btn(String txt, VoidCallback onPressed) {
    return ButtonTheme(
        minWidth: 48.0,
        child: RaisedButton(child: Text(txt), onPressed: onPressed));
  }

/*  void seekToSecond(int second){
    Duration newDuration = Duration(seconds: second);
    advancedPlayer.seek(newDuration);
  }

  void changeVolume(double vol){
    advancedPlayer.setVolume(vol);
  }*/

/*  Widget slider() {
    return Slider(
        value: _position.inSeconds.toDouble(),
        min: 0.0,
        max: _duration.inSeconds.toDouble(),
        onChanged: (double value) {
          setState(() {
            seekToSecond(value.toInt());
            value = value;
          });
        });
  }*/

  Widget volumeSlider() {
    return Slider(
        value: _volume,
        min: 0.0,
        max: 1.0,
        onChanged: (double value) {
          setState(() {
/*
            changeVolume(value);
*/
            _volume = value;
          });
        });
  }

  Widget localAsset() {
    return _tab([
      Text('Play Local Asset \'titanic_flute.mp3\':'),
/*      _btn('Play', () => audioCache.play('titanic_flute.mp3')),
      _btn('Pause',() => advancedPlayer.pause()),
      _btn('Stop', () => advancedPlayer.stop()),
      slider(),
      volumeSlider()*/
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Local Asset'),
            ],
          ),
/*
          title: Text('audioplayers Example'),
*/
        ),
        body: TabBarView(
          children: [localAsset()],
        ),
      ),
    );
  }
}
