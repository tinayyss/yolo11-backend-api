import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Gamit ang IP mula sa screenshot mo
  static const String baseUrl = "https://yolo11-api.onrender.com";

  // --- AUTH OPERATIONS ---
  static Future<bool> register(String name, String email, String user, String pass) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/auth/register'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"name": name, "email": email, "username": user, "password": pass}));
      return res.statusCode == 201;
    } catch (e) { return false; }
  }

  static Future<bool> login(String user, String pass) async {
    try {
      final res = await http.post(Uri.parse('$baseUrl/auth/login'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"username": user, "password": pass}));
      if (res.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", jsonDecode(res.body)["accessToken"]);
        return true;
      }
      return false;
    } catch (e) { return false; }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token") != null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  // --- DETECTION CRUD OPERATIONS ---

  // [READ]
  static Future<List<dynamic>> getDetections() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/detections'));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (e) { print(e); }
    return [];
  }

  // [UPDATE]
  static Future<bool> updateStatus(int id) async {
    try {
      final res = await http.put(Uri.parse('$baseUrl/detections/$id'));
      return res.statusCode == 200;
    } catch (e) { return false; }
  }

  // [DELETE]
  static Future<bool> deleteDetection(int id) async {
    try {
      final res = await http.delete(Uri.parse('$baseUrl/detections/$id'));
      return res.statusCode == 200;
    } catch (e) { return false; }
  }
}