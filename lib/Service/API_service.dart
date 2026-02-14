import 'dart:convert';
import 'package:http/http.dart' as http;

// ✅ Correct path based on your screenshot:
import 'package:ehosptal_flutter_revamp/model/patient.dart';

// If the package name above ever errors, use this instead (relative import):
// import '../model/patient.dart';

class ApiService {
  static const String baseUrl =
      "https://tysnx3mi2s.us-east-1.awsapprunner.com";

  static const Duration _timeout = Duration(seconds: 20);

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  // -----------------------------
  // LOGIN
  // -----------------------------
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String selectedOption, // "Doctor" / "Patient"
  }) async {
    final url = Uri.parse("$baseUrl/api/users/login");

    final response = await http
        .post(
          url,
          headers: _headers,
          body: jsonEncode({
            "email": email,
            "password": password,
            "selectedOption": selectedOption,
          }),
        )
        .timeout(_timeout);

    _ensureSuccess(response, "Login failed");

    final decoded = _decodeJson(response.body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception("Login failed: unexpected response format: ${response.body}");
  }

  // ------------------------------------------------------
  // DOCTOR PATIENT LIST (same as website)
  // POST /DoctorPatientsAuthorized body: { doctorId }
  // ------------------------------------------------------
  Future<List<Patient>> getDoctorPatientsAuthorized({
    required dynamic doctorId,
  }) async {
    if (doctorId == null) {
      throw Exception("doctorId is null. Check your login response key.");
    }

    final url = Uri.parse("$baseUrl/DoctorPatientsAuthorized");

    final response = await http
        .post(
          url,
          headers: _headers,
          body: jsonEncode({"doctorId": doctorId}),
        )
        .timeout(_timeout);

    _ensureSuccess(response, "getDoctorPatientsAuthorized failed");

    final decoded = _decodeJson(response.body);
    print(decoded.toString());
    // Expected: a list of patients
    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Patient.fromJson)
          .toList();
    }
    

    // Fallback: if backend wraps list inside { data: [...] } or { result: [...] }
    if (decoded is Map<String, dynamic>) {
      final list = decoded["result"] ?? decoded["data"];
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map(Patient.fromJson)
            .toList();
      }
    }

    throw Exception("Unexpected response format: ${response.body}");
  }

  // -----------------------------
  // HELPERS
  // -----------------------------
  void _ensureSuccess(http.Response response, String message) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    throw Exception("$message: ${response.statusCode} - ${response.body}");
  }

  dynamic _decodeJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      throw Exception("Failed to decode JSON. Raw response: $body");
    }
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
