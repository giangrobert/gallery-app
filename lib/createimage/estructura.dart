import 'dart:convert';
import 'dart:io';

import 'package:app_contactos/home/model/imagesResponse.dart';
import 'package:app_contactos/home/provider/imagesProviderDB.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text("Cargar una imagen nueva"),
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
                        Text('Agrega todos los campos*'),
                        GFButton(
                          onPressed: () {
                            abrirSeleccionOrigen();
                          },
                          text: "Cargar Photo",
                          shape: GFButtonShape.square,
                        ),
                        imagen != null ? Image.file(imagen!) : Center(),
                        obtenerCampoTitle(),
                        obtenerCampoDescription(),
                        obtenerCampoImg(),
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
                GestureDetector(
                  child: Text("Cámara"),
                  onTap: () {
                    //obtenerImagen(ImageSource.camera);
                  },
                ),
                Padding(padding: EdgeInsets.all(15)),
                GestureDetector(
                  child: Text("Galería"),
                  onTap: () {
                    //obtenerImagen(ImageSource.gallery);
                  },
                ),
              ],
            )),
          );
        });
  }

  TextFormField obtenerCampoTitle() {
    return TextFormField(
      keyboardType: TextInputType.name,
      decoration: InputDecoration(labelText: "title", hintText: "Jhon"),
      validator: (value) {
        if (value!.length > 0) {
          return null;
        } else {
          return "El nombre de contacto no es válido";
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
      decoration: InputDecoration(labelText: "Description", hintText: "Doe"),
      validator: (value) {
        if (value!.length > 0) {
          return null;
        } else {
          return "Los apellidos del contacto no son válidos";
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
      validator: (value) {},
    );
  }

  GFButton botonCrearImagen() {
    return GFButton(
      onPressed: () {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();
          crearImage();
          //uploadStatusImage();
          //subirImagen(imagen!, titleIngresado, descriptionIngresado);
          Navigator.pop(context);
        }
      },
      text: "Crear Photo",
      type: GFButtonType.solid,
      fullWidthButton: true,
      color: Colors.green.shade400,
    );
  }

  crearImage() async {
    ImageModel cm = ImageModel.fromValues(
        titleIngresado, descriptionIngresado, imgIngresado);

    ImagesProviderDb ipdb = ImagesProviderDb();
    await ipdb.init();

    var nums = await ipdb.agregarImage(cm);

    var result = await ipdb.obtenerImages();
  }

  //fIREDBASE

/*Future<ImageModel> subirImagen(
      File image, String title, String description) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //var token = await prefs.getString('token');
    //Map<String, String> headers = {"Authorization": token.toString()};
    var request = http.MultipartRequest(
        "POST", Uri.parse("https://igalery.herokuapp.com/api/gallery/create"));
    // request.headers.addAll(headers);
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

    var response = await request.send();

    var responseData = await response.stream.toBytes();

    String rawResponse = utf8.decode(responseData);

    var jsonResponse = jsonDecode(rawResponse);

    print(rawResponse);

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
  }*/
}
