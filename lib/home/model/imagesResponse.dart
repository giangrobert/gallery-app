class ImagesResponse {
  List<ImageModel> galleryList = <ImageModel>[];

  ImagesResponse.fromAPI(Map jsonImagesResponse) {
    for (int i = 0; i < jsonImagesResponse["galleryList"].length; i++) {
      ImageModel cm = ImageModel(jsonImagesResponse["galleryList"][i]);
      this.galleryList.add(cm);
    }
  }

  ImagesResponse.fromDB(List<Map> resultadosQuery) {
    for (int i = 0; i < resultadosQuery.length; i++) {
      var result = resultadosQuery[i];
      ImageModel cm = ImageModel(result);
      this.galleryList.add(cm);
    }
  }

  ImagesResponse.vacio() {
    this.galleryList = List.empty();
  }
}

class ImageModel {
  String id = "";
  String title = "";
  String description = "";
  String img = "";

  ImageModel(Map jsonImagesResponse) {
    this.id = jsonImagesResponse["_id"];
    this.title = jsonImagesResponse["title"];
    this.description = jsonImagesResponse["description"];
    this.img = jsonImagesResponse["img"];
  }

  ImageModel.fromValues(String title, String description, String img) {
    this.id = "";
    this.title = title;
    this.description = description;
    this.img = img;
  }
}
