import 'package:anime_app/generated/l10n.dart';
import 'package:anime_app/logic/blocs/search/search_bloc.dart';
import 'package:anime_app/logic/blocs/search/search_event.dart';
import 'package:anime_app/logic/blocs/search/search_state.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:anime_app/ui/component/ItemView.dart';
import 'package:anime_app/ui/pages/AnimeDetailsScreen.dart';
import 'package:anime_app/ui/theme/ColorValues.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/UiUtils.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late ScrollController _controller;
  final TextEditingController _searchController =
      TextEditingController(text: '');
  late S locale;
  double _searchListOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController(initialScrollOffset: _searchListOffset);
    _controller.addListener(_pagination);
  }

  @override
  void dispose() {
    _controller.removeListener(_pagination);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    locale = S.of(context);

    final appBar = SliverAppBar(
      backgroundColor: primaryColor,
      expandedHeight: kToolbarHeight,
      title: Center(
        child: BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            // Only set text if state has currentQuery property
            if (state is SearchSuccess) {
              _searchController.text = state.currentQuery;
            }

            return Container(
              width: size.width,
              height: kToolbarHeight - 16,
              child: TextField(
                autofocus: false,
                style: TextStyle(
                  color: primaryColor,
                ),
                enabled: state is! SearchInProgress,
                controller: _searchController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) {
                  if (_searchController.text.isNotEmpty) {
                    context.read<SearchBloc>().add(
                          SearchQuerySubmitted(query: _searchController.text),
                        );
                  }
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () =>
                          context.read<SearchBloc>().add(const SearchCleared()),
                    ),
                    hintText: locale.searchHint,
                    hintStyle: TextStyle(color: secondaryColor),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.0)),
              ),
            );
          },
        ),
      ),
      snap: false,
      floating: true,
      pinned: false,
    );

    return CustomScrollView(
      controller: _controller,
      physics: BouncingScrollPhysics(),
      slivers: <Widget>[
        appBar,
        BlocBuilder<SearchBloc, SearchState>(
          builder: (context, state) {
            Widget widget;

            if (state is SearchInProgress) {
              widget = SliverToBoxAdapter(
                child: Container(
                  height: size.height * .7,
                  child: UiUtils.centredDotLoader(),
                ),
              );
            } else if (state is SearchSuccess) {
              if (state.results.isEmpty) {
                widget = _centerDecoration(
                    size, Icons.sentiment_dissatisfied, locale.noResults);
              } else {
                widget = _buildGrid(state.results, size);
              }
            } else if (state is SearchInitial) {
              widget = _centerDecoration(size, Icons.search, '${locale.search}');
            } else if (state is SearchError) {
              widget = _centerDecoration(size, Icons.error, locale.searchErrorMessage);
            } else {
              widget = _centerDecoration(size, Icons.search, '${locale.search}');
            }

            return widget;
          },
        ),
        SliverToBoxAdapter(
          child: BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) => (state is SearchSuccess && state.isLoadingMore)
                ? Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8.0),
                        child: UiUtils.centredDotLoader(),
                      ),
                    ],
                  )
                : Container(),
          ),
        ),
      ],
    );
  }

  SliverToBoxAdapter _centerDecoration(Size size, IconData icon, String text) =>
      SliverToBoxAdapter(
        child: Container(
          height: size.height * .7,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 180,
                color: Colors.grey.withOpacity(.3),
              ),
              Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.grey.withOpacity(.3),
                ),
              )
            ],
          ),
        ),
      );

  Widget _buildGrid(List<AnimeModel> items, Size size) {
    final double itemHeight = (size.height - kToolbarHeight - 24) / 2.5;
    final double itemWidth = size.width / 2;
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8.0,
          crossAxisSpacing: 6.0,
          childAspectRatio: (itemWidth / itemHeight),
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return ItemView(
              width: itemWidth,
              height: itemHeight,
              tooltip: items[index].title,
              imageUrl: items[index].imageUrl,
              imageHeroTag: items[index].id,
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => AnimeDetailsScreen(
                      heroTag: items[index].id,
                      anime: items[index],
                    ),
                  ),
                );
              },
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  void _pagination() async {
    _searchListOffset = _controller.position.pixels;
    if (_controller.position.pixels >
        (_controller.position.maxScrollExtent -
            (_controller.position.maxScrollExtent / 4))) {
      context.read<SearchBloc>().add(const SearchLoadMoreRequested());
    }
  }
}
