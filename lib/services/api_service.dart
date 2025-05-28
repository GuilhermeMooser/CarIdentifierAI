import 'package:dio/dio.dart';
import 'dart:io';
import '../models/detection_result.dart';

import 'package:dio/dio.dart';
import 'dart:io';
import '../models/detection_result.dart';

class ApiService {
  late final Dio _dio;
  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String baseUrl = 'http://192.168.1.7:8000';

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ));
  }

  Future<ApiResponse> detectCars(File imageFile) async {
    try {
      // Validações locais
      if (!await imageFile.exists()) {
        throw Exception('Arquivo de imagem não encontrado');
      }

      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) { // 10MB
        throw Exception('Arquivo muito grande (máximo 10MB)');
      }

      // Prepara multipart
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: 'image.jpg',
        ),
      });

      // Faz a requisição
      final response = await _dio.post(
        '/detect',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      return ApiResponse.fromJson(response.data);
    } on DioException catch (e) {
      String errorMessage = 'Erro de conexão';

      if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Timeout de conexão';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Timeout de resposta';
      } else if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? 'Erro do servidor';
      }

      throw Exception(errorMessage);
    } catch (e) {
      throw Exception('Erro inesperado: ${e.toString()}');
    }
  }

  Future<bool> checkConnection() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}