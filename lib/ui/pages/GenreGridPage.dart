import 'package:anime_app/generated/l10n.dart';
import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/ui/component/app_bar/AnimeStoreHeroAppBar.dart';
import 'package:anime_app/ui/component/ItemView.dart';
import 'package:anime_app/ui/component/SliverGridViewWidget.dart';
import 'package:anime_app/ui/pages/GenreAnimePage.dart';
import 'package:anime_app/ui/utils/HeroTags.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:random_color/random_color.dart';

class GenreGridPage extends StatelessWidget {
  final RandomColor _randomColor = RandomColor();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    var width = size.width * 1.3;
    var height = size.width * .9;

    final locale = S.of(context);
    return Scaffold(
      body: CustomScrollView(
        physics: BouncingScrollPhysics(),
        slivers: <Widget>[
          AnimeStoreHeroAppBar(
            title: locale.exploreGenres,
            heroTag: HeroTags.TAG_EXPLORE_GENRES,
          ),
          BlocBuilder<ApplicationBloc, ApplicationState>(
            builder: (context, state) {
              return SliverGridItemView(
                childAspectRatio: (width / height),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return ItemView(
                      width: width,
                      height: height,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Expanded(
                              child: Text(
                            state.genreList[index],
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
                          colorHues: [ColorHue.blue],
                        ),
                        colorBrightness: ColorBrightness.dark,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) => GenreAnimePage(
                                  genreName: state.genreList[index])),
                        );
                      },
                    );
                  },
                  childCount: state.genreList.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
