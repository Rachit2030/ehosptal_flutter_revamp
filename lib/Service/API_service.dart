import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ehosptal_flutter_revamp/model/patient.dart';

class ApiService {
  static const String baseUrl =
      "https://tysnx3mi2s.us-east-1.awsapprunner.com";

  static const Duration _timeout = Duration(seconds: 20);

  static const Map<String, String> _headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/login");

    final response = await http
        .post(
          url,
          headers: _headers,
          body: jsonEncode({
            "email": email,
            "password": password,
            "selectedOption": role,
          }),
        )
        .timeout(_timeout);

    _ensureSuccess(response, "Login failed");

    final decoded = _decodeJson(response.body);
    if (decoded is Map<String, dynamic>) return decoded;

    throw Exception("Login failed: unexpected response format: ${response.body}");
  }

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

    if (decoded is List) {
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Patient.fromJson)
          .toList();
    }

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
      headers: _headers,
      body: jsonEncode(payload),
    ).timeout(_timeout);

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

  Future<List<Map<String, dynamic>>> patientMainPageGetCalendar({
    required Map<String, dynamic> loginData,
    required DateTime start,
    required DateTime end,
    required String timezone,
  }) async {
    final url =
        Uri.parse("$baseUrl/api/appointments/patientMainPageGetCalendar");

    final payload = {
      "loginData": loginData,
      "start": start.toUtc().toIso8601String(),
      "end": end.toUtc().toIso8601String(),
      "timezone": timezone,
    };

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode(payload),
    ).timeout(_timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "patientMainPageGetCalendar failed: ${res.statusCode} ${res.body}",
      );
    }

    final decoded = jsonDecode(res.body);

    if (decoded is Map<String, dynamic>) {
      if (decoded["status"] != "OK") {
        throw Exception(
          "patientMainPageGetCalendar status: ${decoded["status"]}",
        );
      }

      final result = decoded["result"];
      if (result is List) {
        return result.cast<Map<String, dynamic>>();
      }
    }

    throw Exception("Unexpected response format: ${res.body}");
  }

  Future<Map<String, dynamic>> getPatientPortalInfoById({
    required dynamic patientId,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/getPatientPortalInfoById");

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"patientId": patientId}),
    ).timeout(_timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "getPatientPortalInfoById failed: ${res.statusCode} ${res.body}",
      );
    }

    final decoded = jsonDecode(res.body);

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception("Unexpected response format: ${res.body}");
  }

  Future<dynamic> getPrescriptionsByPatientId({
    required dynamic patientId,
  }) async {
    final url = Uri.parse("$baseUrl/getPrescriptionsByPatientId");

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"patientId": patientId}),
    ).timeout(_timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "getPrescriptionsByPatientId failed: ${res.statusCode} ${res.body}",
      );
    }

    return jsonDecode(res.body);
  }

  Future<List<dynamic>> imageRetrieveByPatientId({
    required dynamic patientId,
    required String recordType,
  }) async {
    final url = Uri.parse("$baseUrl/imageRetrieveByPatientId");

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({
        "patientId": patientId,
        "recordType": recordType,
      }),
    ).timeout(_timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "imageRetrieveByPatientId failed: ${res.statusCode} ${res.body}",
      );
    }

    final decoded = jsonDecode(res.body);

    if (decoded is Map && decoded["success"] is List) {
      return decoded["success"];
    }

    if (decoded is List) {
      return decoded;
    }

    return [];
  }

  Future<dynamic> getBloodtestByPatientId({
    required dynamic patientId,
  }) async {
    final url = Uri.parse("$baseUrl/getBloodtestByPatientId");

    final res = await http.post(
      url,
      headers: _headers,
      body: jsonEncode({"patientId": patientId}),
    ).timeout(_timeout);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        "getBloodtestByPatientId failed: ${res.statusCode} ${res.body}",
      );
    }

    return jsonDecode(res.body);
  }

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
}