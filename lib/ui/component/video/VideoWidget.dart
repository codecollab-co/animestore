import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/generated/l10n.dart';
import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_event.dart';
import 'package:anime_app/logic/blocs/video_player/video_player_bloc.dart';
import 'package:anime_app/logic/blocs/video_player/video_player_event.dart';
import 'package:anime_app/logic/blocs/video_player/video_player_state.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:anime_app/ui/component/video/LoadingVideoWidget.dart';
import 'package:anime_app/ui/component/video/UnavailableVideoWidget.dart';
import 'package:anime_app/ui/theme/ColorValues.dart';
import 'package:anime_app/ui/utils/UiUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock/wakelock.dart';

class VideoWidget extends StatefulWidget {
  final String animeTitle;
  final int episodeNumber;
  final List<EpisodeModel>? episodes; // Optional: for episode navigation

  const VideoWidget({
    Key? key,
    required this.animeTitle,
    required this.episodeNumber,
    this.episodes,
  }) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

enum _MenuOption { NEXT, PREVIOUS, EXIT }

class _VideoWidgetState extends State<VideoWidget>
    with TickerProviderStateMixin {
  late AnimationController animationController;

  late Animation<Offset> topDownTransition, downTopTransition;
  late Animation<double> opacityAnimation;

  late S locale;

  static const _DEFAULT_ASPECT_RATIO = 3 / 2;
  static const _BACKGROUND_OPACITY_LEVEL = .5;

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
    Wakelock.enable();
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
    );

    topDownTransition = Tween<Offset>(begin: Offset(.0, -50), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: animationController,
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.fastLinearToSlowEaseIn));

    downTopTransition = Tween<Offset>(begin: Offset(.0, 50), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: animationController,
            curve: Curves.fastLinearToSlowEaseIn,
            reverseCurve: Curves.fastLinearToSlowEaseIn));

    opacityAnimation = Tween<double>(begin: .0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Curves.easeIn,
            reverseCurve: Curves.easeIn));
  }

  @override
  void dispose() {
    animationController.dispose();
    Wakelock.disable();
    super.dispose();
  }

  Future<void> _prepareToLeave(BuildContext context) async {
    final bloc = context.read<VideoPlayerBloc>();
    final state = bloc.state;

    if (state.episodeStatus == EpisodeStatus.downloading) {
      bloc.add(const EpisodeLoadingCanceled());
    }

    if (state.controller != null && state.controller!.value.isPlaying) {
      await state.controller!.pause();
    }

    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    return BlocProvider(
      create: (context) {
        final bloc = VideoPlayerBloc(
          animeRepository: AnimeRepository(),
          onEpisodeWatched: (episodeId, title, viewedAt) {
            context.read<ApplicationBloc>().add(
                  EpisodeWatched(
                    episodeId: episodeId,
                    episodeTitle: title,
                    viewedAt: viewedAt,
                  ),
                );
          },
        );

        // Set episode list if provided
        if (widget.episodes != null) {
          bloc.add(EpisodeListUpdated(episodes: widget.episodes!));
        }

        // Load the requested episode
        bloc.add(EpisodeLoadRequested(
          animeTitle: widget.animeTitle,
          episodeNumber: widget.episodeNumber,
        ));

        return bloc;
      },
      child: _VideoPlayerContent(
        animationController: animationController,
        topDownTransition: topDownTransition,
        downTopTransition: downTopTransition,
        opacityAnimation: opacityAnimation,
        prepareToLeave: _prepareToLeave,
        locale: locale,
      ),
    );
  }
}

class _VideoPlayerContent extends StatelessWidget {
  final AnimationController animationController;
  final Animation<Offset> topDownTransition;
  final Animation<Offset> downTopTransition;
  final Animation<double> opacityAnimation;
  final Future<void> Function(BuildContext) prepareToLeave;
  final S locale;

  static const _DEFAULT_ASPECT_RATIO = 3 / 2;
  static const _BACKGROUND_OPACITY_LEVEL = .5;

