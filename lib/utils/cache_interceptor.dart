import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CacheInterceptor extends Interceptor {
  CacheInterceptor();

  var _cache = Map<Uri, Response>();

  SharedPreferences prefs;

  Future onRequest(RequestOptions options) async {
    Response response = _cache[options.uri];
    if (options.extra["refresh"] == true) {
      print("${options.uri}: force refresh, ignore cache! \n");
      return options;
    } else {
      prefs = await SharedPreferences.getInstance();
      if(prefs.containsKey("${options.uri}")){
        var res = jsonDecode(prefs.getString(('${options.uri}')));
        return Response(
            data: res,
            statusCode: 200
        );
      }
    }
    return options;
  }

  @override
  Future onResponse(Response response) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("${response.request.uri}", jsonEncode(response.data));
    _cache[response.request.uri] = response;

    return response;
  }

  @override
  Future onError(DioError error) async {
   if(error.type == DioErrorType.CONNECT_TIMEOUT || error.type == DioErrorType.DEFAULT){
     prefs = await SharedPreferences.getInstance();
     if(prefs.containsKey("${error.request.uri}")){
       var res = jsonDecode(prefs.getString(('${error.request.uri}')));
       return Response(
         data: res,
         statusCode: 200
       );
     }
   }
  }
}