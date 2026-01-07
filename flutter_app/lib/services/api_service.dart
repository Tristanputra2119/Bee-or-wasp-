import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/prediction_result.dart';
import '../utils/constants.dart';

class ApiService {
  final String baseUrl;
  
  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConstants.baseUrl;
  
  /// Check if the API is healthy and model is loaded
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConstants.healthEndpoint}'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['status'] == 'ok' && data['model_loaded'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// Predict the class of an image from bytes
  Future<PredictionResult> predictFromBytes(Uint8List imageBytes, String filename) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl${AppConstants.predictEndpoint}'),
      );
      
      // Determine content type from filename
      String mimeType = 'image/jpeg';
      if (filename.toLowerCase().endsWith('.png')) {
        mimeType = 'image/png';
      } else if (filename.toLowerCase().endsWith('.webp')) {
        mimeType = 'image/webp';
      } else if (filename.toLowerCase().endsWith('.gif')) {
        mimeType = 'image/gif';
      }
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: filename,
          contentType: MediaType.parse(mimeType),
        ),
      );
      
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PredictionResult.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw ApiException(
          message: errorData['detail'] ?? 'Prediction failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        message: 'Connection failed: ${e.toString()}',
        statusCode: 0,
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  
  ApiException({
    required this.message,
    required this.statusCode,
  });
  
  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}
