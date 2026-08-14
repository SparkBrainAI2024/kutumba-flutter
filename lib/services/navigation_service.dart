import 'package:flutter/material.dart';

class NavigationService {
  NavigationService._internal();

  static final NavigationService instance = NavigationService._internal();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName) {
    return navigatorKey.currentState!.pushNamed(routeName);
  }

  Future<dynamic> push(route) {
    return navigatorKey.currentState!.push(route);
  }

  Future<dynamic> pushReplacement(route) {
    return navigatorKey.currentState!.pushReplacement(route);
  }

  Future<dynamic> pushReplacementNamed(route) {
    // print(navigatorKey);
    // print(navigatorKey.currentState);
    return navigatorKey.currentState!.pushReplacementNamed('/albums');
  }
}
