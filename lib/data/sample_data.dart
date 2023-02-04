import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:relay/models/api_failure_model.dart';

class SampleService{
  SampleService(this._dio);
  final Dio _dio;
  //Change to needed datatype and use graphql query;
  // Future<Either<CourseCategories, ApiFailureModel>> fetchCourseCategories() async {
  //   try {
  //     final response = await _dio.get(ZuEndPoints.courseCategoryUrl);
    //   QueryResult result = await client.value.mutate(MutationOptions(
    //   document: gql(DashBoardQueries.cfGraphs()),
    //   variables: {
    //     "input": {
    //       "userId" : id
    //     }
    //   }
    // ));
  //     if (response.statusCode == 200) {
  //       final data =
  //           CourseCategories.fromJson(response.data as Map<String, dynamic>);
  //       return left(data);
  //     }
  //     return right(
  //       ApiFailureModel(),
  //     );
  //   } on SocketException {
  //     return right(
  //       ApiFailureModel(
  //         "Internet Unavailable",
  //       ),
  //     );
  //   }
  // }
}