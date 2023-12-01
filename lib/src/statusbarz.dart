// ignore_for_file: use_setters_to_change_properties, avoid_setters_without_getters, comment_references

import 'dart:ffi';
import 'dart:ui';

import 'package:flutter/material.dart' hide Image;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:statusbarz/src/statusbarz_exception.dart';
import 'package:statusbarz/src/statusbarz_observer.dart';
import 'package:statusbarz/src/statusbarz_theme.dart';

/// {@template statusbarz}
/// The interface that can be used to manually refresh the status bar color and access observer
/// {@endtemplate}
class Statusbarz {
  Statusbarz._constructor();

  static final GlobalKey _key = GlobalKey();
  static final Statusbarz _instance = Statusbarz._constructor();

  StatusbarzTheme _theme = StatusbarzTheme();

  Duration _defaultDelay = const Duration(milliseconds: 10);

  /// Returns the interface that can be used to manually refresh the status bar color
  static Statusbarz get instance => _instance;

  /// Setter for the theme
  void setTheme(StatusbarzTheme theme) => _theme = theme;

  /// Returns the current theme
  StatusbarzTheme get theme => _theme;

  /// Navigator observer to place inside MaterialApp:
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     StatusbarzCapturer(
  ///       child: MaterialApp(
  ///         navigatorObservers: [Statusbarz.instance.observer],
  ///         home: Container(),
  ///       ),
  ///     ),
  ///   );
  /// }
  /// ```

  set setDefaultDelay(Duration delay) => _defaultDelay = delay;

  /// Returns the key that shall be placed ONLY in StatusbarzObserver
  GlobalKey get key => _key;

  /// Changes status bar color based on the current background
  ///
  /// ### Important
  /// This operation is computationally expensive to calculate, so therefore must be used with caution.
  /// ### Error handling
  /// Throws an [StatusbarzException] if no StatusbarzCapturer found from widget tree.
  ///
  /// [Statusbarz.instance.observer] shall be placed inside [MaterialApp] in order to change status bar color automatically when new page is pushed/popped:
  /// ```dart
  /// void main() {
  ///   runApp(
  ///     StatusbarzCapturer(
  ///       child: MaterialApp(
  ///         navigatorObservers: [Statusbarz.instance.observer],
  ///         home: Container(),
  ///       ),
  ///     ),
  ///   );
  /// }
  /// ```
  ///
  /// See also:
  ///
  ///  * [StatusbarzCapturer], the widget used to find the currently rendered object
  ///  * [StatusbarzObserver], the observer used to listen to route changes
  Future<void> refresh({
    Duration? delay,
  }) async {
    return Future.delayed(
      delay ?? _defaultDelay,
      () async {
        final context = _key.currentContext;

        if (context == null) {
          throw StatusbarzException(
            'No StatusbarzObserver found from widget tree. StatusbarzObserver shall be added above MaterialApp in your widget tree.',
          );
        }
        final view = View.of(context);

        /// Finds currently rendered UI
        final boundary = context.findRenderObject() as RenderRepaintBoundary?;

        /// Converts rendered UI to png
        final capturedImage = await boundary!.toImage();
        final byteData = await capturedImage.toByteData(format: ImageByteFormat.png);
        final bytes = byteData!.buffer.asUint8List();

        final bitmap = img.decodeImage(bytes);

        double topOfScreenLuminance = 0.0;
        int numberOfTopScreenPixels = 0;

        double bottomOfScreenLumiance = 0.0;
        int numberOfBottomScreenPixels = 0;

        final mediaQuery = MediaQueryData.fromView(view);
        final statusHeight = mediaQuery.padding.top.clamp(20.0, 150.0);
        // We assume height is at least more than 150 pixel
        final navbarHeight = (mediaQuery.size.height - mediaQuery.padding.bottom.clamp(50, 150)).round() - 30;

        /// Calculates the average color for the status bar
        for (var yCoord = 0; yCoord < statusHeight.toInt(); yCoord++) {
          for (var xCoord = 0; xCoord < bitmap!.width; xCoord++) {
            final pixel = bitmap.getPixel(xCoord, yCoord);
            topOfScreenLuminance += pixel.luminance;
            numberOfTopScreenPixels++;
          }
        }

        /// Calulates the average color for the navigation bar
        for (var yCoord = mediaQuery.size.height.round(); yCoord > navbarHeight.toInt(); yCoord--) {
          for (var xCoord = 0; xCoord < bitmap!.width; xCoord++) {
            final pixel = bitmap.getPixel(xCoord, yCoord);
            bottomOfScreenLumiance += pixel.luminance;
            numberOfBottomScreenPixels++;
          }
        }

        final topOfScreenAvgLuminance = topOfScreenLuminance / numberOfTopScreenPixels;
        final bottomOfScreenAvgLuminance = bottomOfScreenLumiance / numberOfBottomScreenPixels;

        setSystemUIOverlayStyle(
          isStatusBarDark: topOfScreenAvgLuminance < 0.5,
          isNavigationBarDark: bottomOfScreenAvgLuminance < 0.5,
        );
      },
    );
  }

  void setSystemUIOverlayStyle({
    required bool isStatusBarDark,
    required bool isNavigationBarDark,
  }) {
    final systemNavigationBarColor =
        isNavigationBarDark ? theme.darkStyle.systemNavigationBarColor : theme.lightStyle.systemNavigationBarColor;
    final systemNavigationBarDividerColor =
        isNavigationBarDark ? theme.darkStyle.systemNavigationBarColor : theme.lightStyle.systemNavigationBarColor;
    final systemNavigationBarIconBrightness = isNavigationBarDark
        ? theme.darkStyle.systemNavigationBarIconBrightness
        : theme.lightStyle.systemNavigationBarIconBrightness;
    final systemNavigationBarContrastEnforced = isNavigationBarDark
        ? theme.darkStyle.systemNavigationBarContrastEnforced
        : theme.lightStyle.systemNavigationBarContrastEnforced;
    final statusBarColor = isStatusBarDark ? theme.darkStyle.statusBarColor : theme.lightStyle.statusBarColor;
    final statusBarBrightness =
        isStatusBarDark ? theme.darkStyle.statusBarBrightness : theme.lightStyle.statusBarBrightness;
    final statusBarIconBrightness =
        isStatusBarDark ? theme.darkStyle.statusBarIconBrightness : theme.lightStyle.statusBarIconBrightness;
    final systemStatusBarContrastEnforced = isStatusBarDark
        ? theme.darkStyle.systemStatusBarContrastEnforced
        : theme.lightStyle.systemStatusBarContrastEnforced;

    final overlayStyle = SystemUiOverlayStyle(
      systemNavigationBarColor: systemNavigationBarColor,
      systemNavigationBarDividerColor: systemNavigationBarDividerColor,
      systemNavigationBarIconBrightness: systemNavigationBarIconBrightness,
      systemNavigationBarContrastEnforced: systemNavigationBarContrastEnforced,
      statusBarColor: statusBarColor,
      statusBarBrightness: statusBarBrightness,
      statusBarIconBrightness: statusBarIconBrightness,
      systemStatusBarContrastEnforced: systemStatusBarContrastEnforced,
    );
    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
  }
}
