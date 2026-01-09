import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_app/utils/token_storage.dart';

class ApiService {
  static const String baseUrl = "http://192.168.10.8:8000/api/";

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    final token = await TokenStorage.getToken();
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
      throw Exception("Failed request (${response.statusCode})");
    }
  }

  // POST request
  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final token = await TokenStorage.getToken();
    final response = await http.post(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed request (${response.statusCode})");
    }
  }

  // Multipart POST for uploading profile image
  static Future<Map<String, dynamic>> uploadProfile(Map<String, String> fields, File? image) async {
    final token = await TokenStorage.getToken();
    final request = http.MultipartRequest('POST', Uri.parse(baseUrl + "profile/update"));
    request.headers['Authorization'] = "Bearer $token";

    // Add fields
    request.fields.addAll(fields);

    // Add image if exists
    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_photo', image.path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update profile (${response.statusCode})");
    }
  }
}
