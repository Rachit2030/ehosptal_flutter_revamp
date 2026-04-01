import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:ehosptal_flutter_revamp/Model/patient.dart';
import 'package:ehosptal_flutter_revamp/Model/message_models.dart';

// If the package name above ever errors, use this instead (relative import):
// import '../Model/patient.dart';

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
          body: jsonEncode({
            "doctorId": doctorId,
            "doctor_id": doctorId,
          }),
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

  // ------------------------------------------------------
  // ORCHESTRATOR
  // ------------------------------------------------------
  Future<String> orchestrate({
    required String id,
    required String message,
  }) async {
    final url = Uri.parse(
      "http://15.222.187.122/orchestrator/api/orchestrate",
    );

    const orchestratorTimeout = Duration(minutes: 5);

    final request = http.Request("POST", url);
    request.headers.addAll(_headers);
    request.body = jsonEncode({
      "id": id,
      "message": message,
    });

    final streamed = await request.send().timeout(orchestratorTimeout);
    final response = await http.Response.fromStream(streamed);

    _ensureSuccess(response, "orchestrate failed");
    return response.body;
  }

  Future<String> orchestratorChat({
    required String message,
  }) async {
    final url = Uri.parse(
      "http://15.222.187.122/orchestrator/api/chat",
    );

    const orchestratorTimeout = Duration(minutes: 5);

    final request = http.Request("POST", url);
    request.headers.addAll({
      "sec-ch-ua-platform": "\"Windows\"",
      "Referer": "",
      "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36",
      "sec-ch-ua":
          "\"Chromium\";v=\"146\", \"Not-A.Brand\";v=\"24\", \"Google Chrome\";v=\"146\"",
      "sec-ch-ua-mobile": "?0",
      "Content-Type": "application/json",
    });
    request.body = jsonEncode({
      "message": message,
    });

    final streamed = await request.send().timeout(orchestratorTimeout);
    final response = await http.Response.fromStream(streamed);

    _ensureSuccess(response, "orchestratorChat failed");
    return response.body;
  }
  // ------------------------------------------------------
  // MESSAGES
  // ------------------------------------------------------
  Future<Map<String, List<MessageConversation>>> getMessagesByTypeAndId({
  required dynamic userId,
  required String userType,
}) async {
  final url = Uri.parse("$baseUrl/api/users/getMessagesByTypeAndId");

  Future<http.Response> postPayload(Map<String, dynamic> payload) async {
    return http
        .post(
          url,
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(_timeout);
  }

  http.Response response = await postPayload({
    "user_id": userId,
    "user_type": userType,
  });

  if (response.statusCode < 200 || response.statusCode >= 300) {
    response = await postPayload({
      "doctorId": userId,
      "userType": userType,
    });
  }

  if (response.statusCode < 200 || response.statusCode >= 300) {
    response = await postPayload({
      "user_id": userId,
      "userType": userType,
    });
  }

  _ensureSuccess(response, "getMessagesByTypeAndId failed");

  final decoded = _decodeJson(response.body);

  if (decoded is! Map<String, dynamic>) {
    throw Exception("Unexpected messages response: ${response.body}");
  }

  final rawResult = decoded["result"];
  if (rawResult is! Map<String, dynamic>) {
    throw Exception("Unexpected messages result format: ${response.body}");
  }

  final result = <String, List<MessageConversation>>{};
  rawResult.forEach((category, rawList) {
    if (rawList is List) {
      result[category] = rawList
          .whereType<Map>()
          .map(
            (e) => MessageConversation.fromJson(
              Map<String, dynamic>.from(e),
              category: category,
            ),
          )
          .toList();
    } else {
      result[category] = const [];
    }
  });

  return result;
}
  Future<int> messageSend({
    required Map<String, dynamic> payload,
  }) async {
    final url = Uri.parse("$baseUrl/api/users/MessageSend");

    final response = await http
        .post(
          url,
          headers: _headers,
          body: jsonEncode(payload),
        )
        .timeout(_timeout);

    _ensureSuccess(response, "MessageSend failed");

    final decoded = _decodeJson(response.body);

    if (decoded is int) return decoded;
    if (decoded is num) return decoded.toInt();

    if (decoded is Map<String, dynamic>) {
      final value = decoded["result"] ?? decoded["success"] ?? decoded["data"];
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
    }

    if (decoded is String) return int.tryParse(decoded) ?? 0;

    return 0;
  }

  Future<void> messageReadStatusUpdate({
    required List<int> messageIds,
  }) async {
    if (messageIds.isEmpty) return;

    final url = Uri.parse("$baseUrl/api/users/MessageReadStatusUpdate");

    final response = await http
        .post(
          url,
          headers: _headers,
          body: jsonEncode({
            "messageIds": messageIds,
          }),
        )
        .timeout(_timeout);

    _ensureSuccess(response, "MessageReadStatusUpdate failed");
  }

  Future<List<Map<String, dynamic>>> findClinicStaffsByDoctorId({
    required dynamic doctorId,
  }) async {
    final url = Uri.parse("$baseUrl/findClinicStaffsByDoctorId");

    final response = await http
        .post(
          url,
          headers: _headers,
          body: jsonEncode({"doctorId": doctorId}),
        )
        .timeout(_timeout);

    _ensureSuccess(response, "findClinicStaffsByDoctorId failed");

    final decoded = _decodeJson(response.body);

    if (decoded is List) {
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    if (decoded is Map<String, dynamic>) {
      final list = decoded["result"] ?? decoded["data"];
      if (list is List) {
        return list
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    }

    throw Exception("Unexpected clinic staff response: ${response.body}");
  }

}
