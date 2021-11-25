import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class BtnConectid extends StatefulWidget {
  BtnConectid({Key? key}) : super(key: key);

  @override
  _BtnConectidState createState() => _BtnConectidState();
}

class _BtnConectidState extends State<BtnConectid> {
  @override
  void initState() {
    super.initState();
    //conect();
  }

  bool wifi = false;
  @override
  Widget build(BuildContext context) {
    conect();
    return Column(
      children: [
        if (wifi)
          FlatButton(
            child: Icon(
              Icons.wifi,
              color: Colors.white54,
            ),
            onPressed: () {},
          ),
        if (!wifi)
          FlatButton(
            child: Icon(
              Icons.mobile_friendly,
              color: Colors.white54,
            ),
            onPressed: () {},
          ),
      ],
    );
  }

  conect() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      wifi = false;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      wifi = true;
    }
  }
}
