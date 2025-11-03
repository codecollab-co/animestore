import 'package:anime_app/generated/l10n.dart';
import 'package:anime_app/logic/Constants.dart';
import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_event.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/ui/component/EpisodeItemView.dart';
import 'package:anime_app/ui/component/ItemView.dart';
import 'package:anime_app/ui/component/TapableText.dart';
import 'package:anime_app/ui/component/TitleHeaderWidget.dart';
import 'package:anime_app/ui/pages/AnimeDetailsScreen.dart';
import 'package:anime_app/ui/pages/DefaultAnimeItemGridPage.dart';
import 'package:anime_app/ui/pages/GenreAnimePage.dart';
import 'package:anime_app/ui/pages/GenreGridPage.dart';
import 'package:anime_app/ui/pages/MyAnimeListPage.dart';
import 'package:anime_app/ui/pages/RecentEpisodeGridPage.dart';
import 'package:anime_app/ui/pages/VideoPlayerScreen.dart';
import 'package:anime_app/ui/theme/ColorValues.dart';
import 'package:anime_app/ui/utils/HeroTags.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/models/episode_model.dart';
import 'package:carousel_pro_nullsafety/carousel_pro_nullsafety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_color/random_color.dart';

class HomePage extends StatefulWidget {
  HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final RandomColor _randomColor = RandomColor();
  static const _SECTION_STYLE = TextStyle(
    fontSize: 18,
  );

