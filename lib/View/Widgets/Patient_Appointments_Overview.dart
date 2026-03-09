import 'package:ehosptal_flutter_revamp/Service/API_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientAppointmentsOverview extends StatefulWidget {
  final Map<String, dynamic> patient;
  const PatientAppointmentsOverview({super.key, required this.patient});

  @override
  State<PatientAppointmentsOverview> createState() => _PatientAppointmentsOverviewState();
}

class _PatientAppointmentsOverviewState extends State<PatientAppointmentsOverview> {
  final ApiService _api = ApiService();

  bool loading = true;
  String? error;

  List<Map<String, dynamic>> appts = [];

  @override
  void initState() {
    super.initState();
    _fetchToday();
  }

  DateTime _startOfDayLocal(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDayLocal(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59, 999);

  Map<String, dynamic> _buildLoginData() {
    return {
      "type": "Patient",
      "id": widget.patient["id"],
      "name": widget.patient["Fname"] ?? widget.patient["FName"] ?? widget.patient["name"] ?? "Patient",
      "email": widget.patient["EmailId"] ?? widget.patient["email"] ?? "",
      "startInPage": "/patient/dashboard",
    };
  }

  Future<void> _fetchToday() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final now = DateTime.now();
      final start = _startOfDayLocal(now);
      final end = _endOfDayLocal(now);

      // React passes a real timezone string like "America/Toronto"
      const timezone = "America/Toronto";

      final result = await _api.patientMainPageGetCalendar(
        loginData: _buildLoginData(),
        start: start,
        end: end,
        timezone: timezone,
      );

      setState(() {
        appts = result;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  String _formatStart(dynamic start) {
    try {
      final dt = DateTime.parse(start.toString()).toLocal();
      return DateFormat("MMM d, h:mm a").format(dt);
    } catch (_) {
      return "Time unavailable";
    }
  }

  String _doctorName(Map<String, dynamic> item) {
    final doc = item["doctor"];
    if (doc is Map) {
      return (doc["name"] ?? doc["Fname"] ?? doc["FName"] ?? "Doctor").toString();
    }
    return "Doctor";
  }

  String _locationLabel(Map<String, dynamic> item) {
    final isVirtual = item["isVirtual"] == true || item["Virtual"] == true;
    if (isVirtual) return "Virtual";
    final loc = item["location"] ?? item["Location"] ?? item["clinic"] ?? item["Clinic"];
    if (loc != null && loc.toString().trim().isNotEmpty) return loc.toString();
    return "uOttawa Clinic";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            blurRadius: 30,
            offset: const Offset(0, 14),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : (error != null
              ? _errorBox()
              : _content()),
    );
  }

  Widget _errorBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Appointment Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text("Failed to load appointments:\n$error",
            style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _fetchToday,
          child: const Text("Retry"),
        ),
      ],
    );
  }

  Widget _content() {
    final top2 = appts.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Appointment Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),

        const Text("Upcoming Appointments",
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        if (top2.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("No upcoming appointments today."),
          )
        else
          ...top2.map((item) {
            final doctor = "Dr. ${_doctorName(item)}";
            final dateText = _formatStart(item["start"] ?? item["Start"]);
            final loc = _locationLabel(item);

            return _appointmentTile(
              doctorName: doctor,
              dateText: dateText,
              location: loc,
          );
          }),

        const SizedBox(height: 6),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Book New Appointments"),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text("View All Appointments  >"),
            ),
          ],
        ),

        const Divider(height: 26),

        const Text("Pending Referral / Task",
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        // Placeholder pending section that still looks good (no dummy data requested for apis; referrals/tasks endpoint not stable)
        // If you later want, we can wire /getReferralByPatientID here the same way.
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text("Pending items will appear here."),
        ),
      ],
    );
  }

  Widget _appointmentTile({required String doctorName, required String dateText, required String location}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7FB),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doctorName, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(dateText, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  const SizedBox(width: 14),
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.black54),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(location,
                        style: const TextStyle(color: Colors.black54, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton(onPressed: () {}, child: const Text("View Details")),
      ],
    ),
  );
}
}