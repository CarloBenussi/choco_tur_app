import 'package:choco_tur/utils/styles.dart';
import 'package:choco_tur/widgets/seek_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as chat_types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:focus_detector_v2/focus_detector_v2.dart';
import 'package:just_audio/just_audio.dart';

class AudioMessage extends StatefulWidget {
  const AudioMessage({
    super.key,
    required this.message,
    required this.messageWidth,
    required this.theme,
  });

  final chat_types.AudioMessage message;
  final int messageWidth;
  final ChatTheme theme;

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage> {
  final _player = AudioPlayer();
  final double _iconsSize = 24.0;

  @override
  void initState() {
    super.initState();

    _player.setAudioSource(AudioSource.uri(Uri.parse(widget.message.uri)));
  }

  @override
  Widget build(BuildContext context) {
    return FocusDetector(
      onFocusLost: () {
        _player.stop();
      },
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: widget.messageWidth.toDouble(),
        ),
        child: Container(
          decoration: BoxDecoration(color: widget.theme.secondaryColor),
          margin: EdgeInsets.only(
            right: widget.theme.messageInsetsHorizontal,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// This StreamBuilder rebuilds whenever the player state changes, which
              /// includes the playing/paused state and also the
              /// loading/buffering/ready state. Depending on the state we show the
              /// appropriate button or loading indicator.
              Flexible(
                child: StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playerState = snapshot.data;
                    final processingState = playerState?.processingState;
                    final playing = playerState?.playing;
                    if (processingState == ProcessingState.loading || processingState == ProcessingState.buffering) {
                      return IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Styles.onRedShade,
                        ),
                        iconSize: _iconsSize,
                        onPressed: null,
                      );
                    } else if (playing != true) {
                      return IconButton(
                        icon: const Icon(
                          Icons.play_arrow,
                          color: Styles.onRedShade,
                        ),
                        iconSize: _iconsSize,
                        onPressed: _player.play,
                      );
                    } else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        icon: const Icon(
                          Icons.pause,
                          color: Styles.onRedShade,
                        ),
                        iconSize: _iconsSize,
                        onPressed: _player.pause,
                      );
                    } else {
                      return IconButton(
                        icon: const Icon(
                          Icons.replay,
                          color: Styles.onRedShade,
                        ),
                        iconSize: _iconsSize,
                        onPressed: () => _player.seek(Duration.zero),
                      );
                    }
                  },
                ),
              ),
              // Display seek bar. Using StreamBuilder, this widget rebuilds
              // each time the position, buffered position or duration changes.
              Expanded(
                child: StreamBuilder<Duration>(
                  stream: _player.positionStream,
                  builder: (context, snapshot) {
                    return SeekBar(
                      duration: _player.duration ?? Duration.zero,
                      position: snapshot.data ?? Duration.zero,
                      onChanged: (duration) => _player.seek(duration),
                      onChangeEnd: _player.seek,
                    );
                  },
                ),
              ),
              Flexible(
                child: StreamBuilder<double>(
                  stream: _player.speedStream,
                  builder: (context, snapshot) => IconButton(
                    icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Styles.onRedShade,
                        )),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
