import 'dart:io';
import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/models.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class EpisodeDownload extends StatefulWidget {
  const EpisodeDownload({
    super.key, 
    required this.episode
  });

  final Episode? episode;

  @override
  State<EpisodeDownload> createState() => _EpisodeDownloadState();
}

class _EpisodeDownloadState extends State<EpisodeDownload> {
  final ValueNotifier<double?> progress = ValueNotifier<double?>(null);

  // Dio interface
  final Dio dio = Dio();

  void download(Uri uri, String path){
    // Start download
    progress.value = 0.0;
    progress.notifyListeners();

    final directory = ServiceContext.of(context).controller.directory;
    
    String filepath = '${directory!.path}/${widget.episode!.id}.mp3';
    dio.download(uri.toString(), filepath, onReceiveProgress: (received, total){
      // clamp progress to 0.0 - 1.0
      final clamped = received.clamp(0, total).toDouble() / total.toDouble();
      progress.value = clamped;
      progress.notifyListeners();
      if(clamped == 1.0){
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;

    final String name = "${widget.episode?.id ?? 'empty'}.mp3";
    final File local = services.localEpisodeFile(name);
    
    final exists = !kIsWeb && local.existsSync();

    return InkWell(
      customBorder: const CircleBorder(),
      onTap: widget.episode != null ? () async {
        if (exists) {
          await local.delete();
          setState(() {});
        } else {
          download(widget.episode!.audio!, name);
        }
      } : null,
      child: ValueListenableBuilder<double?>(
        valueListenable: progress,
        builder: (context, progress, _) {
          return SizedBox(
            height: 50,
            width: 50,
            child: Center(
              child: Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Opacity(
                      opacity: exists ? 1.0 : 0.3,
                      child: kIsWeb ? null : Icon(
                        exists ? PhosphorIcons.bold.x : PhosphorIcons.bold.arrowLineDown, 
                        color: Theme.of(context).colorScheme.secondary
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      value: 1.0, 
                      strokeWidth: 2, 
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary.withOpacity(0.2))
                    ),
                  ),
                  SizedBox(
                    width: 38,
                    height: 38,
                    child: CircularProgressIndicator(
                      value: exists ? 0.0 : (progress != null ? (progress > 0 ? progress : null) : 0.0),
                      strokeWidth: 2, 
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary)
                    ),
                  )
                ],
              ),
            ),
          );
        }
      ),
    );
  }
}
