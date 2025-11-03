import 'package:anime_app/models/anime_model.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Tab choices for anime details screen
enum TabChoice { episodes, resume }

/// Base class for all AnimeDetails events
abstract class AnimeDetailsEvent extends Equatable {
  const AnimeDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load anime details
class AnimeDetailsLoadRequested extends AnimeDetailsEvent {
  final AnimeModel anime;
  final bool shouldLoadSuggestions;

  const AnimeDetailsLoadRequested({
    required this.anime,
    this.shouldLoadSuggestions = true,
  });

  @override
  List<Object?> get props => [anime, shouldLoadSuggestions];
}

/// Event to load related anime suggestions
class AnimeRelatedLoadRequested extends AnimeDetailsEvent {
  const AnimeRelatedLoadRequested();
}

/// Event to change the tab selection
class AnimeDetailsTabChanged extends AnimeDetailsEvent {
  final TabChoice tab;

  const AnimeDetailsTabChanged({required this.tab});

  @override
  List<Object?> get props => [tab];
}

/// Event to update background color extracted from image
class AnimeBackgroundColorExtracted extends AnimeDetailsEvent {
  final Color color;

  const AnimeBackgroundColorExtracted({required this.color});

  @override
  List<Object?> get props => [color];
}

/// Event to mark an episode as visualized
class EpisodeVisualized extends AnimeDetailsEvent {
  final String episodeId;

  const EpisodeVisualized({required this.episodeId});

  @override
  List<Object?> get props => [episodeId];
}
