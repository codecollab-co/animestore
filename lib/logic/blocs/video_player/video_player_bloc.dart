import 'dart:async' as async_lib;
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/logic/Constants.dart';
import 'package:anime_app/logic/blocs/video_player/video_player_event.dart';
import 'package:anime_app/logic/blocs/video_player/video_player_state.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

/// VideoPlayerBloc manages video playback state
/// Handles episode loading, video controls, and navigation
class VideoPlayerBloc extends Bloc<VideoPlayerEvent, VideoPlayerState> {
  final AnimeRepository _animeRepository;
  final Function(String episodeId, String? episodeTitle, int? viewedAt)? onEpisodeWatched;

  /// Full list of episodes for navigation (set via EpisodeListUpdated event)
  List<EpisodeModel> _episodeList = [];

  VideoPlayerBloc({
    required AnimeRepository animeRepository,
    this.onEpisodeWatched,
  })  : _animeRepository = animeRepository,
        super(const VideoPlayerInitial()) {
    on<EpisodeLoadRequested>(_onEpisodeLoadRequested);
    on<EpisodeListUpdated>(_onEpisodeListUpdated);
    on<VideoPlayToggled>(_onVideoPlayToggled);
    on<VideoPositionChanged>(_onVideoPositionChanged);
    on<NextEpisodeRequested>(_onNextEpisodeRequested);
    on<PreviousEpisodeRequested>(_onPreviousEpisodeRequested);
    on<EpisodeLoadingCanceled>(_onEpisodeLoadingCanceled);
    on<VideoSeeked>(_onVideoSeeked);
    on<VideoPlayerDisposed>(_onVideoPlayerDisposed);
  }

  /// Update episode list for navigation
  void _onEpisodeListUpdated(
    EpisodeListUpdated event,
    Emitter<VideoPlayerState> emit,
  ) {
    _episodeList = event.episodes;
  }

  /// Load episode details and initialize video player
  Future<void> _onEpisodeLoadRequested(
    EpisodeLoadRequested event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (state.episodeStatus == EpisodeStatus.downloading) return;

    emit(const VideoPlayerLoading());

    try {
      print('Loading episode: ${event.animeTitle} - Episode ${event.episodeNumber}');

      // Get episode with streaming details
      final episodeWithStreaming = await _animeRepository.getEpisodeStreamingDetails(
        animeTitle: event.animeTitle,
        episodeNumber: event.episodeNumber,
      );

      // Check if loading was canceled
      if (state.episodeStatus == EpisodeStatus.canceled) {
        return;
      }

      // Dispose old controller if exists
      if (state.controller != null) {
        state.controller!.removeListener(_createControllerListener(emit));
        await state.controller!.dispose();
      }

      // Get streaming URL from streamingInfo
      final streamingUrl = episodeWithStreaming.streamingInfo?.videoUrl ??
          episodeWithStreaming.streamingInfo?.qualities.firstOrNull?.url;

      if (streamingUrl == null) {
        throw Exception('No streaming URL available for this episode');
      }

      // Create new video player controller
      print('The url will be $streamingUrl');
      final controller = VideoPlayerController.network(
        streamingUrl,
        httpHeaders: episodeWithStreaming.streamingInfo?.headers ?? {},
      );

      // Initialize controller with timeout
      await controller.initialize().timeout(
        const Duration(seconds: videoInitTimeout),
      );

      // Add listener for position updates
      controller.addListener(_createControllerListener(emit));

      emit(VideoPlayerReady(
        controller: controller,
        isPlaying: false,
        currentPosition: const Duration(milliseconds: 0),
        currentEpisode: episodeWithStreaming,
      ));

      // Auto-play
      add(const VideoPlayToggled());

      // Mark episode as watched
      if (onEpisodeWatched != null) {
        onEpisodeWatched!(
          episodeWithStreaming.id,
          episodeWithStreaming.title,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } on async_lib.TimeoutException catch (e) {
      print('VideoPlayerBloc::_onEpisodeLoadRequested TimeoutException: $e');
      emit(const VideoPlayerError(
        errorMessage: 'Video initialization timeout. Please try again.',
      ));
    } catch (e) {
      print('VideoPlayerBloc::_onEpisodeLoadRequested Error: $e');
      emit(VideoPlayerError(errorMessage: e.toString()));
    }
  }

  /// Toggle play/pause
  void _onVideoPlayToggled(
    VideoPlayToggled event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is! VideoPlayerReady) return;

    final currentState = state as VideoPlayerReady;
    final controller = currentState.controller;

    if (controller == null) return;

    if (controller.value.isPlaying) {
      controller.pause();
      emit(currentState.copyWith(isPlaying: false));
    } else {
      controller.play();
      emit(currentState.copyWith(isPlaying: true));
    }
  }

  /// Update video position
  void _onVideoPositionChanged(
    VideoPositionChanged event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is VideoPlayerReady) {
      final currentState = state as VideoPlayerReady;
      emit(currentState.copyWith(currentPosition: event.position));
    }
  }

