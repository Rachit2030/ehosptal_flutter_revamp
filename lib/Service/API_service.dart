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

  Future<List<Map<String, dynamic>>> getDoctorCalendar({
  required Map<String, dynamic> loginData,
  required DateTime start,
  required DateTime end,
}) async {
  print(start);
  final url = Uri.parse("$baseUrl/api/appointments/doctorGetCalendar");

  final payload = {
    "loginData": loginData,
    "start": start.toUtc().toIso8601String(),
    "end": end.toUtc().toIso8601String(),
  };

  final res = await http.post(
    url,
    headers: const {
      "Content-Type": "application/json",
      "Accept": "application/json",
    },
    body: jsonEncode(payload),
  );

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception("doctorGetCalendar failed: ${res.statusCode} ${res.body}");
  }

  final decoded = jsonDecode(res.body);
  print(decoded.toString());
  if (decoded is Map<String, dynamic>) {
    final result = decoded["result"];
    if (result is List) {
      return result.cast<Map<String, dynamic>>();
    }
    throw Exception("Unexpected response: missing 'result' list");
  }

  throw Exception("Unexpected response format");
}
}
