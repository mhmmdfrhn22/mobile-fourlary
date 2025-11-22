import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/core/routes/app_routes.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/onboarding4.png",
      "title": "Ayo Jelajahi Galeri Fourlary!",
      "subtitle":
          "Ayo Jelajahi 100 lebih Foto Foto Menarik dan Informatif Di Halaman Galeri Fourlary!",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Cari Tahu Berita Terbaru!",
      "subtitle":
          "Jelajahi Juga Berbagai Berita Berita Hangat Seputar SMK Negeri 4 Bogor Saat Ini!",
    },
    {
      "image": "assets/images/onboarding3.png",
      "title": "Mulai Jelajah Sekarang!",
      "subtitle":
          "Masuk atau Daftarkan Akun Anda dan Mulai Menjelajah Fitur Bersama Kami!",
    },
  ];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 4,
              child: PageView.builder(
                controller: _controller,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final data = onboardingData[index];
                  return Padding(
                    padding: EdgeInsets.all(screenWidth * 0.08), // Larger padding for the view
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Larger image size for more prominent visuals
                        Image.asset(data["image"]!, height: screenHeight * 0.4), 
                        SizedBox(height: screenHeight * 0.06), // Adjust spacing between image and text
                        Text(
                          data["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.065, // Adjusted font size for the title
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02), // Adjust space for subtitle
                        Text(
                          data["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.04, // Adjusted font size for the subtitle
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                onboardingData.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.03), // Adjust spacing for button

            // Button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08, vertical: screenHeight * 0.02), // Adjust padding for button
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPage == onboardingData.length - 1) {
                      Navigator.pushReplacementNamed(context, AppRoutes.login);
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == onboardingData.length - 1
                        ? "Masuk Sekarang"
                        : "Lanjutkan",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
