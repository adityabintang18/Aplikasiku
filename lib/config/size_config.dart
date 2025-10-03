import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static late double blockWidth;
  static late double blockHeight;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    blockWidth = screenWidth / 100;
    blockHeight = screenHeight / 100;
  }

  static double getWidth(double inputWidth) {
    return (inputWidth / 375.0) * screenWidth;
  }

  static double getHeight(double inputHeight) {
    return (inputHeight / 812.0) * screenHeight;
  }
}
