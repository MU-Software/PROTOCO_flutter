import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_user_agent/flutter_user_agent.dart';

import 'package:PROTOCO_flutter/storage/keystore.dart';
import 'package:PROTOCO_flutter/util/util.dart';

class Api {
  // Singleton
  static final Api _instance = Api._internal();

  Dio api;
  CookieManager cookieManager;

  // Singleton
  factory Api() {
    return _instance;
  }

  // Initializer
  Api._internal() {
    api = Dio();
    cookieManager = CookieManager(CookieJar());

    api.interceptors.add(cookieManager);
    api.interceptors.add(
      InterceptorsWrapper(onRequest: (RequestOptions options) async {
        var customHeaders = {
          'Content-Type': 'application/json',
          'Accept-Charset': 'utf-8',
          'User-Agent': await FlutterUserAgent.getPropertyAsync('userAgent'),
        };
        options.headers.addAll(customHeaders);
        options.validateStatus = (code) {
          // Make all response success as we send custom error codes
          return true;
        };

        // TODO: Set proper api version on production
        options.baseUrl = 'https://protoco.cc/api/dev';

        return options;
      }),
    );
  }

  Future<bool> checkTokenStatus({bool forceTokenRefresh = false}) async {
    KVStore kvStore = KVStore();
    if (kvStore.data['refresh_token'] == null || kvStore.data['refresh_token'].isEmpty) {
      return false;
    }

    if (!forceTokenRefresh) {
      // Try to parse access token cookie string only when forceTokenRefresh is false
      // This means when forceTokenRefresh is true, then there will be request on /account/refresh everytime
      if (kvStore.data['access_token'] != null && kvStore.data['access_token'].isNotEmpty) {
        try {
          Cookie accessTokenCookie = Cookie.fromSetCookieValue(kvStore.data['access_token'] ?? '');
          if (accessTokenCookie.expires.toUtc().isAfter(DateTime.now().toUtc())) {
            // Only set isAccessTokenExpired to false when accessToken is not expired
            return true;
          }
        } catch (e) {}
      }
    }

    // Make access token alive again
    try {
      ApiResult apiResult = ApiResult.fromResponse(
        await this.api.post(
              '/account/refresh',
              options: Options(
                headers: {'Cookie': kvStore.data['refresh_token']},
              ),
            ),
      );
      if (apiResult.success) {
        for (String setcookie in apiResult.header['set-cookie']) {
          try {
            Cookie c = Cookie.fromSetCookieValue(setcookie);
            if (c.name == 'access_token') {
              kvStore['access_token'] = setcookie;
              return true;
            } else if (c.name == 'refresh_token') {
              kvStore['refresh_token'] = setcookie;
            }
          } catch (e) {}
        }
        // Refreshing accessToken failed
        return false;
      }
    } catch (e) {}
    return false;
  }

  ExcMsg requestErrorHandler(DioError e, StackTrace stackTrace) {
    String clientMessage, debugMessage;

    ApiResult apiResult;
    if (e.response != null) {
      apiResult = ApiResult.fromResponse(e.response);
      // If ApiResult.fromResponse didn't throw Exception, then we can get subCode from response.
    }
    switch (e.type) {
      case DioErrorType.RESPONSE:
        clientMessage = '서버가 알 수 없는 대답을 보냈어요.\n잠시 후에 다시 시도해주세요.';
        debugMessage = '서버가 응답했으나 오류로 처리되었습니다.';
        break;
      case DioErrorType.CANCEL:
        clientMessage = '요청을 중단했어요.\n다시 시도해주세요.';
        debugMessage = '유저가 요청을 중단했습니다.';
        break;
      case DioErrorType.CONNECT_TIMEOUT:
        clientMessage = '서버와 연결하기위해 기다렸지만 연결을 맺지 못했어요.\n잠시 후에 다시 시도해주세요.';
        debugMessage = 'CONNECT_TIMEOUT 입니다.';
        break;
      case DioErrorType.RECEIVE_TIMEOUT:
        clientMessage = '서버의 대답을 기다렸지만 오지 않았어요.\n잠시 후에 다시 시도해주세요.';
        debugMessage = 'RECEIVE_TIMEOUT 입니다.';
        break;
      case DioErrorType.SEND_TIMEOUT:
        clientMessage = '서버에 정보를 전달할 수 없어요.\n인터넷 연결을 확인해주세요.';
        debugMessage = 'SEND_TIMEOUT 입니다.';
        break;
      case DioErrorType.DEFAULT:
        clientMessage = '서버와 통신을 할 수 없어요.\n인터넷 연결을 확인해주세요.';
        if (apiResult != null) {
          if (apiResult.message != null && apiResult.message.isEmpty) clientMessage = apiResult.message;
          debugMessage = 'Response의 subCode는 ${apiResult.subCode}입니다.';
        } else {
          debugMessage = 'DioErrorType.DEFAULT 입니다.';
        }
        break;
      default:
        clientMessage = '서버와 통신중에 문제가 생겼어요.\n잠시 후에 다시 시도해주세요.';
        debugMessage = 'DioErrorType case에서 match되는 것이 없이 default 입니다.';
        break;
    }
    return ExcMsg(
      clientMessage,
      debugMessage: debugMessage,
      exception: e,
      stackTrace: stackTrace,
    );
  }