  bool _isFirstHomePageView = true;
  late AnimationController controller;
  late Animation<Offset> carouselAnimation;
  late Animation<Offset> headerAnimation;
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    if (_isFirstHomePageView) {
      controller = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 1000),
      );

      carouselAnimation = Tween<Offset>(begin: Offset(50, .0), end: Offset.zero)
          .animate(CurvedAnimation(
              curve: Curves.fastLinearToSlowEaseIn, parent: controller));

      headerAnimation = Tween<Offset>(begin: Offset(-50, .0), end: Offset.zero)
          .animate(CurvedAnimation(
              curve: Curves.fastLinearToSlowEaseIn, parent: controller));

      controller.forward();
    }
  }

  @override
  void dispose() {
    _isFirstHomePageView = false;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    final S locale = S.of(context);

    final ScrollController topAnimesController = ScrollController();

    final ScrollController mostRecentController = ScrollController();

    final ScrollController genresController = ScrollController();

    final ScrollController myListController = ScrollController();

    final expandedHeight = size.width * .9;

    final carousel = _createDayReleaseCarousel(
      context: context,
      width: size.width,
      height: expandedHeight,
    );

    final appBar = SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      elevation: 0.0,
      pinned: false,
      snap: false,
      centerTitle: true,
      backgroundColor: primaryColor.withOpacity(.9),
      //title: Text('AppBar', style: TextStyle(color: Colors.black),),
      flexibleSpace: FlexibleSpaceBar(
          background: (_isFirstHomePageView)
              ? SlideTransition(
                  position: carouselAnimation,
                  child: carousel,
                )
              : carousel),
    );

    final topAnimesHeader = BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        return _createHeaderSection(
          context,
          locale: locale,
          title: '${locale.topAnimes}',
          iconData: Icons.star,
          iconColor: Colors.amberAccent,
          heroTag: HeroTags.TAG_TOP_ANIMES,
          onTap: () {
            _openAnimeItemGridPage(context, state.topAnimeList, 'Top Animes',
                HeroTags.TAG_TOP_ANIMES);
          },
        );
      },
    );

    final genresHeader = _createHeaderSection(
      context,
      locale: locale,
      iconData: Icons.explore,
      iconColor: accentColor,
      title: locale.exploreGenres,
      heroTag: HeroTags.TAG_EXPLORE_GENRES,
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => GenreGridPage()),
        );
      },
    );

    final myListHeader = BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) => (state.myAnimeMap.isEmpty)
          ? SliverToBoxAdapter(
              child: Container(),
            )
          : _createHeaderSection(
              context,
              locale: locale,
              viewMore: true,
              title: locale.myAnimeList,
              heroTag: HeroTags.TAG_MY_LIST,
              iconColor: accentColor,
              iconData: Icons.video_library,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => MyAnimeListPage(
                          heroTag: HeroTags.TAG_MY_LIST,
                        )),
              ),
            ),
    );

    final mostRecentsHeader = BlocBuilder<ApplicationBloc, ApplicationState>(
      builder: (context, state) {
        return _createHeaderSection(
          context,
          locale: locale,
          iconData: Icons.update,
          iconColor: accentColor,
          title: locale.recentlyUpdated,
          heroTag: HeroTags.TAG_RECENTLY_UPLOADED,
          onTap: () => _openAnimeItemGridPage(
            context,
            state.mostRecentAnimeList,
            locale.recentlyUpdated,
            HeroTags.TAG_RECENTLY_UPLOADED,
          ),
        );
      },
    );

    final latestEpisodesHeader = _createHeaderSection(
      context,
      locale: locale,
      iconData: Icons.ondemand_video,
      title: locale.latestEpisodes,
      heroTag: HeroTags.TAG_LATEST_EPISODES,
      iconColor: accentColor,
      onTap: () => _openLatestEpisodePage(context),
    );

    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: () async {
        context.read<ApplicationBloc>().add(const HomePageRefreshRequested());
        await Future.delayed(Duration(seconds: 1));
      },
      color: accentColor,
      backgroundColor: primaryColor,
      child: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          appBar,
          topAnimesHeader,
          BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              return _createHorizontaAnimelList(
                data: state.topAnimeList,
                width: size.width * .42,
                tag: HeroTags.TAG_TOP_ANIMES,
                controller: topAnimesController,
              );
            },
          ),
          mostRecentsHeader,
          BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              return _createHorizontaAnimelList(
                data: state.mostRecentAnimeList,
                width: size.width * .42,
                tag: heroTagRelease,
                controller: mostRecentController,
              );
            },
          ),
          genresHeader,
          BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              return _createHorizontalGenreList(
                width: size.width * .42,
                data: state.genreList,
                controller: genresController,
              );
            },
          ),
          myListHeader,
          BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) => (state.myAnimeMap.isEmpty)
                ? SliverToBoxAdapter(
                    child: Container(),
                  )
                : _createHorizontaCustomAnimelList(
                    width: size.width * .42,
                    tag: heroTagMyList,
                    controller: myListController,
                  ),
          ),
          latestEpisodesHeader,
          BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              return _createHorizontalEpisodeList(
                context,
                data: state.latestEpisodes,
                width: size.width * .42,
              );
            },
          ),
        ],
      ),
    );
  }

  SliverPadding _createHeaderSection(BuildContext context,
      {required S locale,
      IconData? iconData,
      Color? iconColor,
      required String title,
      bool viewMore = true,
      String? heroTag,
      VoidCallback? onTap}) {
    final layout = Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        TitleHeaderWidget(
          iconData: iconData,
          iconColor: iconColor,
          title: title,
          heroTag: heroTag,
          style: _SECTION_STYLE,
          onTap: onTap,
        ),
        (viewMore)
            ? Container(
                child: TapText(
                  onTap: onTap,
                  fontSize: 16.0,
                  text: locale.viewAll,
                  defaultColor: secondaryColor,
                  onTapColor: accentColor,
                ),
              )
            : Container(),
      ],
    );

    return SliverPadding(
      padding:
          EdgeInsets.only(bottom: 24.0, top: 24.0, left: 16.0, right: 12.0),
      sliver: SliverToBoxAdapter(
          child: (_isFirstHomePageView)
              ? SlideTransition(
                  position: headerAnimation,
                  child: layout,
                )
              : layout),
    );
  }

  SliverToBoxAdapter _createHorizontaAnimelList(
      {required List<AnimeModel> data,
      required double width,
      String? tag,
      required ScrollController controller}) {
    final listWidget = ListView.builder(
      controller: controller,
      itemBuilder: (context, index) {
        var anime = data[index];
        var heroTag = '${anime.id}$tag';

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
          child: ItemView(
            tooltip: anime.title,
            width: width,
            height: width * 1.4,
            imageUrl: anime.imageUrl,
            imageHeroTag: heroTag,
            onTap: () => _openAnimeDetailsPage(context, anime, heroTag),
          ),
        );
      },
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      physics: BouncingScrollPhysics(),
    );

    return SliverToBoxAdapter(
      child: Container(
          height: width * 1.4,
          child: (_isFirstHomePageView)
              ? SlideTransition(
                  position: carouselAnimation,
                  child: listWidget,
                )
              : listWidget),
    );
  }

  SliverToBoxAdapter _createHorizontaCustomAnimelList(
          {required double width,
          String? tag,
          required ScrollController controller}) =>
      SliverToBoxAdapter(
        child: Container(
          height: width * 1.4,
          child: BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              var data = state.myAnimeMap.values.toList();
              return ListView.builder(
                controller: controller,
                itemBuilder: (context, index) {
                  var anime = data[index];
                  var heroTag = '${anime.id}$tag';

                  return Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.0, vertical: 10.0),
                    child: ItemView(
                      width: width,
                      tooltip: anime.title,
                      height: width * 1.4,
                      imageUrl: anime.imageUrl,
                      imageHeroTag: heroTag,
                      onTap: () =>
                          _openAnimeDetailsPage(context, anime, heroTag),
                    ),
                  );
                },
                scrollDirection: Axis.horizontal,
                itemCount: data.length,
                physics: BouncingScrollPhysics(),
              );
            },
          ),
        ),
      );

  SliverToBoxAdapter _createHorizontalGenreList(
          {required List<String> data,
          required double width,
          required ScrollController controller}) =>
      SliverToBoxAdapter(
        child: Container(
          height: width * .9,
          child: ListView.builder(
            controller: controller,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
                child: ItemView(
                  width: width * 1.3,
                  height: width * .9,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                          child: Text(
                        data[index],
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ),
                      ))
                    ],
                  ),
                  backgroundColor: _randomColor.randomColor(
                    colorHue: ColorHue.multiple(
                      colorHues: [
                        ColorHue.blue,
                      ],
                    ),
                    colorBrightness: ColorBrightness.dark,
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) =>
                                GenreAnimePage(genreName: data[index])));
                  },
                ),
              );
            },
            scrollDirection: Axis.horizontal,
            itemCount: data.length,
            physics: BouncingScrollPhysics(),
          ),
        ),
      );

  SliverToBoxAdapter _createHorizontalEpisodeList(BuildContext context,
          {required List<EpisodeModel> data, required double width}) =>
      SliverToBoxAdapter(
        child: Container(
          height: width + 24,
          child: ListView.builder(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 12.0),
                child: EpisodeItemView(
                  width: width * 1.3,
                  height: width * .9,
                  imageUrl: data[index].imageUrl ?? '',
                  title: data[index].title ?? 'Episode ${data[index].number}',
                  onTap: () => _playEpisode(context, data[index]),
                ),
              );
            },
            itemCount: data.length ~/ 8,
          ),
        ),
      );

  void _openLatestEpisodePage(BuildContext context) => Navigator.push(context,
      CupertinoPageRoute(builder: (context) => RecentEpisodeListPage()));

  void _openAnimeDetailsPage(
          BuildContext context, AnimeModel anime, String heroTag) =>
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => AnimeDetailsScreen(
              heroTag: heroTag,
              anime: anime,
            ),
          ));

  Widget _createDayReleaseCarousel(
          {required BuildContext context,
          required double width,
          required double height}) =>
      BlocBuilder<ApplicationBloc, ApplicationState>(builder: (context, state) {
        return Carousel(
          showIndicator: true,
          autoplay: false,
          animationCurve: Curves.easeIn,
          boxFit: BoxFit.fill,
          dotSize: 6.0,
          overlayShadow: true,
          images: List.generate(
              (state.dayReleaseList.length >= 12)
                  ? 12
                  : state.dayReleaseList.length, (index) {
            var heroTag = '${state.dayReleaseList[index].id}$heroTagCarousel';
            return ItemView(
              borderRadius: .0,
              tooltip: state.dayReleaseList[index].title,
              imageUrl: state.dayReleaseList[index].imageUrl,
              width: width,
              imageHeroTag: heroTag,
              height: height,
              onTap: () => _openAnimeDetailsPage(
                  context, state.dayReleaseList[index], heroTag),
            );
          }),
        );
      });

  void _openAnimeItemGridPage(
      BuildContext context, List<AnimeModel> data, String title, String heroTag,
      {List<Widget>? actions}) {
    Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => DefaultAnimeItemGridPage(
            title: title,
            gridItems: data,
            heroTag: heroTag,
            actions: actions,
          ),
        ));
  }

  void _playEpisode(BuildContext context, EpisodeModel episode) {
    // Note: We need anime title for VideoPlayerScreen
    // For now, we'll use a placeholder. In a real app, this should be passed from the state
    Navigator.push(
        context,
        CupertinoPageRoute(
            builder: (context) => VideoPlayerScreen(
                  animeTitle: 'Unknown', // TODO: Pass actual anime title from state
                  episodeNumber: episode.number,
                )));
  }
}
