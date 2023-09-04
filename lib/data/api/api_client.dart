import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get_connect/connect.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_academy/utils/app_contanants.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiClient extends GetConnect implements GetxService {
  late String token;
  final String appBaseUrl;
  final SharedPreferences sharedPreferences;
  late Map<String, String> _mainHeaders;
  late final GetConnect _connect;

  ApiClient({required this.sharedPreferences, required this.appBaseUrl}) {
    baseUrl = appBaseUrl;
    _connect = GetConnect();

    token = sharedPreferences.getString(AppConstants.TOKEN) ?? "";
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
  }
  void updateHeader(String token) {
    this.token = token;
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': '*/*',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Response> getData(
    String uri, {
    Map<String, dynamic>? query,
    String? contentType,
    Map<String, String>? headers,
    Function(dynamic)? decoder,
  }) async {
    final url = '$appBaseUrl/$uri';
    try {
      Response response = await _connect.get(
        url,
        contentType: contentType,
        query: query,
        headers: _mainHeaders,
        decoder: decoder,
      );

      response = handleResponse(response);

      return response;
    } catch (e) {
      debugPrint('error in api client $e');
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> deleteData(
    String uri, {
    Map<String, dynamic>? query,
    String? contentType,
    Map<String, String>? headers,
    Function(dynamic)? decoder,
  }) async {
    final url = '$appBaseUrl/$uri';
    try {
      Response response = await _connect.delete(
        url,
        contentType: contentType,
        query: query,
        headers: _mainHeaders,
        decoder: decoder,
      );

      response = handleResponse(response);

      return response;
    } catch (e) {
      debugPrint('error in api client $e');
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> patchData(String uri, dynamic body,
      {String? contentType}) async {
    final url = '$appBaseUrl/$uri';

    final prev = _mainHeaders;
    if (contentType != null) prev['Content-Type'] = contentType;

    try {
      Response response = await _connect.patch(
        url,
        body,
        contentType: 'application/json; charset=UTF-8',
        headers: prev,
      );
      response = handleResponse(response);

      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Future<Response> multiPart({
    required String uri,
    required File file,
    required String fileName,
    required String type,
  }) async {
    try {
      uri = '$appBaseUrl/$uri';

      var url = Uri.parse(uri);
      var request = http.MultipartRequest(type, url)
        ..files.add(await http.MultipartFile.fromPath(fileName, file.path,
            contentType: MediaType('application', 'x-tar')))
        ..headers.addAll(_mainHeaders);

      http.Response httpResponse =
          await http.Response.fromStream(await request.send());

      Response response = Response(
        body: json.decode(httpResponse.body) as Map<String, dynamic>,
        headers: httpResponse.headers,
        statusCode: httpResponse.statusCode,
      );

      response = handleResponse(response);

      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> multiPartWithFields({
    required String uri,
    required File? file,
    required String fileName,
    required String type,
    required Map<String, String> fields,
  }) async {
    try {
      uri = '$appBaseUrl/$uri';

      var url = Uri.parse(uri);
      var request = http.MultipartRequest(type, url)
        ..headers.addAll(_mainHeaders);
      if (file != null)
        request.files.add(await http.MultipartFile.fromPath(fileName, file.path,
            contentType: MediaType('application', 'x-tar')));
      if (fields.isNotEmpty) request.fields.addAll(fields);

      http.Response httpResponse =
          await http.Response.fromStream(await request.send());

      Response response = Response(
        body: json.decode(httpResponse.body) as Map<String, dynamic>,
        headers: httpResponse.headers,
        statusCode: httpResponse.statusCode,
      );

      response = handleResponse(response);

      return response;
    } catch (error) {
      rethrow;
    }
  }

  Future<Response> postData(
    String uri,
    dynamic body,
  ) async {
    final url = '$appBaseUrl/$uri';

    try {
      Response response = await _connect.post(
        url,
        body,
        contentType: 'application/json; charset=UTF-8',
        headers: _mainHeaders,
      );
      response = handleResponse(response);

      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: e.toString());
    }
  }

  Response handleResponse(Response response) {
    Response _response = response;
    if (_response.hasError &&
        _response.body != null &&
        _response.body is! String) {
      if (_response.body.toString().startsWith('{errors: [{code:')) {
        debugPrint('{errors: [{code:');

        _response = Response(
            statusCode: _response.statusCode,
            body: _response.body,
            statusText: "Error");
      } else if (_response.body.toString().startsWith('{message')) {
        debugPrint('message');
        _response = Response(
            statusCode: _response.statusCode,
            body: _response.body,
            statusText: _response.body['message']);
      }
    } else if (_response.hasError && _response.body == null) {
      debugPrint("The status code is " + _response.statusCode.toString());
      _response = Response(
          statusCode: 0,
          statusText:
              'Connection to API server failed due to internet connection');
    }
    return _response;
  }

  @override
  void onInit() {
    httpClient.baseUrl = appBaseUrl;
    httpClient.defaultContentType = "application/json";
    httpClient.timeout = Duration(seconds: 8);

    super.onInit();
  }
}