  Future<ApiResult> safeRequest(Future<Response> reqFunc(), String path, {bool needToken: false}) async {
    try {
      KVStore kvStore = KVStore();
      List<Cookie> authCookies = List<Cookie>();
      if (cookieManager != null) {
        api.interceptors.remove(cookieManager);
        api.interceptors.removeWhere((item) => item == null);
        cookieManager = null;
      }

      if (needToken) {
        if (!await this.checkTokenStatus()) throw ExcMsg('로그인이 필요해요,\n로그인 후 다시 시도해주세요!');

        authCookies.add(Cookie('access_token', kvStore.data['access_token']));
        if (path.startsWith('/account/')) authCookies.add(Cookie('refresh_token', kvStore.data['refresh_token']));
      }

      if (authCookies.isNotEmpty) {
        CookieJar newCookieJar = CookieJar();
        newCookieJar.saveFromResponse(Uri.parse('https://protoco.cc/'), authCookies);
        cookieManager = CookieManager(newCookieJar);
        api.interceptors.add(cookieManager);
      }

      Response response = await reqFunc();
      return ApiResult.fromResponse(response);
    } on DioError catch (e, stacktrace) {
      throw this.requestErrorHandler(e, stacktrace);
    } on ExcMsg catch (e) {
      throw e;
    } on Exception catch (e, stackTrace) {
      throw ExcMsg(
        '서버와의 통신 중에 문제가 발생했어요.\n잠시 후 다시 시도해주세요.',
        debugMessage: '알 수 없는 예외가 발생했습니다.(exception object is subclass of Exception)',
        exception: e,
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ExcMsg(
        '서버와의 통신 중에 문제가 발생했어요.\n잠시 후 다시 시도해주세요.',
        debugMessage: '알 수 없는 예외가 발생했습니다.(exception(${e.runtimeType.toString()}) is not a subclass of Exception)',
        stackTrace: stackTrace,
      );
    }
  }

  Future<ApiResult> get(String path,
      {bool needToken: false, Map<String, dynamic> queryParameters, Options options}) async {
    return this.safeRequest(
      () => this.api.get(
            path,
            queryParameters: queryParameters,
            options: options,
          ),
      path,
      needToken: needToken,
    );
  }

  Future<ApiResult> post(String path, {bool needToken: false, dynamic data, Options options}) async {
    return this.safeRequest(
      () => this.api.post(
            path,
            data: data,
            options: options,
          ),
      path,
      needToken: needToken,
    );
  }

  Future<ApiResult> patch(String path, {bool needToken: false, dynamic data, Options options}) async {
    return this.safeRequest(
      () => this.api.post(
            path,
            data: data,
            options: options,
          ),
      path,
      needToken: needToken,
    );
  }

  Future<ApiResult> put(String path, {bool needToken: false, dynamic data, Options options}) async {
    return this.safeRequest(
      () => this.api.post(
            path,
            data: data,
            options: options,
          ),
      path,
      needToken: needToken,
    );
  }

  Future<ApiResult> delete(String path, {bool needToken: false, dynamic data, Options options}) async {
    return this.safeRequest(
      () => this.api.post(
            path,
            data: data,
            options: options,
          ),
      path,
      needToken: needToken,
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

  ApiResult({this.success, this.code, this.subCode, this.message, this.data});

  factory ApiResult.fromResponse(Response response, {bool isRetry: false}) {
    ApiResult _this = ApiResult();
    if (response == null) {
      throw ExcMsg(
        '서버가 응답이 없어요,\n잠시 후에 다시 시도해주세요.',
        debugMessage: 'response 객체가 null입니다.',
      );
    } else if (response.statusCode > 500) {
      throw ExcMsg(
        '서버와 통신에 실패했어요,\n잠시 후에 다시 시도해주세요.',
        debugMessage: 'statusCode가 ${response.statusCode.toString()}입니다.',
      );
    }

    dynamic responseJson = response.data;
    if (responseJson == null) {
      throw ExcMsg(
        '서버에서 받은 응답을 이해하지 못했어요,\n잠시 후에 다시 시도해주세요.',
        debugMessage: '서버에서 받은 데이터를 파싱하지 못했습니다.',
      );
    }

    _this.header = response?.headers?.map ?? Map<String, dynamic>();
    if (response.data.runtimeType == Map) {
      _this.success = (response.data['success'] ?? '') == 'true';
      _this.code = int.tryParse(response.data['code'] ?? '');
      _this.subCode = response.data['sub_code'] ?? '';
      _this.message = response.data['message'] ?? '';
      _this.data = response.data['data'] ?? '';
    } else {
      _this.success = false;
      _this.code = -1;
      _this.subCode = '';
      _this.message = '';
      _this.data = Map<String, dynamic>();
    }

    if (!_this.success) {
      if (_this.subCode.startsWith('request.body')) {
        throw ExcMsg(
          '알 수 없는 문제가 발생했어요,\n잠시 후에 다시 시도해주세요.',
          debugMessage: '클라이언트가 요청할 데이터를 제대로 보내지 않았어요.',
        );
      } else if (_this.subCode.startsWith('request.header')) {
        throw ExcMsg(
          '알 수 없는 문제가 발생했어요,\n잠시 후에 다시 시도해주세요.',
          debugMessage: '클라이언트가 요청의 말머리를 제대로 보내지 않았어요.',
        );
      } else if (_this.subCode.startsWith('backend')) {
        throw ExcMsg(
          '서버에 알 수 없는 문제가 발생했어요,\n잠시 후에 다시 시도해주세요.',
          debugMessage: '서버가 영 좋지 않은 상황이에요.',
        );
      } else if (_this.subCode.startsWith('http')) {
        throw ExcMsg('서버에서 무엇을 할지 모르는 요청이에요...');
      } else if (_this.subCode.startsWith('refresh_token')) {
        KVStore()['refresh_token'] = null;
        KVStore()['access_token'] = null;
        throw ExcMsg(
          '로그인 정보가 올바르지 않아요,\n죄송하지만 다시 로그인 해주세요.',
          debugMessage: '서버가 ${_this.subCode}를 반환했습니다.',
        );
      } else if (_this.subCode.startsWith('access_token')) {
        // Maybe access token's time is not expired, but it's revoked?
        // We need to retry this request after force token refresh.
        if (!isRetry) {
          return ApiResult.fromResponse(response, isRetry: true);
        } else {
          KVStore()['refresh_token'] = null;
          KVStore()['access_token'] = null;
          throw ExcMsg(
            '로그인 정보가 올바르지 않아요,\n죄송하지만 다시 로그인 해주세요.',
            debugMessage: 'AccessToken이 올바르지 않고, 서버가 ${_this.subCode}를 반환했습니다.',
          );
        }
      } else {
        throw ExcMsg(
          '서버와의 통신에서 문제가 발생했어요,\n잠시 후 다시 시도해주세요.',
          debugMessage: '서버가 "${_this.subCode.isEmpty ? "sub_code 없음" : _this.subCode}"를 반환했습니다.',
        );
      }
    }
    return _this;
  }
}