  const _VideoPlayerContent({
    Key? key,
    required this.animationController,
    required this.topDownTransition,
    required this.downTopTransition,
    required this.opacityAnimation,
    required this.prepareToLeave,
    required this.locale,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: WillPopScope(
        onWillPop: () async {
          await prepareToLeave(context);
          return true;
        },
        child: Container(
          width: size.width,
          height: size.height,
          color: Colors.transparent,
          child: BlocConsumer<VideoPlayerBloc, VideoPlayerState>(
            listener: (context, state) {
              // Handle error state with potential error messages
              if (state is VideoPlayerError) {
                // Error is shown in the UI via UnavailableVideoWidget
                // No additional toast/snackbar needed
              }
            },
            builder: (context, state) {
              Widget currentWidget;

              switch (state.episodeStatus) {
                case EpisodeStatus.buffering:
                case EpisodeStatus.downloadingDone:
                case EpisodeStatus.downloading:
                case EpisodeStatus.none:
                  currentWidget = buildLoaderWidget(context);
                  break;

                case EpisodeStatus.canceled:
                  currentWidget = Container();
                  break;

                case EpisodeStatus.error:
                  final videoWidget = context.widget as VideoWidget;
                  currentWidget = UnavailableVideoWidget(
                    retryCallback: () => context
                        .read<VideoPlayerBloc>()
                        .add(EpisodeLoadRequested(
                          animeTitle: videoWidget.animeTitle,
                          episodeNumber: videoWidget.episodeNumber,
                        )),
                    onBackCallback: () async {
                      await prepareToLeave(context);
                      Navigator.pop(context);
                    },
                  );
                  break;

                case EpisodeStatus.ready:
                  currentWidget = buildPlayerWidget(context, size, state);
                  animationController.forward(from: .0);
                  break;
              }
              return currentWidget;
            },
          ),
        ),
      ),
    );
  }

