import 'package:anime_app/models/episode_model.dart';
import 'package:anime_app/ui/component/video/VideoWidget.dart';
import 'package:flutter/material.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String animeTitle;
  final int episodeNumber;
  final List<EpisodeModel>? episodes;

  const VideoPlayerScreen({
    Key? key,
    required this.animeTitle,
    required this.episodeNumber,
    this.episodes,
  }) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  @override
  Widget build(BuildContext context) => VideoWidget(
        animeTitle: widget.animeTitle,
        episodeNumber: widget.episodeNumber,
        episodes: widget.episodes,
      );
}
