import 'package:app_contactos/home/estructura.dart';
import 'package:app_contactos/login/model/authResponse.dart';
import 'package:app_contactos/login/provider/authProvider.dart';
import 'package:app_contactos/register/estructura.dart';
import 'package:app_contactos/widgets/textFieldContainer.dart';
import 'package:flutter/material.dart';
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
        backgroundColor: const Color(0xFFfdfded),
        body: SingleChildScrollView(
          child: Container(
              child: Form(
            key: formKey,
            child: Container(
              padding: EdgeInsets.all(25.0),
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(height: 35),
                  SizedBox(
                    height: 220,
                    child: Image.asset(
                      'assets/img/home.png',
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Bienvenido a IGalery',
                    style: GoogleFonts.pacifico(
                        fontSize: 35, color: Colors.black87),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  obtenerCampoEmail(),
                  SizedBox(
                    height: 30,
                  ),
                  obtenerCampoContrasena(),
                  SizedBox(
                    height: 40,
                  ),
                  obtenerBotonIniciarSesion(),
                ],
              ),
            ),
          )),
        ));
  }

  TextFormField obtenerCampoEmail() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: "Correo electrónico",
        hintText: "correo@gmail.com",
        hintStyle: TextStyle(color: Colors.black87),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Colors.black87),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Colors.black87),
        ),
        prefixIcon: Icon(
          Icons.account_circle_rounded,
          color: Colors.black87,
        ),
      ),
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
    );
  }

  TextFormField obtenerCampoContrasena() {
    return TextFormField(
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Contraseña",
        hintStyle: TextStyle(color: Colors.black87),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Colors.black87),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          borderSide: BorderSide(color: Colors.black87),
        ),
        prefixIcon: Icon(
          Icons.password_outlined,
          color: Colors.black87,
        ),
      ),
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
    );
  }

  ElevatedButton obtenerBotonIniciarSesion() {
    return ElevatedButton(
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.white,
          primary: Colors.black87,
          onSurface: Colors.black87,
          elevation: 20,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(170, 60),
        ),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            validarToken(emailIngresado, contrasenaIngresada);
          }
        },
        child: Text(
          "Iniciar Sesión",
          style: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 17,
              ),
        ));
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
