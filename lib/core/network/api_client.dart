import 'dart:convert';
import 'package:http/http.dart' as http;

import '../errors/failures.dart';

/// API client for making HTTP requests
class ApiClient {
  final http.Client _client;
  final String baseUrl;

  ApiClient(this._client, {this.baseUrl = 'https://api.restaurant-pos.com'});

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw const ServerFailure(message: 'Network error occurred');
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw const ServerFailure(message: 'Network error occurred');
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      throw const ServerFailure(message: 'Network error occurred');
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await _client.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
      );

      return _handleResponse(response);
    } catch (e) {
      throw const ServerFailure(message: 'Network error occurred');
    }
  }

  /// Handle HTTP response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw ServerFailure(
        message: 'Server error: ${response.statusCode}',
        code: response.statusCode,
      );
    }
  }

  /// Get default headers
  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  /// Dispose the HTTP client
  void dispose() {
    _client.close();
  }
}
