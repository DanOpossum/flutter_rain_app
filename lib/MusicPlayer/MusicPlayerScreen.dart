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
  double volume = 70;

  _MusicPlayerScreenState();

  @override
  Widget build(BuildContext context) {
    var aa = Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
      ),
      body: SingleChildScrollView(
        child: Container(
          // padding: EdgeInsets.all(0.0),
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
                final playing = playBackState?.playing ?? false;
                // Can use this to check if playing
                // if (processingState == AudioProcessingState.none) ...[
                final processingState =
                    playBackState?.processingState ?? AudioProcessingState.none;
                return Container(
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        _soundChoices(mediaItem, playing),
                        _volumeController(),
                        _playerController(playing, mediaItem, queue),
                      ],
                    ));
              },
            ),
          ]),
        ),
      ),
    );

    return aa;
  }

  // Starts the main player of the map.. todo probably do this automatically
  _startAudioPlayBtn() {
    Slider aa = _volumeController();
    aa.onChanged(volume);

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

  InkWell soundButton(int i) {
    Decoration image;

    if (i == 1) {
      image = catBox();
    } else if (i == 2) {
      image = activeBox();
    } else {
      image = blankBox();
    }
    var newInkwell = InkWell(
        onTap: () async {
          AudioService.start(
              backgroundTaskEntrypoint: _audioTaskEntryPoint,
              androidNotificationChannelName: 'Audio Service Demo',
              androidNotificationColor: 0xFF2222f5,
              androidNotificationIcon: 'mipmap/ic_launcher');
        },
        child: new Container(
          width: 100.00,
          height: 100.00,
          decoration: image,
        ));

    return newInkwell;
  }

  BoxDecoration blankBox() {
    return BoxDecoration(
        image: new DecorationImage(
      image: ExactAssetImage('assets/square.png'),
      fit: BoxFit.fitHeight,
    ));
  }

  BoxDecoration activeBox() {
    return BoxDecoration(
        image: new DecorationImage(
      image: ExactAssetImage('assets/test.png'),
      fit: BoxFit.fitHeight,
    ));
  }

  BoxDecoration catBox() {
    return BoxDecoration(
        image: new DecorationImage(
      image: ExactAssetImage('assets/kitty-8-10.jpg'),
      fit: BoxFit.fitHeight,
    ));
  }

  _soundChoices(MediaItem mediaItem, bool playing) {
    return Container(
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 0.0,
              crossAxisSpacing: 0.0,
              // childAspectRatio: .750,
            ),
            delegate: SliverChildListDelegate(
              [
                mediaItem != null &&
                        mediaItem.title == "Epic Titanic Flute" &&
                        playing
                    ? soundButton(2)
                    : soundButton(1),
                soundButton(0),
                soundButton(0),
                soundButton(0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _volumeController() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: Colors.red[700],
        inactiveTrackColor: Colors.red[100],
        trackShape: RoundedRectSliderTrackShape(),
        trackHeight: 4.0,
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
        thumbColor: Colors.redAccent,
        overlayColor: Colors.red.withAlpha(32),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
        tickMarkShape: RoundSliderTickMarkShape(),
        activeTickMarkColor: Colors.red[700],
        inactiveTickMarkColor: Colors.red[100],
        valueIndicatorShape: PaddleSliderValueIndicatorShape(),
        valueIndicatorColor: Colors.redAccent,
        valueIndicatorTextStyle: TextStyle(
          color: Colors.white,
        ),
      ),
      child: Slider(
        value: volume,
        min: 0,
        max: 100,
        divisions: 10,
        label: '$volume',
        onChanged: (value) {
          setState(
            () {
              volume = value;
              AudioService.customAction("volume", volume);
            },
          );
        },
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
}

class BodyWidget extends StatelessWidget {
  final Color color;

  BodyWidget(this.color);

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => afterBuild);
    return Container(
      height: 10.0,
      color: color,
      alignment: Alignment.center,
    );
  }
}

void afterBuild() {
  // executes after build is done
}

void _audioTaskEntryPoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

// Used to combine some streams, passed through audiostate
Stream<AudioState> get _audioStateStream {
  // Combine 3 streams from audio player, pass through audiostate
  return Rx.combineLatest3<List<MediaItem>, MediaItem, PlaybackState,
      AudioState>(
    AudioService.queueStream,
    AudioService.currentMediaItemStream,
    AudioService.playbackStateStream,
    (
      queue,
      mediaItem,
      playbackState,
    ) =>
        AudioState(
      queue,
      mediaItem,
      playbackState,
    ),
  );
}
