import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:anime_app/data/repositories/search_repository.dart';
import 'package:anime_app/logic/blocs/application/application_bloc.dart';
import 'package:anime_app/logic/blocs/application/application_event.dart';
import 'package:anime_app/logic/blocs/application/application_state.dart';
import 'package:anime_app/logic/blocs/search/search_bloc.dart';
import 'package:anime_app/ui/pages/MainScreen.dart';
import 'package:anime_app/ui/pages/RetryPage.dart';
import 'package:anime_app/ui/pages/SplashScreen.dart';
import 'package:anime_app/ui/theme/ColorValues.dart';

import 'generated/l10n.dart';

void main() {
  runApp(MyApp());

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.black,
  ));
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final animeRepository = AnimeRepository();
    final userRepository = UserRepository();
    final searchRepository = SearchRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationBloc>(
          create: (context) => ApplicationBloc(
            animeRepository: animeRepository,
            userRepository: userRepository,
          )..add(const AppInitializeRequested()),
        ),
        BlocProvider<SearchBloc>(
          create: (context) => SearchBloc(
            searchRepository: searchRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AniStore',
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        debugShowCheckedModeBanner: false,
        theme: ThemeData().copyWith(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: primaryColor,
          // text theme
          textTheme: const TextTheme().copyWith(
            bodyMedium: const TextStyle(color: textPrimaryColor),
          ),
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: accentColor),
        ),
        localizationsDelegates: const [
          S.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: S.delegate.supportedLocales,
        home: BlocBuilder<ApplicationBloc, ApplicationState>(
          builder: (context, state) {
            switch (state.initStatus) {
              case AppInitStatus.initializing:
                return const SplashScreen();
              case AppInitStatus.initialized:
                return const MainScreen();
              case AppInitStatus.initError:
                return const RetryPage();
            }
          },
        ),
      ),
    );
  }
}
