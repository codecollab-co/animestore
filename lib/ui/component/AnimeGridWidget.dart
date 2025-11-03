import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_event.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/ui/component/ItemView.dart';
import 'package:anime_app/ui/component/SliverGridViewWidget.dart';
import 'package:anime_app/ui/pages/AnimeDetailsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/UiUtils.dart';

class AnimeGridWidget extends StatefulWidget {
  @override
  _AnimeGridWidgetState createState() => _AnimeGridWidgetState();
}

class _AnimeGridWidgetState extends State<AnimeGridWidget> {
  late ApplicationBloc appBloc;

  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    appBloc = context.read<ApplicationBloc>();
    _controller = ScrollController();
    _controller.addListener(_listener);
  }

  void _listener() {
    if (_controller.position.pixels >
        (_controller.position.maxScrollExtent -
            (_controller.position.maxScrollExtent / 4))) {
      context.read<ApplicationBloc>().add(const AnimeListLoadRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
    final double itemWidth = size.width / 2;

    return CustomScrollView(
      controller: _controller,
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        // appBar,
        BlocBuilder<ApplicationBloc, ApplicationState>(
          builder: (context, state) {
            return SliverGridItemView(
              childAspectRatio: (itemWidth / itemHeight),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Tooltip(
                    message: state.feedAnimeList[index].title,
                    child: ItemView(
                      width: itemWidth,
                      height: itemHeight,
                      imageUrl: state.feedAnimeList[index].imageUrl,
                      imageHeroTag: state.feedAnimeList[index].id,
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => AnimeDetailsScreen(
                                heroTag: state.feedAnimeList[index].id,
                                anime: state.feedAnimeList[index],
                              ),
                            ));
                      },
                    ),
                  );
                },
                childCount: state.feedAnimeList.length,
              ),
            );
          },
        ),

        SliverToBoxAdapter(
          child: BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) =>
                (state.animeListLoadingStatus == LoadingStatus.loading)
                    ? Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.all(8.0),
                              child: UiUtils.centredDotLoader()),
                        ],
                      )
                    : Container(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }
}
