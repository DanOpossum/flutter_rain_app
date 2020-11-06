import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rain_app/MusicPlayer/MusicPlayerScreen.dart';

void main() {
  runApp(
    HomeApp(),
  );
}

class HomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AudioServiceWidget(child: MusicPlayerScreen()),
    );
  }
}

