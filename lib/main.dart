import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'route/route.dart';
import 'storage/keystore.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await KVStore().init();

  runApp(ProtocoApp());
}

class ProtocoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PROTOCO',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: RouteManager.routes,
      initialRoute: RouteManager.initialRoute,
    );
  }
}
