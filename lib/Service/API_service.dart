import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      "https://tysnx3mi2s.us-east-1.awsapprunner.com";

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String selectedOption, // "Doctor" / "Patient"
  }) async {
    final url = Uri.parse("$baseUrl/api/users/login");

    final response = await http
        .post(
          url,
          headers: const {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "email": email,
            "password": password,
            "selectedOption": selectedOption, // keep "Doctor" if backend expects that
          }),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception("Login failed: ${response.statusCode} - ${response.body}");
  }
}
