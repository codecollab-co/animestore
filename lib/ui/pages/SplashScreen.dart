import 'package:anime_app/ui/component/DotSpinner.dart';
import 'package:anime_app/ui/theme/ColorValues.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController controller;
  late AnimationController dotController;

  late Animation<double> transformAnimation;
  late Animation<Offset> textTransition;
  late Animation<Offset> iconTransition;
  late Animation<double> borderAnimation;
  late Animation<Offset> loaderTransition;

  @override
  void dispose() {
    controller.dispose();
    dotController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    transformAnimation = Tween<double>(begin: .0, end: 1.0).animate(
        CurvedAnimation(
            curve: const Interval(.0, .5, curve: Curves.linear), parent: controller));

    borderAnimation = Tween<double>(begin: 1.0, end: .0).animate(
        CurvedAnimation(
            curve: const Interval(.0, .5, curve: Curves.easeIn), parent: controller));
    const transitionInterval =
        Interval(.5, 1.0, curve: Curves.fastLinearToSlowEaseIn);

    textTransition = Tween<Offset>(
      begin: const Offset(100.0, .0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      curve: transitionInterval,
      parent: controller,
    ));

    iconTransition = Tween<Offset>(begin: const Offset(-100.0, .0), end: Offset.zero)
        .animate(CurvedAnimation(
      curve: transitionInterval,
      parent: controller,
    ));

    loaderTransition = Tween<Offset>(
      begin: const Offset(50.0, .0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      curve: Curves.fastLinearToSlowEaseIn,
      parent: dotController,
    ));
    controller.forward().then((_) {
      dotController.forward();
      // App initialization is now handled by ApplicationBloc
      // via AppInitializeRequested event in main.dart
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, child) => Transform.scale(
          scale: transformAnimation.value,
          alignment: Alignment.center,
          origin: Offset.zero,
          child: Material(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderAnimation.value * 20),
            ),
            color: primaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) => SlideTransition(
                    position: iconTransition,
                    child: SvgPicture.asset(
                      'assets/icons/anistore.svg',
                      color: Colors.white,
                      width: 120,
                      height: 120,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: AnimatedBuilder(
                    animation: controller,
                    builder: (_, __) => SlideTransition(
                      position: textTransition,
                      child: const Text(
                        'Anime Store',
                        style: TextStyle(
                            color: textPrimaryColor,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 32),
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: dotController,
                  builder: (context, child) {
                    return SlideTransition(
                      position: loaderTransition,
                      child: DotSpinner(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
