import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'repository.dart';

Repository repository = Repository();

String authToken = '';

getPhoneNumbers(List<int> cities, String q) async {
  var result = await repository.getMainPosts(cities, q);

  List list = result['web_widgets']['post_list'];
  int page = 0;

  do {
    for (var item in list) {
      if (item['widget_type'] == 'POST_ROW') await printItem(item);
    }

    page++;
    print('----------PAGE $page----------');
    result = await repository.getPosts(cities, q, page, result['last_post_date']);
    list = result['web_widgets']['post_list'];
  } while (list.isNotEmpty);
}

printItem(var item) async {
  String? phone;

  if (item['data']['action']['type'] == 'VIEW_POST') {
    phone = await repository.getPostContact(item['data']['action']['payload']['token']);
  } else if (item['data']['action']['type'] == 'SERVICES_VIEW_PROFILE') {
    phone = await repository.getServiceContact(item['data']['action']['payload']['slug'], item['data']['action']['payload']['cat']);
  }

  var p = {
    'title': item['data']['title'],
    'link': item['data']['action']['payload']['token'],
    'phone_number': phone,
  };

  print(p);
}

void main(List<String> arguments) async {
  final ArgParser argParser = ArgParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    List rest = results.rest;

    if (rest.length != 1) {
      print('Args not corrected');
      return;
    }

    String mobile = rest.first;

    if (!mobile.startsWith('09') || mobile.length != 11) {
      print('Mobile not corrected');
      return;
    }

    print('AUTHENTICATING...');
    await repository.authenticate(mobile);

    String? code;
    while (code == null) {
      print('ENTER AUTH CODE:');
      code = stdin.readLineSync(encoding: utf8);
    }

    print('CONFIRMING...');
    var result = await repository.confirm(mobile, code);

    authToken = result['token'];

    print('WAITING...');
    await Future.delayed(Duration(seconds: 2));
    print('START');

    String? q;
    while (q == null) {
      print('ENTER SEARCH QUERY:');
      q = stdin.readLineSync(encoding: utf8);
    }

    List<int> cities = [1, 16];

    await getPhoneNumbers(cities, q);

    //
  } on FormatException catch (e) {
    print(e.message);
  }
}
