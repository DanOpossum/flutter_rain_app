import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rain_app/MusicPlayer/AudioPlayer.dart';
import 'package:rxdart/rxdart.dart';

class MusicPlayerScreen extends StatefulWidget {
  @override
  _MusicPlayerScreenState createState() => _MusicPlayerScreenState();
}

// The main UI for the Music Player
class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        title: Text ('Music Player'),
      ),
      body: Container(
        padding: EdgeInsets.all(20.0),
        color: Colors.white,
        // Background audio player will communicate with the help of streams to the ui
        // we are listening to the audioplayers streams
        child: StreamBuilder<AudioState>(
            stream: _audioStateStream,
            builder: (context, snapshot){
              final audioState = snapshot.data;
              final queue = audioState?.queue;
              final mediaItem = audioState?.mediaItem;
              final playBackState =  audioState?.playbackState;
              final processingState = playBackState?.processingState ?? AudioProcessingState.none;
              final playing = playBackState?.playing ?? false;

              return Container(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if(processingState == AudioProcessingState.none)...[
                       _startAudioPlayBtn(),
                    ]else...[
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // The main media player buttons
                        children: [
                          !playing
                              ? IconButton(
                                 icon: Icon(Icons.play_arrow),
                                 iconSize: 64.0,
                                 onPressed: AudioService.play)
                              : IconButton(
                                 icon: Icon(Icons.pause),
                                 iconSize: 64.0,
                                 onPressed: AudioService.pause),
                              IconButton(
                                 icon: Icon(Icons.skip_previous),
                                  iconSize: 64.0,
                                  onPressed: (){
                                   if(mediaItem == queue.first){return;}
                                   AudioService.skipToPrevious();
                                 }),
                              IconButton(
                                 icon: Icon(Icons.skip_next),
                                  iconSize: 64.0,
                                  onPressed: (){
                                   if(mediaItem == queue.last){return;}
                                   AudioService.skipToNext;
                                 }),
                        ],
                      )
                    ]
                  ],
                )
              );
            },
            ),
      ),
    );
 }

 // Starts the main player of the map.. todo probably do this automatically
  _startAudioPlayBtn() {
    return MaterialButton(
      child: Text('Start Audio Player'),
      onPressed: () async {
        await AudioService.start(
            backgroundTaskEntrypoint: _audioTaskEntryPoint,
            androidNotificationChannelName: 'Audio Service Demo',
            androidNotificationColor:  0xFF2222f5,
            androidNotificationIcon: 'mipmap/ic_launcher');
      },
    );
  }
}

void _audioTaskEntryPoint() async{
  AudioServiceBackground.run(()=> AudioPlayerTask());
}

// Used to combine some streams, passed through audiostate
Stream<AudioState> get _audioStateStream {
  // Combine 3 streams from audio player, pass through audiostate
  return Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,
        (queue, mediaItem, playbackState) =>
            AudioState(queue, mediaItem, playbackState,),
  );
}


