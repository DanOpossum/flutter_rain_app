import 'dart:async';
import 'dart:html';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

MediaControl playControl = MediaControl(
    androidIcon: 'drawable/play_arrow',
    label: 'Play',
    action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/skip_to_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/skip_to_prev',
  label: 'Previous',
  action: MediaAction.play,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioPlayerTask extends BackgroundAudioTask{

  final _queue = <MediaItem>[
    MediaItem(
      id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 5739820),
      artUri:
      "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
    ),
    MediaItem(
      id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
      album: "Science Friday",
      title: "From Cat Rheology To Operatic Incompetence",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 2856950),
      artUri:
      "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg",
    ),
  ];

  int _queueIndex = -1;
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioProcessingState _audioProcessingState;
  bool _playing;
  bool get hasNext => _queueIndex +1 <_queueIndex;
  bool get hasPrevious => _queueIndex > 0;
  MediaItem get mediaItem => _queue[_queueIndex];

  StreamSubscription<AudioPlaybackState> _playerStateSubscription;
  StreamSubscription<AudioPlaybackEvent> _eventSubscription;

  @override
  void onStart(Map<String, dynamic> params) {
    _playerStateSubscription =
        _audioPlayer.playbackStateStream.where((state) =>state ==
            AudioPlaybackState.completed).listen((state) {_handlePlaybackComplete();});
  }
  @override
  void onPlay() {
  }
  @override
  void onPause() {
  }
  @override
  void onSkipToNext() async {

  }
  @override
  void onSkipToPrevious() {

  }
  void skip(int offset) async {

  }
  @override
  Future<void> onStop() async {
  }
  @override
  void onSeekTo(Duration position) {

  }
  @override
  void onClick(MediaButton button) {
  }
  @override
  Future<void> onFastForward() async {
  }
  @override
  Future<void> onRewind() async {
  }

  _handlePlaybackComplete(){

  }

}