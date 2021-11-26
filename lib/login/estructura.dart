import 'package:app_contactos/home/estructura.dart';
import 'package:app_contactos/login/model/authResponse.dart';
import 'package:app_contactos/login/provider/authProvider.dart';
import 'package:app_contactos/register/estructura.dart';
import 'package:app_contactos/widgets/circles.dart';
import 'package:app_contactos/widgets/textFieldContainer.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button_bar.dart';
import 'package:getwidget/components/card/gf_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyLoginPage extends StatefulWidget {
  static String ruta = "/";

  @override
  State<StatefulWidget> createState() {
    return _MyLoginPageState();
  }
}

class _MyLoginPageState extends State<MyLoginPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String emailIngresado = "";
  String contrasenaIngresada = "";

  @override
  Widget build(BuildContext context) {
    validarSesion();
    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
          child: Form(
        key: formKey,
        child: Container(
          padding: EdgeInsets.all(25.0),
          alignment: Alignment.center,
          child: Column(
            children: [
              SizedBox(height: 100),
              Image.network(
                'https://icons-for-free.com/iconfiles/png/512/Gallery-1320568041658802818.png',
                width: 150,
              ),
              SizedBox(height: 20),
              Text(
                'Bienvenido a IGalery',
                style:
                    GoogleFonts.pacifico(fontSize: 30, color: Colors.black87),
              ),
              obtenerCampoEmail(),
              obtenerCampoContrasena(),
              obtenerBotonIniciarSesion(),
              Container(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Text("¿Eres nuevo?"),
                    GestureDetector(
                        child: Text(
                          "Regístrate",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(context, MyRegisterPage.ruta);
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
      )),
    ));
  }

  TexfieldContainer obtenerCampoEmail() {
    return TexfieldContainer(
      child: TextFormField(
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
            labelText: "Correo electrónico", hintText: "john.doe@mail.com"),
        validator: (value) {
          String patron = r'^[^@]+@[^@]+\.[^@]+$';
          RegExp regExp = new RegExp(patron);
          if (regExp.hasMatch(value!)) {
            return null;
          } else {
            return "El email no es válido";
          }
        },
        onSaved: (value) {
          emailIngresado = value!;
        },
      ),
    );
  }

  TexfieldContainer obtenerCampoContrasena() {
    return TexfieldContainer(
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(labelText: "Contraseña"),
        validator: (value) {
          if (value!.length > 5) {
            return null;
          } else {
            return "La contraseña no cumple requisitos mínimos de seguridad";
          }
        },
        onSaved: (value) {
          contrasenaIngresada = value!;
        },
      ),
    );
  }

  ElevatedButton obtenerBotonIniciarSesion() {
    return ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            validarToken(emailIngresado, contrasenaIngresada);
          }
        },
        child: Text("Iniciar Sesión"));
  }

  void validarToken(String email, String contrasena) async {
    AuthProvider ap = AuthProvider();
    AuthResponse ar =
        await ap.obtenerToken(emailIngresado, contrasenaIngresada);

    if (ar.message != "Usuario autenticado") {
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', ar.token!);

      formKey.currentState!.reset();

      Navigator.pushNamed(context, MyImagessPage.ruta);
    }
  }

  validarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = await prefs.getString('token');

    bool existeToken = token == null ? false : true;

    if (existeToken) {
      Navigator.pushNamed(context, MyImagessPage.ruta);
    }
  }
}
