import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
final GetIt getIt = GetIt.instance;
//Register models and all dependencies here;
void registerDependencies() {
  //REGISTER ALL YOUR SERVICES
  getIt.registerSingleton<Dio>(Dio());

}

//DEFINE YOUR SERVICES HERE
final dioProvider = getIt.get<Dio>();