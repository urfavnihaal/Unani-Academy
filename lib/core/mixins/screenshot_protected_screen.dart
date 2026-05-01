import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

mixin ScreenshotProtectedScreen<T extends StatefulWidget> on State<T> {
  @override
  void initState() {
    super.initState();
    _enableProtection();
  }

  @override
  void dispose() {
    _disableProtection();
    super.dispose();
  }

  Future<void> _enableProtection() async {
    try {
      if (Platform.isAndroid) {
        // Blocks both screenshots and screen recording natively on Android
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      }
      
      // Additional protection/detection from screen_protector
      await ScreenProtector.preventScreenshotOn();
      
      // On iOS, this specifically makes the screen go black during recording
      if (Platform.isIOS) {
        await ScreenProtector.preventScreenshotOn();
      }

      // Listener for screenshot attempts to show a feedback message
      ScreenProtector.addListener(() {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.security_rounded, color: Colors.white),
                  SizedBox(width: 12),
                  Text("Screenshot not allowed"),
                ],
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }, (p0) {
        // Screen recording listener (optional)
      });
    } catch (e) {
      debugPrint('Error enabling screenshot protection: $e');
    }
  }

  Future<void> _disableProtection() async {
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
      await ScreenProtector.preventScreenshotOff();
      ScreenProtector.removeListener();
    } catch (e) {
      debugPrint('Error disabling screenshot protection: $e');
    }
  }
}
