import 'package:anime_app/logic/blocs/video_player/video_player_event.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

/// Base class for all VideoPlayer states
abstract class VideoPlayerState extends Equatable {
  final EpisodeStatus episodeStatus;
  final VideoPlayerController? controller;
  final bool isPlaying;
  final Duration currentPosition;
  final EpisodeModel? currentEpisode;

  const VideoPlayerState({
    required this.episodeStatus,
    this.controller,
    required this.isPlaying,
    required this.currentPosition,
    this.currentEpisode,
  });

  @override
  List<Object?> get props => [
        episodeStatus,
        controller,
        isPlaying,
        currentPosition,
        currentEpisode,
      ];
}

/// Initial state before any episode is loaded
class VideoPlayerInitial extends VideoPlayerState {
  const VideoPlayerInitial()
      : super(
          episodeStatus: EpisodeStatus.none,
          isPlaying: false,
          currentPosition: const Duration(milliseconds: 0),
        );
}

/// State when episode is being loaded/downloaded
class VideoPlayerLoading extends VideoPlayerState {
  const VideoPlayerLoading({
    VideoPlayerController? controller,
    bool isPlaying = false,
    Duration currentPosition = const Duration(milliseconds: 0),
    EpisodeModel? currentEpisode,
  }) : super(
          episodeStatus: EpisodeStatus.downloading,
          controller: controller,
          isPlaying: isPlaying,
          currentPosition: currentPosition,
          currentEpisode: currentEpisode,
        );
}

/// State when episode loading is canceled
class VideoPlayerCanceled extends VideoPlayerState {
  const VideoPlayerCanceled()
      : super(
          episodeStatus: EpisodeStatus.canceled,
          isPlaying: false,
          currentPosition: const Duration(milliseconds: 0),
        );
}

/// State when video is buffering
class VideoPlayerBuffering extends VideoPlayerState {
  const VideoPlayerBuffering({
    required VideoPlayerController controller,
    bool isPlaying = false,
    required Duration currentPosition,
    required EpisodeModel currentEpisode,
  }) : super(
          episodeStatus: EpisodeStatus.buffering,
          controller: controller,
          isPlaying: isPlaying,
          currentPosition: currentPosition,
          currentEpisode: currentEpisode,
        );
}

/// State when video is ready to play
class VideoPlayerReady extends VideoPlayerState {
  const VideoPlayerReady({
    required VideoPlayerController controller,
    required bool isPlaying,
    required Duration currentPosition,
    required EpisodeModel currentEpisode,
  }) : super(
          episodeStatus: EpisodeStatus.ready,
          controller: controller,
          isPlaying: isPlaying,
          currentPosition: currentPosition,
          currentEpisode: currentEpisode,
        );

  VideoPlayerReady copyWith({
    VideoPlayerController? controller,
    bool? isPlaying,
    Duration? currentPosition,
    EpisodeModel? currentEpisode,
  }) {
    return VideoPlayerReady(
      controller: controller ?? this.controller!,
      isPlaying: isPlaying ?? this.isPlaying,
      currentPosition: currentPosition ?? this.currentPosition,
      currentEpisode: currentEpisode ?? this.currentEpisode!,
    );
  }
}

/// State when episode loading/playing failed
class VideoPlayerError extends VideoPlayerState {
  final String errorMessage;

  const VideoPlayerError({
    required this.errorMessage,
  }) : super(
          episodeStatus: EpisodeStatus.error,
          isPlaying: false,
          currentPosition: const Duration(milliseconds: 0),
        );

  @override
  List<Object?> get props => [...super.props, errorMessage];
}
