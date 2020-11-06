import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

MediaControl playControl = MediaControl(
    androidIcon: 'drawable/play',
    label: 'Play',
    action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/previous',
  label: 'Previous',
  action: MediaAction.play,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioPlayerTask extends BackgroundAudioTask{

  //the queue of audio media
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

    //listening for state
    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final bufferingState = event.buffering ? AudioProcessingState.buffering :null;
      switch(event.state){
        case AudioPlaybackState.paused:
          _setState(
              processingState: bufferingState ?? AudioProcessingState.ready,
              position: event.position);
          break;
        case AudioPlaybackState.playing:
          _setState(
              processingState: bufferingState ?? AudioProcessingState.ready,
              position: event.position);
          break;
        case AudioPlaybackState.connecting:
          _setState(
              processingState: _audioProcessingState ?? AudioProcessingState.connecting,
              position: event.position);
          break;
        default:
      }
    });

    // how we set the queue to the audio service in the background
    AudioServiceBackground.setQueue(_queue);
    onSkipToNext();

  }
  @override
  void onPlay() {
    if (_audioProcessingState == _audioProcessingState){
      _playing = true;
      _audioPlayer.play();
    }
  }
  @override
  void onPause() {
    _playing = false;
    _audioPlayer.pause();
  }

  void skip(int offset) async {
    int newPos = _queueIndex + offset;
    if(!(newPos >= 0 && newPos <_queue.length)){
      return;
    }
    if(_playing == null){
      _playing = true;
    }
    else if (_playing){
      await _audioPlayer.stop();
    }
    _queueIndex = newPos;
    _audioProcessingState = offset > 0
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    AudioServiceBackground.setMediaItem(mediaItem);
    await _audioPlayer.setUrl(mediaItem.id);
    _audioProcessingState = null;
    if(_playing){
      onPlay();
    }
    else{
      _setState(processingState: AudioProcessingState.ready);
    }
  }
  @override
  void onSkipToNext() async {
    skip(1);
  }
  @override
  void onSkipToPrevious() {
    skip(-1);
  }
  @override
  Future<void> onStop() async {
    _playing = false;
    await _audioPlayer.stop();
    await _audioPlayer.dispose();
    _playerStateSubscription.cancel();
    _eventSubscription.cancel();
    return await super.onStop();
  }

  @override
  void onSeekTo(Duration position) {
    _audioPlayer.seek(position);

  }

  void playPause() {
    if (AudioServiceBackground.state.playing)
      onPause();
    else
      onPlay();
  }


  @override
  void onClick(MediaButton button) {
    playPause();

  }

  //Handles moving the postion based on duration bounds
  Future<void> _seekRelative(Duration offset) async {
    var newPosition = _audioPlayer.playbackEvent.position + offset;
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }
    if (newPosition > mediaItem.duration) {
      newPosition = mediaItem.duration;
    }
    await _audioPlayer.seek(_audioPlayer.playbackEvent.position + offset);
  }


  @override
  Future<void> onFastForward() async {
    await _seekRelative(fastForwardInterval);
  }
  @override
  Future<void> onRewind() async {
    await _seekRelative(rewindInterval);

  }

  // make sure there is something in the queue, if not stop
  _handlePlaybackComplete(){
    if (hasNext) {
      onSkipToNext();
    } else {
      onStop();
    }
  }

  Future<void> _setState({
    AudioProcessingState processingState,
    Duration position,
    Duration bufferedPosition,
  }) async{
    if (position == null){
      position = _audioPlayer.playbackEvent.position;
    }
    await AudioServiceBackground.setState(
        controls: getControls(),
        systemActions: [MediaAction.seekTo],
        processingState:  processingState?? AudioServiceBackground.state.processingState,
        playing: _playing,
        position: position,
        speed: _audioPlayer.speed);
  }

  List<MediaControl> getControls(){
    if(_playing){
      return[
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl,
      ];
    }
    else{
      return[
        playControl,
        pauseControl,
        stopControl,
        skipToNextControl,
      ];
    }
  }
}

//Helps combines some streams to listen to them
class AudioState {
  final List<MediaItem> queue;
  final MediaItem mediaItem;
  final PlaybackState playbackState;

  AudioState(this.queue, this.mediaItem, this.playbackState);
}