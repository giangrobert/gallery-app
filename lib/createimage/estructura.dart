import 'dart:convert';
import 'dart:io';

import 'package:app_contactos/home/model/imagesResponse.dart';
import 'package:app_contactos/home/provider/imagesProviderAPI.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CreateImagePage extends StatefulWidget {
  static String ruta = "/createimage";

  @override
  State<StatefulWidget> createState() {
    return _CreateImagePage();
  }
}

class _CreateImagePage extends State<CreateImagePage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? imagen = null;
  final picker = ImagePicker();

  Future selImagen(op) async {
    var pickerFile;
    if (op == 1) {
      pickerFile = await picker.pickImage(source: ImageSource.camera);
    } else if (op == 2) {
      pickerFile = await picker.pickImage(source: ImageSource.gallery);
    }
    setState(() {
      if (pickerFile != null) {
        //imagen = File(pickerFile.path);
        cortar(File(pickerFile.path));
      } else {
        print('No seleccionaste ninguna imagen');
      }
    });
    Navigator.of(context).pop();
  }

  cortar(picked) async {
    File? cortado = await ImageCropper.cropImage(
        sourcePath: picked.path,
        aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
    if (cortado != null) {
      setState(() {
        imagen = cortado;
        print('imagen ${picked.path}');

        //imgIngresado = basename(picked.path);
        //uploadFile(imagen);
      });
    }
  }

  String titleIngresado = "";
  String descriptionIngresado = "";
  String imgIngresado = "";
  String longitudIngresado = "";
  String latitudIngresado = "";
  String altitudIngresado = "";
  String tiporedIngresado = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFFfdfded),
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text(
            "Cargar una Imagen Nueva",
            style: GoogleFonts.pacifico(fontSize: 22, color: Colors.white),
          ),
        ),
        body: Container(
            padding: EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Card(
                child: Container(
                  padding: EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        GFButton(
                          onPressed: () {
                            abrirSeleccionOrigen();
                          },
                          text: "  Cargar Imagen",
                          shape: GFButtonShape.square,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        imagen != null ? Image.file(imagen!) : Center(),
                        SizedBox(
                          height: 30,
                        ),
                        obtenerCampoTitle(),
                        SizedBox(
                          height: 20,
                        ),
                        obtenerCampoDescription(),
                        SizedBox(
                          height: 40,
                        ),
                        botonCrearImagen()
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  Future<void> abrirSeleccionOrigen() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
                child: Column(
              children: [
                GFButton(
                  onPressed: () {
                    selImagen(1);
                  },
                  text: "Cámara",
                  shape: GFButtonShape.square,
                  type: GFButtonType.outline,
                  fullWidthButton: true,
                ),
                GFButton(
                  onPressed: () {
                    selImagen(2);
                  },
                  text: "Galería",
                  shape: GFButtonShape.square,
                  type: GFButtonType.outline2x,
                  fullWidthButton: true,
                ),
              ],
            )),
          );
        });
  }

  TextFormField obtenerCampoTitle() {
    return TextFormField(
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Titulo"),
      validator: (value) {
        if (value!.length > 0) {
          return null;
        } else {
          return "No se ha ingresado un Titulo";
        }
      },
      onSaved: (value) {
        titleIngresado = value!;
      },
    );
  }

  TextFormField obtenerCampoDescription() {
    return TextFormField(
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "Descripción"),
      validator: (value) {
        if (value!.length > 0) {
          return null;
        } else {
          return "No se ha ingresado una Descripción";
        }
      },
      onSaved: (value) {
        descriptionIngresado = value!;
      },
    );
  }

  TextFormField obtenerCampoImg() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(labelText: "IMG", hintText: "jo"),
      validator: (value) {
        if (value!.length > 0) {
          return null;
        } else {
          return "No se ha seleccionado una imagen";
        }
      },
      onSaved: (value) {
        imgIngresado = value!;
      },
    );
  }

  GFButton botonCrearImagen() {
    return GFButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          crearImage();
          //uploadStatusImage();
          subirImagen(imagen!, titleIngresado, descriptionIngresado);
          Navigator.pop(context);
        }
      },
      text: "Subir Foto",
      type: GFButtonType.solid,
      fullWidthButton: true,
      color: Colors.green.shade400,
    );
  }

  crearImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString('token');
    Position position = await obtenerPosicionGeografica();
    longitudIngresado = position.longitude.toString();
    latitudIngresado = position.latitude.toString();
    altitudIngresado = position.altitude.toString();
    ImageModel cm = ImageModel.fromValues(
        titleIngresado,
        descriptionIngresado,
        imgIngresado,
        longitudIngresado,
        latitudIngresado,
        altitudIngresado,
        tiporedIngresado);

    ImagesProviderApi ipdb = ImagesProviderApi();

    var nums = await ipdb.crearImage(token.toString(), cm);

    var result = await ipdb.obtenerListadoImages(token.toString());
  }

  //fIREDBASE

  Future<ImageModel> subirImagen(
      File image, String title, String description) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString('token');

    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      tiporedIngresado = 'Datos Móviles';
    } else if (connectivityResult == ConnectivityResult.wifi) {
      tiporedIngresado = 'Wifi';
    }

    var request = http.MultipartRequest(
        "POST", Uri.parse("https://igalery.herokuapp.com/api/gallery/create"));
    request.headers["Authorization"] = token.toString();
    var picture = await http.MultipartFile.fromPath("imagen", image.path);

    request.files.add(
      picture,
    );

    Position position = await obtenerPosicionGeografica();
    request.fields["title"] = title;
    request.fields["description"] = description;
    request.fields["longitud"] = position.longitude.toString();
    request.fields["latitud"] = position.latitude.toString();
    request.fields["altitud"] = position.altitude.toString();
    request.fields["tipoRed"] = tiporedIngresado;

    var response = await request.send();

    var responseData = await response.stream.toBytes();

    String rawResponse = utf8.decode(responseData);

    var jsonResponse = jsonDecode(rawResponse);

    ImageModel ir = ImageModel(jsonResponse);

    return ir;
  }

  Future<Position> obtenerPosicionGeografica() async {
    bool servicioHabilidado = await Geolocator.isLocationServiceEnabled();
    //GPS esta encendido

    if (servicioHabilidado) {
      LocationPermission permisos = await Geolocator.checkPermission();

      if (permisos == LocationPermission.denied ||
          permisos == LocationPermission.deniedForever) {
        permisos = await Geolocator.requestPermission();
      }

      if (permisos == LocationPermission.whileInUse ||
          permisos == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.bestForNavigation);
        return position;
      }
    }

    return Position(
        longitude: 0,
        latitude: 0,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0);
  }
}
