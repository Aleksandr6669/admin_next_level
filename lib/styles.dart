
import 'package:flutter/material.dart';

// Text Styles
const TextStyle kTitleTextStyle = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kSubtitleTextStyle = TextStyle(
  fontSize: 16,
  color: Colors.white70,
);

const TextStyle kButtonTextStyle = TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
  color: Colors.white,
);

const TextStyle kTextLinkStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
);

const TextStyle kAppBarTitleTextStyle = TextStyle(
    fontSize: 20, 
    fontWeight: FontWeight.bold, 
    color: Colors.white
);

const TextStyle kPageTitleTextStyle = TextStyle(color: Colors.white);

const TextStyle kSettingsTitleTextStyle =
    TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold);

const TextStyle kSettingsLanguageTextStyle = TextStyle(color: Colors.white, fontSize: 18);

const TextStyle kDropdownTextStyle = TextStyle(color: Colors.white, fontSize: 16);

// Input Decoration
InputDecoration kInputDecoration(String label, IconData icon) {
  return InputDecoration(
    hintText: label,
    hintStyle: const TextStyle(color: Colors.white54),
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 12.0), // Добавляем отступ слева
      child: Icon(icon, color: Colors.white54),
    ),
    filled: true,
    fillColor: Colors.white.withAlpha(25),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide(color: Colors.white.withAlpha(25)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30.0),
      borderSide: BorderSide(color: Colors.white.withAlpha(76)),
    ),
  );
}

// Gradients
const LinearGradient kButtonGradient = LinearGradient(
  colors: [Color(0xFFDA4453), Color(0xFF89216B)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

final LinearGradient kGlassmorphicGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withAlpha(25),
    Colors.white.withAlpha(12),
  ],
);

final LinearGradient kGlassmorphicBorderGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Colors.white.withAlpha(128),
    Colors.white.withAlpha(128),
  ],
);

LinearGradient kAnimatedGradient(double animationValue) {
    return LinearGradient(
        transform: GradientRotation(animationValue * 6.28),
        colors: [
            const Color.fromARGB(255, 78, 76, 84).withAlpha(76),
            const Color.fromARGB(255, 72, 71, 72).withAlpha(51),
            const Color.fromARGB(255, 23, 24, 25).withAlpha(102),
        ],
        stops: const [0.2, 0.5, 0.8],
    );
}

final LinearGradient kAppBarBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white.withAlpha(76), Colors.white.withAlpha(25)],
);

final LinearGradient kDropdownGradient = LinearGradient(
    colors: [
        const Color.fromARGB(255, 72, 71, 72).withAlpha(51),
        const Color.fromARGB(255, 23, 24, 25).withAlpha(102),
    ],
    stops: const [0.2, 0.8],
);

final LinearGradient kDropdownBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Colors.white.withAlpha(76), Colors.white.withAlpha(25)],
);


// Box Decorations
final BoxDecoration kButtonBoxDecoration = BoxDecoration(
  borderRadius: BorderRadius.circular(15.0),
  gradient: kButtonGradient,
  boxShadow: [
    BoxShadow(
      color: Colors.black.withAlpha(51),
      spreadRadius: 2,
      blurRadius: 5,
      offset: const Offset(0, 3),
    ),
  ],
);

const BoxDecoration kBackgroundDecoration = BoxDecoration(
  image: DecorationImage(
    image: AssetImage("assets/background.jpg"),
    fit: BoxFit.cover,
  ),
);

// Button Styles
final ButtonStyle kElevatedButtonStyle = ElevatedButton.styleFrom(
  padding: const EdgeInsets.symmetric(vertical: 18),
  backgroundColor: Colors.transparent,
  shadowColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(15.0),
  ),
);

// Colors
const Color kBottomNavSelectedItemColor = Colors.white;
const Color kBottomNavUnselectedItemColor = Colors.white70;
const Color kDropdownColor = Color.fromARGB(149, 26, 5, 43);
const Color kDropdownIconColor = Colors.white;
