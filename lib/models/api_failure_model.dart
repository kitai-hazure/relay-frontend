class ApiFailureModel {
  ApiFailureModel([
    this.message = "Ooops Something Went Wrong",
    this.statusCode = 200,
  ]);
  String message;
  int statusCode;
}
