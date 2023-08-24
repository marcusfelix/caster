import 'package:app/controllers/service_controller.dart';
import 'package:app/includes/models.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MiniPlayer extends StatelessWidget {
  MiniPlayer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final services = ServiceContext.of(context).controller;

    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      return Padding(
        padding: EdgeInsets.all(constraints.maxWidth > 414 ? 24.0 : 0),
        child: Material(
          color: Theme.of(context).colorScheme.secondaryContainer,
          child: SizedBox(
            height: 60,
            child: ValueListenableBuilder<Episode?>(
              valueListenable: services.episode,
              builder: (context, episode, _) {
                return episode != null ?  Column(
                  children: [
                    Container(
                      height: 3,
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: StreamBuilder(
                                stream: services.player.bufferedPositionStream,
                                builder: (BuildContext context, AsyncSnapshot<Duration> buffer) {
                                  return LinearProgressIndicator(
                                    value: ((buffer.data?.inMilliseconds ?? 0) * 1.0) / (episode.duration.inMilliseconds), 
                                    minHeight: 3, 
                                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary.withOpacity(0.2)), 
                                    backgroundColor: Colors.transparent
                                  );
                                }
                              ),
                            ),
                          ),
                          StreamBuilder<Duration?>(
                            stream: services.player.positionStream,
                            builder: (BuildContext context, AsyncSnapshot<Duration?> playback) {
                              return LinearProgressIndicator(
                                value: services.player.playerState.processingState == ProcessingState.ready ? ((playback.data?.inMilliseconds ?? 0) * 1.0) / (episode.duration.inMilliseconds) : null, 
                                minHeight: 3, 
                                valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary), 
                                backgroundColor: Colors.transparent
                              );
                            }
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 16),
                            child: episode.cover != null ? Image.network(
                              episode.cover!,
                              fit: BoxFit.cover,
                            ) : null,
                          ),
                          Expanded(
                            child: Text(
                              episode.title, 
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis, 
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.w700, 
                                color: Theme.of(context).colorScheme.onSecondaryContainer, 
                                fontSize: 16
                              )
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            height: 60,
                            child: Material(
                              color: Colors.transparent,
                              child: StreamBuilder<bool>(
                                initialData: false,
                                stream: services.player.playingStream,
                                builder: (BuildContext context, AsyncSnapshot<bool> playing) {
                                  return InkWell(
                                    child: Center(
                                      child: SizedBox(
                                        width: 32, 
                                        height: 32, 
                                        child: Icon((playing.data ?? false) ? PhosphorIcons.fill.pause : PhosphorIcons.fill.play, 
                                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      if (playing.data ?? false) {
                                        services.player.pause();
                                      } else {
                                        services.player.play();
                                      }
                                    },
                                  );
                                }
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ) : Container();
              }
            )
          ),
        ),
      );
    });
  }
}
