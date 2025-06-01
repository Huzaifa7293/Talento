import 'package:flutter/material.dart';
import 'package:talento/Utils/appColors.dart';
import 'package:talento/Utils/appFonts.dart';
import 'package:talento/Views/welcome.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      'image': 'assets/Images/onboard1.png',
      'title': 'Talent is everywhere,\nFind it with Talento',
      'curve': 'assets/Images/curve1.png',
      'imageSide': 'right',
    },
    {
      'image': 'assets/Images/onboard2.png',
      'title': 'Create,\nConnect,\nCollaborate.\nAll on Talento',
      'curve': 'assets/Images/curve2.png',
      'imageSide': 'left',
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Container(
            decoration: const BoxDecoration(gradient: AppColors.gradient),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingData.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final data = onboardingData[index];
                    return OnboardPage(
                      image: data['image']!,
                      title: data['title']!,
                      curveImage: data['curve']!,
                      imageSide: data['imageSide']!,
                    );
                  },
                ),
                // Page indicator dots
                Positioned(
                  bottom: 120,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        width: _currentPage == index ? 20 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          gradient:
                              _currentPage == index ? AppColors.gradient : null,
                          color:
                              _currentPage == index ? null : Colors.white70,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                // Next button
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _nextPage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 2),
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AppColors.gradient,
                              border:
                                  Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Center(
                              child: Icon(Icons.arrow_forward,
                                  color: Colors.white, size: 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String curveImage;
  final String imageSide;

  const OnboardPage({
    super.key,
    required this.image,
    required this.title,
    required this.curveImage,
    required this.imageSide,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isImageRight = imageSide == 'right';

    return Stack(
      children: [
        // Background Curve
        Positioned(
          top: 0,
          left: isImageRight ? 0 : null,
          right: isImageRight ? null : 0,
          child: Image.asset(
            curveImage,
            width: size.width * 0.65,
            fit: BoxFit.fitHeight,
          ),
        ),
        // Foreground content: Image and Text
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: isImageRight
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Image.asset(
                    image,
                    height: size.height * 0.4,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  '"$title"',
                  textAlign: TextAlign.center,
                  style: FontStyles.header(context).copyWith(
                    color: Colors.white,
                    fontSize: size.width < 600 ? 20 : 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
