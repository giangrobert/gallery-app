import 'dart:convert';
import 'package:app_contactos/home/model/imagesResponse.dart';
import 'package:http/http.dart' as http;

class ImagesProviderApi {
  Future<ImagesResponse> obtenerListadoImages(String token) async {
    try {
      var url = Uri.parse("https://igalery.herokuapp.com/api/gallery/list");

      var responseHttp = await http.get(url, headers: {'Authorization': token});

      String rawResponse = utf8.decode(responseHttp.bodyBytes);

      var jsonResponse = jsonDecode(rawResponse);

      ImagesResponse imagesResponse = ImagesResponse.fromAPI(jsonResponse);

      return imagesResponse;
    } catch (ex) {
      return ImagesResponse.vacio();
    }
  }

  Future<void> crearImage(String token, ImageModel imagen) async {
    try {
      var url = Uri.parse("https://igalery.herokuapp.com/gallery/create");

      var responseHttp = await http.post(url, headers: {
        'Authorization': token
      }, body: {
        'title': imagen.title,
        'description': imagen.description,
        'img': imagen.img,
        'longitud': imagen.longitud,
        'latitud': imagen.latitud,
        'altitud': imagen.altitud,
        'tipoRed': imagen.tipoRed,
      });

      String rawResponse = utf8.decode(responseHttp.bodyBytes);
      print(rawResponse);
    } catch (ex) {}
  }
}