  Widget buildPlayerWidget(
          BuildContext context, Size size, VideoPlayerState state) =>
      GestureDetector(
        onTap: () {
          if (animationController.isCompleted) {
            animationController.reverse();
          } else {
            animationController.forward();
          }
        },
        child: Container(
          width: size.width,
          height: size.height,
          color: Colors.transparent,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.center,
                child: AspectRatio(
                  aspectRatio: _DEFAULT_ASPECT_RATIO,
                  child: VideoPlayer(state.controller!),
                ),
              ),

              // Background overlay
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: animationController,
                  builder: (_, __) {
                    return FadeTransition(
                      opacity: opacityAnimation,
                      child: Container(
                        color:
                            Colors.black.withOpacity(_BACKGROUND_OPACITY_LEVEL),
                      ),
                    );
                  },
                ),
              ),

              AnimatedBuilder(
                animation: animationController,
                builder: (_, __) => SlideTransition(
                  position: topDownTransition,
                  child: buildTopBarWidget(context, size, state),
                ),
              ),
              AnimatedBuilder(
                  animation: animationController,
                  builder: (_, __) => FadeTransition(
                        opacity: opacityAnimation,
                        child: buildCenterControllersWidget(
                            context, size, animationController.isCompleted, state),
                      )),
              AnimatedBuilder(
                animation: animationController,
                builder: (_, __) => SlideTransition(
                  position: downTopTransition,
                  child: buildBottomBarWidget(context, size, state),
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildLoaderWidget(BuildContext context) => Center(
        child: LoadingVideoWidget(
          onCancel: () async {
            await prepareToLeave(context);
            Navigator.pop(context);
          },
        ),
      );

  Widget buildTopBarWidget(
          BuildContext context, Size size, VideoPlayerState state) =>
      Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: size.width,
          height: 100,
          color: Colors.transparent,
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: .0,
            centerTitle: true,
            leading: Container(),
            actionsIconTheme: IconThemeData(color: Colors.white),
            actions: <Widget>[
              PopupMenuButton<_MenuOption>(
                itemBuilder: (context) {
                  final videoWidget = context.widget as VideoWidget;
                  return popupMenuItems(locale, state, videoWidget.episodes);
                },
                color: Colors.transparent,
                elevation: .0,
                offset: Offset(100, 40),
                onSelected: (option) async {
                  final videoWidget = context.widget as VideoWidget;
                  switch (option) {
                    case _MenuOption.NEXT:
                      context
                          .read<VideoPlayerBloc>()
                          .add(NextEpisodeRequested(animeTitle: videoWidget.animeTitle));
                      break;

                    case _MenuOption.PREVIOUS:
                      context
                          .read<VideoPlayerBloc>()
                          .add(PreviousEpisodeRequested(animeTitle: videoWidget.animeTitle));
                      break;

                    case _MenuOption.EXIT:
                      await prepareToLeave(context);
                      Navigator.pop(context);
                      break;
                  }
                },
              ),
            ],
            title: Container(
              width: size.width,
              height: 100,
              child: Text(
                state.currentEpisode?.title ?? '',
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      );

  Widget buildCenterControllersWidget(
          BuildContext context, Size size, bool available, VideoPlayerState state) =>
      Align(
        alignment: Alignment.center,
        child: Container(
          width: size.width,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(
                disabledColor: Colors.white,
                color: Colors.white,
                iconSize: 65.0,
                icon: Icon(
                  Icons.replay_10,
                ),
                onPressed: available
                    ? () => context
                        .read<VideoPlayerBloc>()
                        .add(VideoSeeked(
                            seconds: state.currentPosition.inSeconds - 10))
                    : null,
              ),
              IconButton(
                disabledColor: Colors.white,
                color: Colors.white,
                iconSize: 100,
                icon: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
                  builder: (context, state) {
                    var icon = state.isPlaying
                        ? Icons.pause_circle_outline
                        : Icons.play_circle_outline;
                    return Icon(
                      icon,
                    );
                  },
                ),
                onPressed:
                    available ? () => context.read<VideoPlayerBloc>().add(const VideoPlayToggled()) : null,
              ),
              IconButton(
                disabledColor: Colors.white,
                iconSize: 65.0,
                color: Colors.white,
                icon: Icon(
                  Icons.forward_10,
                ),
                onPressed: available
                    ? () => context
                        .read<VideoPlayerBloc>()
                        .add(VideoSeeked(
                            seconds: state.currentPosition.inSeconds + 10))
                    : null,
              ),
            ],
          ),
        ),
      );

  Widget buildBottomBarWidget(
          BuildContext context, Size size, VideoPlayerState state) =>
      Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: size.width,
          height: 80,
          color: Colors.transparent,
          child: BlocBuilder<VideoPlayerBloc, VideoPlayerState>(
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SliderTheme(
                    data: SliderThemeData(
                      thumbColor: accentColor,
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                    ),
                    child: Container(
                      height: 30,
                      margin: EdgeInsets.zero,
                      padding: EdgeInsets.zero,
                      child: Slider(
                        activeColor: accentColor,
                        value: state.currentPosition.inSeconds.toDouble(),
                        min: .0,
                        max: state.controller?.value.duration.inSeconds
                                .toDouble() ??
                            0.0,
                        onChanged: (value) => context
                            .read<VideoPlayerBloc>()
                            .add(VideoSeeked(seconds: value.toInt())),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      margin: EdgeInsets.only(left: 24.0, bottom: 8.0),
                      child: Text(
                        "${_printDuration(state.currentPosition)}" +
                            " / ${_printDuration(state.controller?.value.duration ?? Duration.zero)}",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            },
          ),
        ),
      );

  String _printDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes);
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  List<PopupMenuItem<_MenuOption>> popupMenuItems(
    S locale,
    VideoPlayerState state,
    List<EpisodeModel>? episodes,
  ) {
    List<PopupMenuItem<_MenuOption>> widgetList = [];

    // Check if there's a previous episode by finding current episode index
    bool hasPrevious = false;
    bool hasNext = false;

    if (state.currentEpisode != null && episodes != null && episodes.isNotEmpty) {
      final currentIndex = episodes.indexWhere(
        (ep) => ep.id == state.currentEpisode!.id,
      );

      if (currentIndex > 0) {
        hasPrevious = true;
      }

      if (currentIndex != -1 && currentIndex < episodes.length - 1) {
        hasNext = true;
      }
    }

    if (hasPrevious) {
      widgetList.add(UiUtils.createMenuItem<_MenuOption>(
        icon: Icon(
          Icons.skip_previous,
          color: Colors.white,
        ),
        value: _MenuOption.PREVIOUS,
        title: locale.previous,
      ));
    }

    if (hasNext) {
      widgetList.add(UiUtils.createMenuItem<_MenuOption>(
        icon: Icon(
          Icons.skip_next,
          color: Colors.white,
        ),
        value: _MenuOption.NEXT,
        title: locale.next,
      ));
    }

    widgetList.add(UiUtils.createMenuItem(
      icon: Icon(
        Icons.exit_to_app,
        color: Colors.white,
      ),
      value: _MenuOption.EXIT,
      title: locale.quit,
    ));
    return widgetList;
  }
}
