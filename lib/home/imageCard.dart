import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class ContactCard extends StatelessWidget {
  String imageTitle = "";
  String imageDescription = "";
  String imageImg = "";
  String tiporedt = "";
  void Function()? onPressed;

  ContactCard(this.imageTitle, this.imageDescription, this.imageImg,
      this.tiporedt, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GFCard(
      boxFit: BoxFit.cover,
      title: GFListTile(
        avatar: GFAvatar(
          backgroundImage: AssetImage('assets/img/avatar-icon-images-4.jpg'),
        ),
        title: Text(
          imageTitle,
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
        ),
        subTitle: Text(
          imageDescription,
          style: TextStyle(fontSize: 15.0),
        ),
      ),
      content: Column(
        children: [
          Image.network(imageImg),
        ],
      ),
      buttonBar: GFButtonBar(
        children: <Widget>[
          Row(
            children: [
              GFButton(
                onPressed: onPressed,
                text: "Ubicación",
                icon: Icon(
                  Icons.remove_red_eye,
                  color: Colors.white,
                ),
                shape: GFButtonShape.pills,
                color: Colors.black,
              ),
              SizedBox(width: 12.0),
              Text(tiporedt),
            ],
          ),
        ],
      ),
    );
  }
}
