import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSizeUtil {
  // Singleton instance
  static final AppSizeUtil _instance = AppSizeUtil._internal();
  factory AppSizeUtil() => _instance;
  AppSizeUtil._internal();

  // Reactive variables for width and height
  final RxDouble _width = 0.0.obs;
  final RxDouble _height = 0.0.obs;

  // Getter for width
  double get width => _width.value;

  // Getter for height
  double get height => _height.value;

  // Method to update width and height based on orientation
  void updateSize(BuildContext context) {
    _width.value = MediaQuery.of(context).size.width;
    _height.value = MediaQuery.of(context).size.height;
  }
}