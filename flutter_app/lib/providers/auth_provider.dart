import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _token;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  AuthProvider() {
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _userEmail = prefs.getString('userEmail');
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<String?> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("https://greenmindaibackend.vercel.app/register"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) return null; // Success
      final data = json.decode(response.body);
      return data['error'] ?? "Registration failed";
    } catch (e) {
      return "Connection error: $e";
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("https://greenmindaibackend.vercel.app/login"),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"email": email, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _isLoggedIn = true;
        _userEmail = data['email'];
        _token = data['access_token'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userEmail', _userEmail!);
        await prefs.setString('token', _token!);
        
        notifyListeners();
        return null; // Success
      }
      final data = json.decode(response.body);
      return data['error'] ?? "Login failed";
    } catch (e) {
      return "Connection error: $e";
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    _userEmail = null;
    _token = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    notifyListeners();
  }
}
