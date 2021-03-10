import 'package:dio/dio.dart';

class Api {
  // Singleton
  static final Api _instance = Api._internal();

  Dio api;

  // Singleton
  factory Api() {
    return _instance;
  }

  // Initializer
  Api._internal() {
    api = Dio();
    api.interceptors.add(InterceptorsWrapper(onRequest: (RequestOptions options) async {
      var customHeaders = {};
      options.headers.addAll(customHeaders);

      // TODO: Set proper api version on production
      options.baseUrl = 'https://protoco.cc/api/dev';
      return options;
    }));
  }
}
