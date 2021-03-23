import 'package:dio/dio.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';
import 'dart:convert';

import 'package:PROTOCO_flutter/storage/keystore.dart';
import 'package:PROTOCO_flutter/util/util.dart';

class Api {
  // Singleton
  static final Api _instance = Api._internal();

  Dio api;
  KVStore kvstore;

  // Singleton
  factory Api() {
    return _instance;
  }

  // Initializer
  Api._internal() {
    api = Dio();

    api.interceptors.add(
      InterceptorsWrapper(onRequest: (RequestOptions options) async {
        var customHeaders = {
          'Content-Type': 'application/json',
          'Accept-Charset': 'utf-8',
          'User-Agent': await FlutterUserAgent.getPropertyAsync('userAgent'),
        };
        options.headers.addAll(customHeaders);
        options.validateStatus = (code) {
          // if (code < 500) {
          return true;
          // }
          // return false;
        };

        // TODO: Set proper api version on production
        options.baseUrl = 'https://protoco.cc/api/dev';

        return options;
      }),
    );
  }
}

class ApiResult {
  Map<String, List<String>> header;

  bool success;
  int code;
  String subCode;
  String message;
  Map<String, dynamic> data;

  ApiResult.fromResponse(Response response) {
    if (response == null) {
      throw Exception('응답이 없습니다');
    }
    if (response.statusCode > 500) {
      throw Exception('서버와 통신에 실패했어요.');
    }
    dynamic responseJson = json.decode(response.data);
    if (responseJson == null) {
      throw Exception('서버에서 받은 응답을 이해하지 못했어요.');
    }

    this.header = response.headers.map;
    this.success = response.data['success'];
    this.code = response.data['code'];
    this.subCode = response.data['sub_code'];
    this.message = response.data['message'];
    this.data = response.data['data'];

    if (this.subCode.startsWith('request.body')) {
      throw ExcMsg(
        '알 수 없는 문제가 발생했어요.',
        debugMessage: '클라이언트가 요청할 데이터를 제대로 보내지 않았어요.',
      );
    } else if (this.subCode.startsWith('request.header')) {
      throw ExcMsg(
        '알 수 없는 문제가 발생했어요.',
        debugMessage: '클라이언트가 요청의 말머리를 제대로 보내지 않았어요.',
      );
    } else if (this.subCode.startsWith('backend')) {
      throw ExcMsg(
        '서버에 알 수 없는 문제가 발생했어요.',
        debugMessage: '서버가 영 좋지 않은 상황이에요.',
      );
    } else if (this.subCode.startsWith('http')) {
      throw ExcMsg('서버에서 무엇을 할지 모르는 요청이에요...');
    }
  }
}
