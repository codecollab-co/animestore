import 'dart:ui';
import 'package:anime_app/ui/theme/ColorValues.dart';
import 'package:anime_app/models/anime_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/logic/blocs/application/application_event.dart';

typedef OnTap = void Function();

class ItemView extends StatelessWidget {
  final String? imageUrl;
  final Widget? child;
  final OnTap? onTap;
  final double width, height;
  final String? imageHeroTag;
  final double borderRadius;
  final Color? backgroundColor;
  final String? tooltip;
  final AnimeModel? anime;
  final bool showFavoriteIcon;

  const ItemView({
    required this.width,
    required this.height,
    this.child,
    this.tooltip,
    Key? key,
    this.imageUrl,
    this.onTap,
    this.backgroundColor,
    this.imageHeroTag,
    this.borderRadius = 12.0,
    this.anime,
    this.showFavoriteIcon = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final stack = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        (imageUrl == null)
            ? Align(
                alignment: Alignment.center,
                child: child ?? SizedBox(),
              )
            : Positioned.fill(
                child: Hero(
                  tag: this.imageHeroTag ?? UniqueKey().toString(),
                  child: Image(
                    fit: BoxFit.fill,
                    image: CachedNetworkImageProvider(imageUrl!),
                  ),
                ),
              ),
        Positioned.fill(
          child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
              )),
        ),
        if (showFavoriteIcon && anime != null)
          Positioned(
            top: 8,
            right: 8,
            child: BlocBuilder<ApplicationBloc, ApplicationState>(
              builder: (context, state) {
                final isFavorite = state.myAnimeMap.containsKey(anime!.id);
                return GestureDetector(
                  onTap: () {
                    if (isFavorite) {
                      context.read<ApplicationBloc>().add(
                            MyAnimeRemoved(animeId: anime!.id),
                          );
                    } else {
                      context.read<ApplicationBloc>().add(
                            MyAnimeAdded(
                              animeId: anime!.id,
                              anime: anime!,
                            ),
                          );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 24,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );

    final containerChild = (tooltip == null)
        ? stack
        : Tooltip(
            message: tooltip!,
            child: stack,
          );
    return ClipRRect(
      borderRadius: BorderRadius.circular(this.borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? secondaryColor,
        ),
        child: containerChild,
      ),
    );
  }
}
