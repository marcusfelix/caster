import 'dart:io';

import 'package:app/components/mini_player.dart';
import 'package:app/controllers/config_controller.dart' if (dart.library.html) 'package:app/controllers/config_controller_web.dart';
import 'package:app/includes/default.dart';
import 'package:app/includes/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webfeed/webfeed.dart';

class ServiceContext extends InheritedWidget {
  const ServiceContext({
    Key? key, 
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final ServiceController controller;

  static ServiceContext of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType()!;
  }

  @override
  bool updateShouldNotify(ServiceContext oldWidget) {
    return oldWidget.controller != controller;
  }
}


class ServiceController {

  // Firebase Services
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final analytics = FirebaseAnalytics.instance;
  final firestore = FirebaseFirestore.instance;
  late FirebaseAnalyticsObserver observer;

  // Dio interface
  final Dio dio = Dio();

  // Local Storage
  late SharedPreferences local;

  // App directory
  late Directory? directory;

  // Global Scaffold Key
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  // Config params
  final ValueNotifier<Map<String, dynamic>> configs = ConfigController(defaultConfigs);

  // Library data
  final ValueNotifier<List<Episode>> episodes = ValueNotifier([]);

  // Audio Player
  final AudioPlayer player = AudioPlayer();

  // Current Episode
  final ValueNotifier<Episode?> episode = ValueNotifier<Episode?>(null);

  // Persistent Bottom Sheet
  PersistentBottomSheetController? _sheet;

  // Get current position
  Duration? get duration => player.duration;

  ServiceController(SharedPreferences storage, Directory? dir){
    directory = dir;
    local = storage;
    observer = FirebaseAnalyticsObserver(analytics: analytics);
    load();
  }

  Future<void> init() async {
    // Disable Google Analytics 
    analytics.setAnalyticsCollectionEnabled(false);
    
    await emulators();
  }

  void load(){
    // Load from local storage
    final episodes = local.getString("episodes");
    if(episodes != null) {
      parse(episodes);
    }

    // Fetch from remote
    fetch();
  }

  Future fetch() async {
    // Load from remote
    final response = await dio.get(configs.value['podcast_rss_feed_string']);
    if(response.statusCode == 200) {
      parse(response.data);
      await local.setInt("last-fetch", DateTime.now().millisecondsSinceEpoch);
    }
  }

  void parse(String body) async {
    RssFeed feed = RssFeed.parse(body);
    (feed.items ?? []).forEach((e) {
      episodes.value.add(Episode(
        id: e.guid ?? '',
        title: e.title ?? '',
        description: e.description ?? '',
        url: e.link ?? '',
        cover: e.itunes?.image?.href,
        duration: e.itunes?.duration ?? Duration.zero,
        date: e.pubDate ?? DateTime.now(),
        audio: e.enclosure?.url != null ? Uri.parse(e.enclosure!.url!) : null,
        local: localEpisodeFile("${e.guid ?? 'empty'}.mp3"),
      ));
    });
    episodes.notifyListeners();

    // Save feed to local storage
    await local.setString("episodes", body);

    // Recover last played episode
    final lastPlayed = local.getString("last-played");

    // Play last played episode
    if(lastPlayed != null && episode.value == null){
      final toPlay = episodes.value.firstWhere((element) => element.id == lastPlayed);
      play(toPlay, autoPlay: false);
    }
  }

  File localEpisodeFile(String filename){
    return File(directory != null ? '${directory!.path}/$filename' : '');
  }

  Future play(Episode toPlay, { bool autoPlay = true }) async {

    if(episode.value?.id != toPlay.id && autoPlay){
      showBanner();
    }
    
    Uri? uri = toPlay.audio;

    // Check if url exists
    if(uri == null) return;

    // Check if file exists locally
    if (!kIsWeb && toPlay.local.existsSync()) {
      uri = Uri.file(toPlay.local.path);
    }
    
    AudioSource source = AudioSource.uri(
      uri,
      tag: MediaItem(
        id: toPlay.id.toString(),
        title: toPlay.title,
        artUri: toPlay.cover != null ? Uri.parse(toPlay.cover!) : null,
      ),
    );

    episode.value = toPlay;

    player.setAudioSource(source);

    if(autoPlay){
      player.play();
    }

    // Persist last played episode
    await local.setString("last-played", toPlay.id);
  }

  Future stop() async {
    await player.stop();
    episode.value = null;
  }

  Future next() async {
    final lastPlayed = local.getString("last-played");
    if(lastPlayed == null) return;

    final index = episodes.value.indexWhere((e) => e.id == lastPlayed);
    if(index < episodes.value.length - 1){
      play(episodes.value[index + 1], autoPlay: true);
    }
  }

  Future previous() async {
    final lastPlayed = local.getString("last-played");
    if(lastPlayed == null) return;

    final index = episodes.value.indexWhere((e) => e.id == lastPlayed);
    if(index > 0){
      play(episodes.value[index - 1], autoPlay: true);
    }
  }

  void showBanner() async {
    if(_sheet == null){
      _sheet = scaffoldKey.currentState!.showBottomSheet((context) => MiniPlayer(
        key: Key(episode.value?.id ?? ""),
      ));
      await _sheet!.closed;
      _sheet = null;
    }
  }

  Future emulators() async {
    
  }
}