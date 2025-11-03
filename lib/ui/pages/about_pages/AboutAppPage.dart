import 'package:anime_app/generated/l10n.dart';
import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/ui/component/app_bar/AnimeStoreIconAppBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// This page display information about the application
/// like build number, application name and etc.
///
class AboutAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = S.of(context);

    return Scaffold(
      appBar: AnimeStoreIconAppBar(),
      body: BlocBuilder<ApplicationBloc, ApplicationState>(
        builder: (context, state) {
          final info = state.appInfo;

          return ListView(
            shrinkWrap: true,
            physics: BouncingScrollPhysics(),
            children: <Widget>[
              ListTile(
                title: Text(locale.appNameTitle),
                subtitle: Text(locale.animeStore),
              ),
              ListTile(
                title: Text(locale.versionTitle),
                subtitle: Text(info?.version ?? '0.0.0'),
              ),
              ListTile(
                title: Text(locale.buildNumberTitle),
                subtitle: Text(info?.buildNumber ?? '0'),
              ),
            ],
          );
        },
      ),
    );
  }
}
