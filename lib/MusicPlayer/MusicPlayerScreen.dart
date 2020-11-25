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
  _MusicPlayerScreenState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(20.0),
          color: Colors.white,
          child: new Column(mainAxisSize: MainAxisSize.max, children: [
            // The background audio player will communicate with the help of streams to the ui
            // we are listening to the audioplayers streams
            new StreamBuilder<AudioState>(
              stream: _audioStateStream,
              builder: (context, snapshot) {
                final audioState = snapshot.data;
                final queue = audioState?.queue;
                final mediaItem = audioState?.mediaItem;
                final playBackState = audioState?.playbackState;
                // final volumeState = audioState?.volumeState;

                final processingState =
                    playBackState?.processingState ?? AudioProcessingState.none;
                final playing = playBackState?.playing ?? false;
                final double volume = 1;

                return Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _soundChoices(),
                        // SizedBox(height: 20),
                        _playerController(playing, mediaItem, queue),
                        _volumeController(volume),
                      ],
                    ));
              },
            ),
          ]),
        ),
      ),
    );
  }

  // Starts the main player of the map.. todo probably do this automatically
  _startAudioPlayBtn() {
    return MaterialButton(
      child: Text('Start Audio Player'),
      onPressed: () async {

      

        AudioService.start(
            backgroundTaskEntrypoint: _audioTaskEntryPoint,
            androidNotificationChannelName: 'Audio Service Demo',
            androidNotificationColor: 0xFF2222f5,
            androidNotificationIcon: 'mipmap/ic_launcher');
      },
    );
  }

  // Can use this to check if playing
  // if (processingState == AudioProcessingState.none) ...[

  _soundChoices() {
    return Container(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverGrid(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
            delegate: SliverChildListDelegate(
              [
                IconButton(
                  icon: Image.asset('assets/kitty-8-10.jpg'),
                  iconSize: 50,
                  onPressed: () async {
                    AudioService.start(
                        backgroundTaskEntrypoint: _audioTaskEntryPoint,
                        androidNotificationChannelName: 'Audio Service Demo',
                        androidNotificationColor: 0xFF2222f5,
                        androidNotificationIcon: 'mipmap/ic_launcher');
                  },
                ),
                IconButton(
                    icon: Image.asset('assets/kitty-8-10.jpg'),
                    iconSize: 50,
                    onPressed: () {}),
                IconButton(
                    icon: Image.asset('assets/kitty-8-10.jpg'),
                    iconSize: 50,
                    onPressed: () {}),
                IconButton(
                    icon: Image.asset('assets/kitty-8-10.jpg'),
                    iconSize: 50,
                    onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _playerController(bool playing, MediaItem mediaItem, List<MediaItem> queue) {
    return Row(
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
            onPressed: () {
              if (mediaItem == queue.first) {
                return;
              }
              AudioService.skipToPrevious();
            }),
        IconButton(
            icon: Icon(Icons.skip_next),
            iconSize: 64.0,
            onPressed: () {
              if (mediaItem == queue.last) {
                return;
              }
              AudioService.skipToNext;
            }),
      ],
    );
  }

  _volumeController(double _volume) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.red[700],
        inactiveTrackColor: Colors.red[100],
        trackShape: RectangularSliderTrackShape(),
        trackHeight: 4.0,
        thumbColor: Colors.redAccent,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayColor: Colors.red.withAlpha(32),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
      ),
      child: Slider(
        value: _volume,
        onChanged: (value) {
          setState(() {
            _volume = value;
            AudioService.customAction("volume",_volume);
          });
        },
      ),
    );
  }
}

class BodyWidget extends StatelessWidget {
  final Color color;

  BodyWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.0,
      color: color,
      alignment: Alignment.center,
    );
  }
}

void _audioTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

void _audioTaskVolume() async {
  // AudioServiceBackground.setv(() => AudioPlayerTask().setVolume(.1));
}

// Used to combine some streams, passed through audiostate
Stream<AudioState> get _audioStateStream {
  // Combine 3 streams from audio player, pass through audiostate
  return Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,

    (queue, mediaItem, playbackState,) => AudioState(
      queue,
      mediaItem,
      playbackState,
    ),
  );
}
