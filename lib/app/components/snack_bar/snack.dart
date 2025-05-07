import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Snack {
  static void showSuccessMessage(String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: "Success",
        message: message,
        backgroundColor: Colors.green,
        duration: Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM,
      ),
    );
    //
    //     const snackBar = SnackBar(content: Text('Yay! A SnackBar!'));
    //
    // // Find the ScaffoldMessenger in the widget tree
    // // and use it to show a SnackBar.
    //     ScaffoldMessenger.of(Get.overlayContext!).showSnackBar(snackBar);
  }

  static void showInfoMessage(String message, {Widget? mainButton}) {
    Get.showSnackbar(
      GetSnackBar(
        title: "Info",
        message: message,
        backgroundColor: Colors.blueAccent,
        duration: Duration(seconds: 6),
        snackPosition: SnackPosition.BOTTOM,
        mainButton: mainButton,
      ),
    );
  }

  static void showErrorMessage(String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: "Warning",
        message: message,
        backgroundColor: Colors.redAccent,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 6),
      ),
    );
  }
}
