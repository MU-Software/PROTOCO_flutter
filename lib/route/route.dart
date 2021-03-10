import 'package:flutter/material.dart';

import 'main/index.dart';
import 'main/not_found.dart';
import 'main/introduce.dart';

class RouteManager {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => IndexPage(),
    '/notfound': (context) => NotFoundRoute(),
    '/introduce': (context) => IntroduceRoute(),
  };
  static final initialRoute = '/';
}
