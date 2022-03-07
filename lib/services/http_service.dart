import 'dart:convert';
import 'package:http/http.dart';
import 'package:thecatapp/models/breed_model.dart';
import 'package:thecatapp/models/cat_model.dart';

import 'log_service.dart';

class Network {
  /// Set isTester ///
  static bool isTester = true;

  /// Servers Types ///
  static String SERVER_DEVELOPMENT = "api.thecatapi.com";
  static String SERVER_PRODUCTION = "api.thecatapi.com";

  /// * Http Apis *///
  static String API_LIST = "/v1/images/search";
  static String API_LIST_Breeds = "/v1/breeds";


  // static String API_SEARCH_PHOTOS = '/search/photos';

  /// Getting Header ///
  static Map<String, String> getHeaders() {
    Map<String, String> header = {
      "x-api-key": "427308b2-632e-4532-a9c9-75d8506bd708",
      "Content-Type": "application/json",
    };
    return header;
  }

  /// Selecting Test Server or Production Server  ///

  static String getServer() {
    if (isTester) return SERVER_DEVELOPMENT;
    return SERVER_PRODUCTION;
  }

  ///* Http Requests *///

  /// GET method///
  static Future<String?> GET(String api, Map<String, String> params) async {
    Uri uri = Uri.https(getServer(), api, params);
    Response response = await get(uri, headers: getHeaders());
    Log.i(response.body);
    if (response.statusCode == 200) return response.body;
    return null;
  }

  /// * Http Params * ///

  /// GET PARAM
  static Map<String, String> paramsGet(int page) {
    Map<String, String> params = {
      'limit': '10',
      'page': '$page',
      'order': 'Desc',
    };
    return params;
  }

  /// GET PARAM EMPTY
  static Map<String, String> paramEmpty() {
    Map<String, String> params = {};
    return params;
  }

  static Map<String, String> paramSearch(String id,int page) {
    Map<String, String> params = {
      'limit': '10',
      'page': '$page',
      'breed_ids':id,
    };
    return params;
  }


  /// PARSING ///

  static List<Cat> parseCatList(String response) {
    var data = catListFromJson(response);
    return data;
  }

  static List<Breeds> parseBreedsList(String response) {
    var data = breedsListFromJson(response);
    return data;
  }

  static List<Breeds> parseSearch(String response) {

    var data = breedsListFromJson(response);
    return data;
  }


}
