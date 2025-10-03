import 'package:dio/dio.dart';

class DioNetworkClient{

  static final DioNetworkClient _instance = DioNetworkClient._internal();
  DioNetworkClient._internal(
    
  );
  factory DioNetworkClient() => _instance;

  final Dio dio = Dio(BaseOptions(
    baseUrl: '',
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ))..interceptors.add(LogInterceptor(responseBody: true, requestBody: true, requestHeader: true, responseHeader: true,request: true));
  
  Dio get client => dio;

}