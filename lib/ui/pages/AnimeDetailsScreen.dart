import 'package:anime_app/generated/l10n.dart';
import 'package:anime_app/logic/blocs/anime_details/anime_details_bloc.dart';
import 'package:anime_app/logic/blocs/anime_details/anime_details_event.dart';
import 'package:anime_app/logic/blocs/anime_details/anime_details_state.dart';
import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_event.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/search_repository.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/ui/component/notification/CustomListNotification.dart';
import 'package:anime_app/ui/component/video/VideoWidget.dart';
import 'package:anime_app/ui/theme/ColorValues.dart';
import 'package:anime_app/ui/component/ItemView.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/UiUtils.dart';

class AnimeDetailsScreen extends StatelessWidget {
  final String? heroTag;
  final AnimeModel anime;

  const AnimeDetailsScreen({
    Key? key,
    this.heroTag,
    required this.anime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AnimeDetailsBloc(
        animeRepository: AnimeRepository(),
        searchRepository: SearchRepository(),
        anime: anime,
      )..add(AnimeDetailsLoadRequested(anime: anime)),
      child: _AnimeDetailsContent(
        heroTag: heroTag,
        anime: anime,
      ),
    );
  }
}

class _AnimeDetailsContent extends StatefulWidget {
  final String? heroTag;
  final AnimeModel anime;

  const _AnimeDetailsContent({
    Key? key,
    this.heroTag,
    required this.anime,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AnimeDetailsContentState();
}

class _AnimeDetailsContentState extends State<_AnimeDetailsContent>
    with SingleTickerProviderStateMixin {
  static const _RELATED_TAG = 'RELATED_TAG';
  late S locale;
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;
  late Animation scaleAnimation;
  final ScrollController listController = ScrollController();

  static final _defaultSectionStyle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    slideAnimation =
        Tween<Offset>(begin: Offset(400, .0), end: Offset.zero).animate(
      CurvedAnimation(
          curve: Curves.fastLinearToSlowEaseIn, parent: animationController),
    );

    scaleAnimation = Tween<double>(begin: .0, end: 1.0).animate(CurvedAnimation(
        curve: Interval(.4, 1.0, curve: Curves.easeInBack),
        parent: animationController));

    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    locale = S.of(context);

    final size = MediaQuery.of(context).size;
    final expandedHeight = size.width * .9;
    final provider = CachedNetworkImageProvider(
      widget.anime.imageUrl,
    );

    final image = Image(
      fit: BoxFit.fill,
      image: provider,
    );

    // in the future add a BlocBuilder widget to
    // handle the image predominant color as background color
    // state.backgroundColor
    final appBar = SliverAppBar(
      floating: false,
      pinned: false,
      snap: false,
      leading: Container(),
      expandedHeight: expandedHeight,
      backgroundColor: primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: widget.heroTag ?? UniqueKey().toString(),
          child: image,
        ),
      ),
    );

