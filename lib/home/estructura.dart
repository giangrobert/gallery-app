import 'dart:async';
import 'dart:convert' as convert;
import 'package:app_contactos/widgets/widget_conectid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

import 'package:app_contactos/createimage/estructura.dart';
import 'package:app_contactos/home/imageCard.dart';
import 'package:app_contactos/home/model/imagesResponse.dart';

import 'package:app_contactos/home/provider/imagesProviderAPI.dart';

import 'package:app_contactos/login/estructura.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/appbar/gf_appbar.dart';
import 'package:getwidget/components/button/gf_icon_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyImagessPage extends StatefulWidget {
  static String ruta = "/home";

  @override
  State<StatefulWidget> createState() {
    return _MyImagessPageState();
  }
}

class _MyImagessPageState extends State<MyImagessPage> {
  String miToken = "";
  Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  List<Widget> listadoImagesWidgets = <Widget>[];

  @override
  void initState() {
    super.initState();
    //obtenerListadoImages();

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        //sincronizarImagesBackend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    obtenerListadoImages();

    return Scaffold(
      backgroundColor: const Color(0xFFfdfded),
      appBar: GFAppBar(
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        leading: BtnConectid(),
        title: Text(
          " Mi Gallery",
          style: GoogleFonts.pacifico(fontSize: 20, color: Colors.white),
        ),
        actions: <Widget>[
          GFIconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              cerrarSesion();
            },
            type: GFButtonType.transparent,
          ),
        ],
      ),
      body: Center(
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: this.listadoImagesWidgets,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, CreateImagePage.ruta);
        },
        label: Text(
          "Añadir Imagen",
          style: GoogleFonts.pacifico(fontSize: 15, color: Colors.white),
        ),
        icon: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void obtenerListadoImages() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString('token');

    ImagesProviderApi ipapi = ImagesProviderApi();

    List<Widget> imagesCargados = <Widget>[];

    ImagesResponse irbd = await ipapi.obtenerListadoImages(token.toString());

    for (int i = 0; i < irbd.galleryList.length; i++) {
      print('Mi title ${irbd.galleryList.length}');
      var imgaeExist = '';
      var url = Uri.parse(
          'https://igalery.herokuapp.com/api/gallery/obtenerimagen/${irbd.galleryList[i].img.toString()}');
      var response = await http.get(url);
      print('Response body: ${response.body.toString()}');
      if (response.statusCode == 404) {
        imgaeExist = '';
      } else {
        imgaeExist =
            'https://igalery.herokuapp.com/api/gallery/obtenerimagen/${irbd.galleryList[i].img.toString()}';
        Widget wd = ContactCard(
          irbd.galleryList[i].title!,
          irbd.galleryList[i].description!,
          imgaeExist,
          irbd.galleryList[i].tipoRed!,
          () {
            _showMyDialog(
                irbd.galleryList[i].latitud!, irbd.galleryList[i].longitud!);
          },
        );
        imagesCargados.add(wd);
      }
    }

    setState(() {
      this.listadoImagesWidgets = imagesCargados;
      print(imagesCargados);
    });
  }

  void cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushNamed(context, MyLoginPage.ruta);
  }

  Future<void> _showMyDialog(String latitud, String longitud) async {
    Completer<GoogleMapController> _controller = Completer();
    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(double.parse(latitud), double.parse(longitud)),
      zoom: 14.4746,
    );
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.black87,
            title: Text('${latitud} | ${longitud}'),
          ),
          body: GoogleMap(
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        );
      },
    );
  }
}
