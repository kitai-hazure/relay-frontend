import 'package:concentric_transition/concentric_transition.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:relay/screens/sign_in_screen.dart';

class OnboardingPage extends StatelessWidget {
  OnboardingPage({Key? key}) : super(key: key);
  static const routeName = 'onboarding';
  final data = [
    OnBoardingData(
      title: "Connect",
      subtitle:
          "Maintain connections with the people irrespective of other factors",
      image: LottieBuilder.asset("assets/lottie/onboarding-1.json"),
      backgroundColor: const Color.fromRGBO(0, 10, 56, 1),
      titleColor: Colors.pink,
      subtitleColor: Colors.white,
    ),
    OnBoardingData(
      title: "Breaking Barriers",
      subtitle: "Use our application and minimize language barrier around the globe",
      image: LottieBuilder.asset("assets/lottie/onboarding-2.json"),
      backgroundColor: Colors.white,
      titleColor: Colors.purple,
      subtitleColor: const Color.fromRGBO(0, 10, 56, 1),
    ),
    OnBoardingData(
      title: "Collaborate",
      subtitle: "Collaborate and make the world an inclusive and better place",
      image: LottieBuilder.asset("assets/lottie/onboarding-3.json"),
      backgroundColor: const Color.fromRGBO(71, 59, 117, 1),
      titleColor: Colors.yellow,
      subtitleColor: Colors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ConcentricPageView(
        duration: const Duration(seconds: 4),
        colors: data.map((e) => e.backgroundColor).toList(),
        itemCount: data.length,
        itemBuilder: (int index) {
          return OnBoardingCard(data: data[index]);
        },
        onFinish: () {
          //TODO
          Navigator.pushReplacement(context, MaterialPageRoute(builder: ((context) => SignInScreen())));
        },
      ),
    );
  }
}

class OnBoardingData {
  final String title;
  final String subtitle;
  final Widget image;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final Widget? background;

  OnBoardingData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.backgroundColor,
    required this.titleColor,
    required this.subtitleColor,
    this.background,
  });
}

class OnBoardingCard extends StatelessWidget {
  const OnBoardingCard({
    required this.data,
    Key? key,
  }) : super(key: key);

  final OnBoardingData data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (data.background != null) data.background!,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),
              Flexible(
                flex: 20,
                child: data.image,
              ),
              const Spacer(flex: 1),
              Text(
                data.title.toUpperCase(),
                style: TextStyle(
                  color: data.titleColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                maxLines: 1,
              ),
              const Spacer(flex: 1),
              Text(
                data.subtitle,
                style: TextStyle(
                  color: data.subtitleColor,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const Spacer(flex: 10),
            ],
          ),
        ),
      ],
    );
  }
}