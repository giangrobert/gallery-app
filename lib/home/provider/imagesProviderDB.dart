import 'dart:io';

import 'package:app_contactos/home/model/imagesResponse.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ImagesProviderDb {
  Database? db;

  ImagesProviderDb();

  init() async {
    Directory applicationDirectory = await getApplicationDocumentsDirectory();
    var fullPath = join(applicationDirectory.path, "Images.db");
    this.db =
        await openDatabase(fullPath, onCreate: (Database new2Db, int version) {
      return new2Db.execute(
          """
          CREATE TABLE Images(
            _id TEXT,
            title TEXT,
            description TEXT,
            img TEXT
          );
            """);
    }, version: 2);
  }

  agregarImage(ImageModel im) async {
    await this.db!.rawInsert(
        """
      INSERT INTO Images (_id, title, description, img)
      VALUES (?,?,?,?)
      """,
        [im.id, im.title, im.description, im.img]);
  }

  eliminarImages() async {
    await this.db!.rawDelete("""DELETE FROM Images""");
  }

  Future<ImagesResponse> obtenerImages() async {
    var results =
        await this.db!.rawQuery("SELECT * FROM Images ORDER BY title");
    // var results = await this.db!.query("Contactos", where: "_id", whereArgs: ["1"] );

    ImagesResponse response = ImagesResponse.fromDB(results);

    return response;
  }

  Future<ImagesResponse> obtenerImagesPorId(String id) async {
    var results =
        await this.db!.rawQuery("SELECT * FROM Images WHERE _id = ? ", [id]);
    ImagesResponse response = ImagesResponse.fromDB(results);
    return response;
  }

  Future<ImagesResponse> obtenerImagesPendientesPorSincronizar() async {
    var results =
        await this.db!.rawQuery("SELECT * FROM Images WHERE _id = '' ");
    ImagesResponse response = ImagesResponse.fromDB(results);
    return response;
  }

  Future<void> eliminarImagesSincronizados() async {
    var results =
        await this.db!.rawDelete("DELETE FROM Images WHERE _id = '' ");
  }
}
