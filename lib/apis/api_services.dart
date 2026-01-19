import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:my_app/utils/token_storage.dart';

class ApiService {
  static const String baseUrl = "http://192.168.10.51:8000/api/";

  // ================= GET =================
  static Future<dynamic> get(String endpoint) async {
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
    }

    throw Exception(
        "GET failed [${response.statusCode}]: ${response.body}");
  }

  // ================= POST =================
  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> body) async {
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
        "POST failed [${response.statusCode}]: ${response.body}");
  }

  // ================= PUT =================
  static Future<dynamic> put(
      String endpoint, Map<String, dynamic> body) async {
    final token = await TokenStorage.getToken();

    final response = await http.put(
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
    }

    throw Exception(
        "PUT failed [${response.statusCode}]: ${response.body}");
  }

  // ================= DELETE =================
  static Future<dynamic> delete(String endpoint) async {
    final token = await TokenStorage.getToken();

    final response = await http.delete(
      Uri.parse(baseUrl + endpoint),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      return {"success": true};
    }

    throw Exception(
        "DELETE failed [${response.statusCode}]: ${response.body}");
  }

  // ================= UPLOAD PROFILE =================
  static Future<dynamic> uploadProfile(
      Map<String, String> fields, File? image) async {
    final token = await TokenStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse(baseUrl + "profile/update"),
    );

    request.headers['Authorization'] = "Bearer $token";
    request.fields.addAll(fields);

    if (image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_photo', image.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }

    throw Exception(
        "Profile upload failed [${response.statusCode}]: ${response.body}");
  }
}
