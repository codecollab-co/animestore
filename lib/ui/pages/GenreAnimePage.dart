import 'package:anime_app/data/repositories/genre_repository.dart';
import 'package:anime_app/logic/blocs/genre/genre_bloc.dart';
import 'package:anime_app/logic/blocs/genre/genre_event.dart';
import 'package:anime_app/logic/blocs/genre/genre_state.dart';
import 'package:anime_app/ui/component/ItemView.dart';
import 'package:anime_app/ui/component/SliverGridViewWidget.dart';
import 'package:anime_app/ui/pages/AnimeDetailsScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anime_app/ui/utils/UiUtils.dart';

class GenreAnimePage extends StatelessWidget {
  final String genreName;

  const GenreAnimePage({Key? key, required this.genreName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GenreBloc(
        genreRepository: GenreRepository(),
      )..add(GenreAnimeLoadRequested(genre: genreName)),
      child: _GenreAnimeContent(genreName: genreName),
    );
  }
}

class _GenreAnimeContent extends StatefulWidget {
  final String genreName;

  const _GenreAnimeContent({Key? key, required this.genreName})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _GenreAnimeContentState();
}

class _GenreAnimeContentState extends State<_GenreAnimeContent> {
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_listener);
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }

  void _listener() {
    if (_controller.position.pixels >
        (_controller.position.maxScrollExtent -
            (_controller.position.maxScrollExtent / 4))) {
      context.read<GenreBloc>().add(const GenreAnimeLoadMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    /*24 is for notification bar on Android*/
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
    final double itemWidth = size.width / 2;

    return Scaffold(
      body: CustomScrollView(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        slivers: <Widget>[
          const SliverToBoxAdapter(
            child: SizedBox.shrink(),
          ),
          BlocBuilder<GenreBloc, GenreState>(
            builder: (context, state) {
              if (state is GenreLoading) {
                return SliverToBoxAdapter(
                  child: SizedBox(
                    height: size.height,
                    width: size.width,
                    child: UiUtils.centredDotLoader(),
                  ),
                );
              }

              if (state is GenreError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('ERROR: ${state.errorMessage}'),
                  ),
                );
              }

              if (state is GenreLoaded) {
                return SliverGridItemView(
                  childAspectRatio: (itemWidth / itemHeight),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var anime = state.animeItems[index];
                      var heroTag = '${anime.id}-$index';

                      return Tooltip(
                        message: anime.title,
                        child: ItemView(
                          imageHeroTag: heroTag,
                          width: itemWidth,
                          height: itemHeight,
                          imageUrl: anime.imageUrl,
                          onTap: () {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => AnimeDetailsScreen(
                                  heroTag: heroTag,
                                  anime: anime,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    childCount: state.animeItems.length,
                  ),
                );
              }

              return const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );
            },
          ),
          BlocBuilder<GenreBloc, GenreState>(
            builder: (context, state) {
              if (state is GenreLoaded && state.isLoadingMore) {
                return SliverToBoxAdapter(
                  child: _loadingWidget(),
                );
              }
              return const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _loadingWidget() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: UiUtils.centredDotLoader(),
      );
}
