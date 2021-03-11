import 'package:flutter/material.dart';

import 'main/index.dart';
import 'main/not_found.dart';
import 'main/introduce.dart';

import 'auth/create_account.dart';
import 'auth/find_password.dart';
import 'auth/login.dart';

class RouteManager {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) => IndexPage(),
    '/notfound': (context) => NotFoundRoute(),
    '/introduce': (context) => IntroduceRoute(),
    '/auth/create': (context) => AccountCreateRoute(),
    '/auth/find-password': (context) => AccountFindPasswordRoute(),
    '/auth/login': (context) => AccountLoginRoute(),
  };
  static final initialRoute = '/';
}
