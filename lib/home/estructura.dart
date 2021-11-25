import 'dart:async';

import 'package:app_contactos/createimage/estructura.dart';
import 'package:app_contactos/home/imageCard.dart';
import 'package:app_contactos/home/model/imagesResponse.dart';

import 'package:app_contactos/home/provider/imagesProviderAPI.dart';
import 'package:app_contactos/home/provider/imagesProviderDB.dart';
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

    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        sincronizarImagesBackend();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    obtenerListadoImages();

    return Scaffold(
      appBar: GFAppBar(
        backgroundColor: Colors.black87,
        automaticallyImplyLeading: false,
        leading: GFIconButton(
          icon: Icon(
            Icons.message,
            color: Colors.white,
          ),
          onPressed: () {},
          type: GFButtonType.transparent,
        ),
        title: Text("Mi Gallery"),
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
          child: ListView(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: this.listadoImagesWidgets,
        ),
      ])),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, CreateImagePage.ruta);
        },
        label: Text("Crear Imagen"),
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
    ImagesProviderDb ipdb = ImagesProviderDb();
    await ipdb.init();

    ConnectivityResult connectiivityResult =
        await _connectivity.checkConnectivity();

    if (connectiivityResult != ConnectivityResult.none) {
      ImagesResponse irapi = await ipapi.obtenerListadoImages(token.toString());

      for (int i = 0; i < irapi.galleryList.length; i++) {
        ImagesResponse temp =
            await ipdb.obtenerImagesPorId(irapi.galleryList[i].id);
        if (temp.galleryList.length == 0) {
          ipdb.agregarImage(irapi.galleryList[i]);
        }
      }
    }

    ImagesResponse irbd = await ipdb.obtenerImages();

    List<Widget> imagesCargados = <Widget>[];

    for (int i = 0; i < irbd.galleryList.length; i++) {
      Widget wd = ContactCard(irbd.galleryList[i].title,
          irbd.galleryList[i].img, irbd.galleryList[i].img);

      imagesCargados.add(wd);
    }

    setState(() {
      this.listadoImagesWidgets = imagesCargados;
    });
  }

  void cerrarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    Navigator.pushNamed(context, MyLoginPage.ruta);
  }

  void sincronizarImagesBackend() async {
    print("Se inicia la sincronizacion");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = await prefs.getString('token');

    ImagesProviderDb ipdb = ImagesProviderDb();
    await ipdb.init();

    ImagesResponse ir = await ipdb.obtenerImagesPendientesPorSincronizar();

    ImagesProviderApi ipapi = ImagesProviderApi();

    for (int i = 0; i < ir.galleryList.length; i++) {
      await ipapi.crearImage(token!, ir.galleryList[i]);
    }

    await ipdb.eliminarImagesSincronizados();

    print("Se termina la sincronizacion");
  }
}
