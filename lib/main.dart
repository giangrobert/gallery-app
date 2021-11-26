import 'package:app_contactos/createimage/estructura.dart';
import 'package:app_contactos/home/estructura.dart';
import 'package:app_contactos/login/estructura.dart';
import 'package:flutter/material.dart';

void main() {
  //Firebase.initializeApp();
  runApp(MaterialApp(
    routes: {
      MyLoginPage.ruta: (BuildContext context) => MyLoginPage(),
      MyImagessPage.ruta: (BuildContext context) => MyImagessPage(),
      CreateImagePage.ruta: (BuildContext context) => CreateImagePage(),
    },
    debugShowCheckedModeBanner: false,
  ));
}