  /// Navigate to next episode
  void _onNextEpisodeRequested(
    NextEpisodeRequested event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is! VideoPlayerReady) return;
    if (_episodeList.isEmpty) return;

    final currentState = state as VideoPlayerReady;
    final currentEpisode = currentState.currentEpisode;

    if (currentEpisode == null) return;

    // Find current episode index in the list
    final currentIndex = _episodeList.indexWhere((ep) => ep.id == currentEpisode.id);

    if (currentIndex == -1 || currentIndex >= _episodeList.length - 1) {
      // No next episode available
      return;
    }

    final nextEpisode = _episodeList[currentIndex + 1];
    _prepareControllerForEpisodeChange(currentState.controller);

    // Load next episode (requires anime title from event)
    add(EpisodeLoadRequested(
      animeTitle: event.animeTitle,
      episodeNumber: nextEpisode.number,
    ));
  }

  /// Navigate to previous episode
  void _onPreviousEpisodeRequested(
    PreviousEpisodeRequested event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is! VideoPlayerReady) return;
    if (_episodeList.isEmpty) return;

    final currentState = state as VideoPlayerReady;
    final currentEpisode = currentState.currentEpisode;

    if (currentEpisode == null) return;

    // Find current episode index in the list
    final currentIndex = _episodeList.indexWhere((ep) => ep.id == currentEpisode.id);

    if (currentIndex <= 0) {
      // No previous episode available
      return;
    }

    final previousEpisode = _episodeList[currentIndex - 1];
    _prepareControllerForEpisodeChange(currentState.controller);

    // Load previous episode (requires anime title from event)
    add(EpisodeLoadRequested(
      animeTitle: event.animeTitle,
      episodeNumber: previousEpisode.number,
    ));
  }

  /// Cancel episode loading
  void _onEpisodeLoadingCanceled(
    EpisodeLoadingCanceled event,
    Emitter<VideoPlayerState> emit,
  ) {
    emit(const VideoPlayerCanceled());
  }

  /// Seek to specific position
  void _onVideoSeeked(
    VideoSeeked event,
    Emitter<VideoPlayerState> emit,
  ) {
    if (state is! VideoPlayerReady) return;

    final currentState = state as VideoPlayerReady;
    final controller = currentState.controller;

    if (controller != null) {
      final seconds = event.seconds < 0 ? 0 : event.seconds;
      controller.seekTo(Duration(seconds: seconds));
    }
  }

  /// Dispose video player
  Future<void> _onVideoPlayerDisposed(
    VideoPlayerDisposed event,
    Emitter<VideoPlayerState> emit,
  ) async {
    if (state.controller != null) {
      state.controller!.removeListener(_createControllerListener(emit));
      await state.controller!.dispose();
    }
    emit(const VideoPlayerInitial());
  }

  /// Prepare controller for episode change
  void _prepareControllerForEpisodeChange(VideoPlayerController? controller) {
    if (controller != null) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
      // Listener will be removed in the next episode load
    }
  }

  /// Create controller listener that updates position and handles auto-play next
  VoidCallback _createControllerListener(Emitter<VideoPlayerState> emit) {
    return () {
      if (state is VideoPlayerReady) {
        final currentState = state as VideoPlayerReady;
        final controller = currentState.controller;

        if (controller != null) {
          // Update position
          add(VideoPositionChanged(position: controller.value.position));

          // Check if video ended and auto-play next episode
          if (controller.value.position.inMilliseconds >= controller.value.duration.inMilliseconds &&
              _episodeList.isNotEmpty &&
              currentState.currentEpisode != null) {
            // Find current episode index
            final currentIndex = _episodeList.indexWhere(
              (ep) => ep.id == currentState.currentEpisode!.id,
            );

            // Check if there's a next episode
            if (currentIndex != -1 && currentIndex < _episodeList.length - 1) {
              // Note: NextEpisodeRequested now requires animeTitle
              // This will need to be passed from the UI when creating the event
              // For now, we won't auto-play next episode
              // The UI should handle this by passing animeTitle
            }
          }
        }
      }
    };
  }

  @override
  Future<void> close() async {
    if (state.controller != null) {
      await state.controller!.dispose();
    }
    return super.close();
  }
}
