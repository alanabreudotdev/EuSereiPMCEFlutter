import 'dart:convert';
import 'appsettings.dart';
import 'package:http/http.dart' as http;

class CallApi{

  final String _url = AppSettings.url+'api/';

  postData(data, apiUrl) async {

    var fullUrl = _url + apiUrl;
    //var fullUrl = apiUrl;

    try {
      var response =  await http.post(
          fullUrl,
          body: jsonEncode(data),
          headers: _setHeaders()

      )
          .timeout(new Duration(seconds: 5),
          onTimeout: () =>
              http.Response(json.encode({'success':false, 'message': 'Erro de rede'}), 401))
      /* DEFINE O TEMPO LIMITE DA REQUISICAO */
          .catchError(
              (e) =>
              http.Response(json.encode({'success':false, 'message': 'Requisição não concluída. Tente novamente'}), 401));
      data = json.decode(response.body);
      //print(response.body);
      //print(data);
      print(fullUrl);

      return data;

    } on Exception catch(e){
      print(e);
      data = [];
    }
  }

  getData(apiUrl) async {

    var data;
    var fullUrl = _url + apiUrl;
    //var fullUrl =  apiUrl;
    print(fullUrl);

    try {
      var response = await http
          .get(
          fullUrl,
          headers: _setHeaders()
      )
          .timeout(new Duration(seconds: 30),
          onTimeout: () =>
              http.Response(json.encode({'success':false, 'message': 'Erro de rede.'}), 401))
      /* DEFINE O TEMPO LIMITE DA REQUISICAO */
          .catchError(
              (e) =>
              http.Response(json.encode({'success':false, 'message': 'Requisição não concluída. Tente novamente'}), 401),);
      data = json.decode(response.body);

      print(data);
      return data;

    } on Exception catch(e){
      print(e);
      data = [];
    }


  }

  _setHeaders() => {
    'Content-type' : 'application/json',
    'Accept' : 'application/json',
  };

}