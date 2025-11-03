import 'package:anime_app/models/episode_model.dart';
import 'package:equatable/equatable.dart';

/// Episode loading status enum
enum EpisodeStatus {
  downloading,
  downloadingDone,
  canceled,
  error,
  buffering,
  ready,
  none,
}

/// Base class for all VideoPlayer events
abstract class VideoPlayerEvent extends Equatable {
  const VideoPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to update the full episode list for navigation
class EpisodeListUpdated extends VideoPlayerEvent {
  final List<EpisodeModel> episodes;

  const EpisodeListUpdated({required this.episodes});

  @override
  List<Object?> get props => [episodes];
}

/// Event to load episode details and initialize player
class EpisodeLoadRequested extends VideoPlayerEvent {
  final String animeTitle;
  final int episodeNumber;

  const EpisodeLoadRequested({
    required this.animeTitle,
    required this.episodeNumber,
  });

  @override
  List<Object?> get props => [animeTitle, episodeNumber];
}

/// Event to toggle play/pause
class VideoPlayToggled extends VideoPlayerEvent {
  const VideoPlayToggled();
}

/// Event to update video position
class VideoPositionChanged extends VideoPlayerEvent {
  final Duration position;

  const VideoPositionChanged({required this.position});

  @override
  List<Object?> get props => [position];
}

/// Event to navigate to next episode
class NextEpisodeRequested extends VideoPlayerEvent {
  final String animeTitle;

  const NextEpisodeRequested({required this.animeTitle});

  @override
  List<Object?> get props => [animeTitle];
}

/// Event to navigate to previous episode
class PreviousEpisodeRequested extends VideoPlayerEvent {
  final String animeTitle;

  const PreviousEpisodeRequested({required this.animeTitle});

  @override
  List<Object?> get props => [animeTitle];
}

/// Event to cancel episode loading
class EpisodeLoadingCanceled extends VideoPlayerEvent {
  const EpisodeLoadingCanceled();
}

/// Event to seek to specific position
class VideoSeeked extends VideoPlayerEvent {
  final int seconds;

  const VideoSeeked({required this.seconds});

  @override
  List<Object?> get props => [seconds];
}

/// Event to dispose video player
class VideoPlayerDisposed extends VideoPlayerEvent {
  const VideoPlayerDisposed();
}
