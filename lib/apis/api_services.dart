import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_app/utils/token_storage.dart';

class ApiService {
  // ✅ Base API URL
  static const String baseUrl = "http://192.168.10.12:8000/api/";

  // ================= GET =================
  /// Makes a GET request to [endpoint] and returns parsed JSON.
  /// Can return Map<String, dynamic> or List<dynamic>.
  static Future<dynamic> get(String endpoint) async {
    final token = await TokenStorage.getToken();

    try {
      final response = await http.get(
        Uri.parse(baseUrl + endpoint),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "GET request failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      throw Exception("GET request error: $e");
    }
  }

  // ================= POST =================
  /// Makes a POST request to [endpoint] with JSON [body].
  /// Returns parsed JSON.
  static Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final token = await TokenStorage.getToken();

    try {
      final response = await http.post(
        Uri.parse(baseUrl + endpoint),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "POST request failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      throw Exception("POST request error: $e");
    }
  }

  // ================= UPLOAD PROFILE =================
  /// Uploads profile with optional [image] and additional [fields].
  static Future<dynamic> uploadProfile(
      Map<String, String> fields, File? image) async {
    final token = await TokenStorage.getToken();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(baseUrl + "profile/update"),
      );

      request.headers['Authorization'] = "Bearer $token";
      request.fields.addAll(fields);

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            image.path,
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            "Profile upload failed [${response.statusCode}]: ${response.body}");
      }
    } catch (e) {
      throw Exception("Profile upload error: $e");
    }
  }
}