    return Scaffold(
      floatingActionButton: BlocBuilder<AnimeDetailsBloc, AnimeDetailsState>(
        builder: (context, detailsState) {
          if (detailsState is! AnimeDetailsLoaded) {
            return Container();
          }

          return BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, appState) {
              bool isInList = appState.myAnimeMap.containsKey(widget.anime.id);

              return AnimatedBuilder(
                animation: animationController,
                builder: (_, __) => Transform.scale(
                  scale: scaleAnimation.value,
                  origin: Offset.zero,
                  child: FloatingActionButton.extended(
                    backgroundColor: accentColor,
                    onPressed: () => (isInList) ? _removeFromList() : _addToList(),
                    label: Text((isInList) ? locale.removeFromList : locale.addToList),
                    icon: Icon((isInList)
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline),
                  ),
                ),
              );
            },
          );
        },
      ),
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: appBar,
              ),
              SliverToBoxAdapter(
                child: animeTitleSection(widget.anime.title),
              ),

              // sliver header with tab bars
              BlocBuilder<AnimeDetailsBloc, AnimeDetailsState>(
                builder: (context, state) {
                  Widget widget;
                  if (state is AnimeDetailsLoaded) {
                    widget = SliverPersistentHeader(
                      pinned: true,
                      floating: true,
                      delegate: _SliverAppBarDelegate(
                        TabBar(
                          labelColor: Colors.white,
                          indicatorColor: Colors.white,
                          tabs: <Widget>[
                            Tab(
                              text: locale.episodes,
                            ),
                            Tab(
                              text: locale.animeDetails,
                            ),
                          ],
                        ),
                        offsetValue: MediaQuery.of(context).padding.bottom,
                      ),
                    );
                  } else {
                    widget = emptySliver;
                  }

                  return widget;
                },
              ),
            ];
          },
          body: BlocBuilder<AnimeDetailsBloc, AnimeDetailsState>(
            builder: (context, state) {
              if (state is AnimeDetailsError) {
                return SingleChildScrollView(child: buildErrorWidget());
              }

              if (state is AnimeDetailsLoading) {
                return Container(
                  child: UiUtils.centredDotLoader(),
                );
              }

              if (state is! AnimeDetailsLoaded) {
                return Container();
              }

              return TabBarView(
                children: <Widget>[
                  _createWithSlideTransition(
                      child: buildEpisodesSection(state),
                      animation: slideAnimation,
                      controller: animationController),
                  _createWithSlideTransition(
                      child: buildMoreDetailsSection(state),
                      animation: slideAnimation,
                      controller: animationController),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _createWithSlideTransition(
      {required Widget child,
      required Animation<Offset> animation,
      required AnimationController controller}) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => SlideTransition(
        position: animation,
        child: child,
      ),
    );
  }

  Widget buildEpisodesSection(AnimeDetailsLoaded state) {
    final episodes = state.episodes;
    if (episodes == null || episodes.isEmpty) return Container();

    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final episode = episodes[index];

                return Container(
                  color: Color(0xFF131D2A),
                  margin: EdgeInsets.only(bottom: 4.0),
                  child: Material(
                    color: Colors.transparent,
                    elevation: .0,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => VideoWidget(
                                      animeTitle: state.currentAnime.title,
                                      episodeNumber: episode.number,
                                      episodes: episodes,
                                    )));
                      },
                      child: BlocBuilder<ApplicationBloc, ApplicationState>(
                        builder: (context, appState) {
                          var isWatched = appState.watchedEpisodeMap
                              .containsKey(episode.id);

                          return ListTile(
                            leading: Icon(
                              Icons.play_circle_outline,
                              size: 34.0,
                              color: (isWatched)
                                  ? accentColor
                                  : Colors.grey[300]?.withOpacity(.7),
                            ),
                            title: Text(
                              episode.title ?? 'Episode ${episode.number}',
                              style: TextStyle(
                                  color: (isWatched)
                                      ? accentColor
                                      : Colors.white,
                                  decoration: (isWatched)
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  decorationColor: Colors.white),
                            ),
                            trailing: IconButton(
                              tooltip: (isWatched)
                                  ? locale.markAsUnviewed
                                  : locale.markAsViewed,
                              onPressed: () {
                                if (isWatched) {
                                  context.read<ApplicationBloc>().add(
                                        EpisodeUnwatched(
                                            episodeId: episode.id),
                                      );
                                } else {
                                  context.read<ApplicationBloc>().add(
                                        EpisodeWatched(
                                            episodeId: episode.id,
                                            episodeTitle: episode.title,
                                            viewedAt: DateTime.now().millisecondsSinceEpoch),
                                      );
                                }
                              },
                              icon: Icon(
                                (isWatched)
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.white,
                              ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
              },
              childCount: episodes.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMoreDetailsSection(AnimeDetailsLoaded state) {
    // More details section - now shows info from currentAnime
    final anime = state.currentAnime;

    return SafeArea(
      top: false,
      bottom: false,
      child: CustomScrollView(
        shrinkWrap: true,
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildListDelegate.fixed(
              [
                buildDetailsSection(anime),
                buildResumeSection(anime.synopsis),
                (state.relatedAnimes != null)
                    ? buildAnimeSuggestionSection(state)
                    : Container(),
                Container(
                  height: 56.0,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _removeFromList() {
    context
        .read<ApplicationBloc>()
        .add(MyAnimeRemoved(animeId: widget.anime.id));
    _showNotificationToast(locale.removedFromList, false);
  }

  void _addToList() {
    context.read<ApplicationBloc>().add(
          MyAnimeAdded(
            animeId: widget.anime.id,
            anime: widget.anime,
          ),
        );
    _showNotificationToast(locale.addedToList, true);
  }

  void _showNotificationToast(String message, bool flag) {
    BotToast.showCustomNotification(
        dismissDirections: [DismissDirection.horizontal],
        onlyOne: true,
        toastBuilder: (_) {
          return CustomListNotification(
            imagePath: widget.anime.imageUrl,
            title: widget.anime.title,
            subtitle: message,
            flag: flag,
          );
        });
  }

  Widget animeTitleSection(String title) => Container(
        margin:
            const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0, bottom: .0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Flexible(
                child: Text(
                  title,
                  style: _defaultSectionStyle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      );

  Widget buildDetailsSection(AnimeModel anime) => Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          children: <Widget>[
            _buildInfoRow('${locale.genre}: ', anime.genres.join(', ')),
            _buildInfoRow('${locale.studio}: ', anime.studios.join(', ')),
            _buildInfoRow('${locale.episodes}: ', anime.episodeCount?.toString() ?? 'N/A'),
            _buildInfoRow('${locale.year}: ', anime.releaseYear ?? anime.year?.toString() ?? 'N/A'),
          ],
        ),
      );

  Widget buildResumeSection(String? resume) => Column(
        children: <Widget>[
          Text(
            locale.resume,
            style: TextStyle(fontSize: 20),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Flexible(
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      resume ?? '----',
                      maxLines: 24,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.justify,
                      style: TextStyle(letterSpacing: .2),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );

  Widget buildAnimeSuggestionSection(AnimeDetailsLoaded state) => Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 12.0,
              ),
              child: Text(
                locale.suggestion,
                style: _defaultSectionStyle,
              ),
            ),
            BlocBuilder<AnimeDetailsBloc, AnimeDetailsState>(
              builder: (context, detailsState) {
                if (detailsState is! AnimeDetailsLoaded) {
                  return Container();
                }

                if (detailsState.relatedAnimes == null) {
                  return Container(
                      margin: EdgeInsets.symmetric(vertical: 16.0),
                      child: UiUtils.centredDotLoader());
                } else if (detailsState.relatedAnimes!.isEmpty) {
                  return Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.symmetric(vertical: 16.0),
                          child: _buildUnavaiableWidget(
                            locale.noSuggestions,
                          ))
                    ],
                  );
                } else {
                  var width = MediaQuery.of(context).size.width * .42;
                  var height = width * 1.4;
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 12.0),
                    height: height,
                    child: ListView.builder(
                      controller: listController,
                      itemBuilder: (context, index) {
                        var anime = detailsState.relatedAnimes![index];
                        var heroTag = '${anime.id}$_RELATED_TAG';
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.0, vertical: 10.0),
                          child: ItemView(
                            width: width,
                            tooltip: anime.title,
                            height: height,
                            imageUrl: anime.imageUrl,
                            imageHeroTag: heroTag,
                            onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AnimeDetailsScreen(
                                  heroTag: heroTag,
                                  anime: anime,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      scrollDirection: Axis.horizontal,
                      itemCount: detailsState.relatedAnimes!.length,
                      physics: BouncingScrollPhysics(),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      );

  Widget get emptySliver => SliverToBoxAdapter(
        child: Container(),
      );

  Widget _buildInfoRow(String key, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(key, maxLines: 1),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavaiableWidget(String text, {IconData? iconData}) {
    return Container(
      margin: EdgeInsets.only(top: 16.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            iconData ?? Icons.do_not_disturb_alt,
            size: 52,
            color: accentColor,
          ),
          Container(
              margin: EdgeInsets.only(top: 4.0),
              child: Text(
                text,
                style: TextStyle(fontWeight: FontWeight.w500),
              )),
        ],
      ),
    );
  }

  Widget buildErrorWidget() => Center(
        child: Container(
          margin: EdgeInsets.only(top: 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.clear,
                color: Colors.red,
                size: 100,
              ),
              Text(locale.dataUnavailable),
              Container(
                margin: const EdgeInsets.only(top: 16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AnimeDetailsBloc>().add(
                          AnimeDetailsLoadRequested(anime: widget.anime),
                        );
                  },
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: Text(
                    locale.tryAgain,
                    style: TextStyle(color: textPrimaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    backgroundColor: accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar, {this.offsetValue = .0});

  final TabBar _tabBar;
  final double offsetValue;
  static const _PADDING = 32.0;
  @override
  double get minExtent => _tabBar.preferredSize.height + _PADDING + offsetValue;
  @override
  double get maxExtent => _tabBar.preferredSize.height + _PADDING + offsetValue;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        child: _tabBar,
        bottom: false,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
