import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// {@template statusbarz_theme}
/// The default theme for the `Statusbarz`
/// {@endtemplate}
class StatusbarzTheme {
  /// {@macro statusbarz_theme}
  StatusbarzTheme({
    this.darkStyle = const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    ),
    this.lightStyle = const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
    ),
  });

  /// The `SystemUiOverlayStyle` to apply when the background behind status bar is light. This shall
  /// use dark icons etc. Defaults to:
  /// ```dart
  /// const SystemUiOverlayStyle(
  ///    systemNavigationBarColor: Colors.white,
  ///    systemNavigationBarIconBrightness: Brightness.dark,
  ///    statusBarColor: Colors.transparent,
  ///    statusBarBrightness: Brightness.light,
  ///    statusBarIconBrightness: Brightness.dark,
  ///  )
  /// ```
  final SystemUiOverlayStyle darkStyle;

  /// The `SystemUiOverlayStyle` to apply when the background behind status bar is dark. This shall
  /// use light icons etc. Defaults to:
  /// ```dart
  /// const SystemUiOverlayStyle(
  ///    systemNavigationBarColor: Colors.black,
  ///    systemNavigationBarIconBrightness: Brightness.light,
  ///    statusBarColor: Colors.transparent,
  ///    statusBarBrightness: Brightness.dark,
  ///    statusBarIconBrightness: Brightness.light,
  ///  )
  /// ```
  final SystemUiOverlayStyle lightStyle;
}
