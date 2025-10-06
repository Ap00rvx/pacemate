import 'package:dio/dio.dart';

class DioNetworkClient {
  static final DioNetworkClient _instance = DioNetworkClient._internal();
  DioNetworkClient._internal();
  factory DioNetworkClient() => _instance;

  final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: 'https://pacemate.apurvabraj.space/',
            connectTimeout: Duration(seconds: 60),
            receiveTimeout: Duration(seconds: 60),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            responseBody: true,
            requestBody: true,
            requestHeader: true,
            responseHeader: true,
            request: true,
          ),
        );

  Dio get client => dio;
}
