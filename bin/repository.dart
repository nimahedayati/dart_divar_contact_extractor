import 'dart:io';

import 'package:dio/dio.dart';

import 'dart_divar_contact_extractor.dart';

class Repository {
  Dio dio = Dio();

  Future<dynamic> authenticate(String mobile) async {
    var params = {'phone': mobile};

    var response = await dio.post('https://api.divar.ir/v5/auth/authenticate', data: params);

    return response.data;
  }

  Future<dynamic> confirm(String mobile, String code) async {
    var params = {'phone': mobile, 'code': code};

    var response = await dio.post('https://api.divar.ir/v5/auth/confirm', data: params);

    return response.data;
  }

  Future<dynamic> getMainPosts(List<int> cities, String q) async {
    var params = {'q': q, 'cities': cities.join(',')};

    var response = await dio.get('https://api.divar.ir/v8/web-search/iran', queryParameters: params);

    return response.data;
  }

  Future<dynamic> getPosts(List<int> cities, String q, int page, num lastPostDate) async {
    Map<String, dynamic> data = {
      "page": page,
      "json_schema": {
        "cities": cities.map((e) => e.toString()).toList(),
        "category": {"value": "ROOT"},
        "query": q
      },
      "last-post-date": lastPostDate
    };

    var response = await dio.post('https://api.divar.ir/v8/web-search/16/ROOT', data: data);

    return response.data;
  }

  Future<dynamic> getPostContact(String token) async {
    try {
      var response = await dio.get('https://api.divar.ir/v8/postcontact/web/contact_info/$token',
          options: Options(
            headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"},
          ));

      var list = response.data['widget_list'];

      for (var item in list) {
        if (item['data']['action']['type'] == 'CALL_SUPPORT') {
          return item['data']['action']['payload']['phone_number'];
        }
      }
    } catch (e) {
      if (e is DioException) {
        return (e.response?.data['message']['title']);
      }
    }

    return null;
  }

  Future<dynamic> getServiceContact(String slug, String cat) async {
    try {
      var response = await dio.get('https://api.divar.ir/v8/postcontact/web/contact_info/services_profile_$slug',
          options: Options(
            headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"},
          ));

      var list = response.data['widget_list'];

      for (var item in list) {
        if (item['data']['action']['type'] == 'CALL_SUPPORT') {
          return item['data']['action']['payload']['phone_number'];
        }
      }
    } catch (e) {
      if (e is DioException) {
        return (e.response?.data['message']['title']);
      }
    }

    return null;
  }
}
