import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class ContactCard extends StatelessWidget {
  String imageTitle = "";
  String imageDescription = "";
  String imageImg = "";

  ContactCard(this.imageTitle, this.imageDescription, this.imageImg);

  @override
  Widget build(BuildContext context) {
    return /*Card(
      child: Column(
        children: [
          Text(this.contactName,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold)),
          Text(this.contactPhone,
              style: TextStyle(
                color: Colors.black26,
                fontSize: 22.0,
              )),
          Text(this.contactEmail,
              style: TextStyle(
                color: Colors.black26,
                fontSize: 22.0,
              )),
        ],
      ),
    )*/
        GFCard(
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
      buttonBar: GFButtonBar(
        children: <Widget>[
          Image.network(imageImg),
        ],
      ),
    );
  }
}
