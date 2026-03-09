import 'package:ehosptal_flutter_revamp/Service/API_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PatientHealthSummary extends StatefulWidget {
  final Map<String, dynamic> patient;
  const PatientHealthSummary({super.key, required this.patient});

  @override
  State<PatientHealthSummary> createState() => _PatientHealthSummaryState();
}

class _PatientHealthSummaryState extends State<PatientHealthSummary> {
  final ApiService _api = ApiService();

  bool loading = true;
  String? error;

  List<Map<String, dynamic>> meds = [];
  List<Map<String, dynamic>> recentRecords = [];

  @override
  void initState() {
    super.initState();
    _fetchHealth();
  }

  dynamic get _patientId => widget.patient["id"] ?? widget.patient["patientId"];

  Future<void> _fetchHealth() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (_patientId == null) throw Exception("Missing patient id");

      // 1) prescriptions
      final pres = await _api.getPrescriptionsByPatientId(patientId: _patientId);

      // normalize prescriptions into a List<Map>
      final List<Map<String, dynamic>> presList = [];
      if (pres is List) {
        for (final x in pres) {
          if (x is Map<String, dynamic>) presList.add(x);
          if (x is Map) presList.add(Map<String, dynamic>.from(x));
        }
      } else if (pres is Map && pres["success"] is List) {
        for (final x in pres["success"]) {
          if (x is Map) presList.add(Map<String, dynamic>.from(x));
        }
      }

      // 2) imaging records: MRI brain + X-ray chest
      final mri = await _api.imageRetrieveByPatientId(
        patientId: _patientId,
        recordType: "MRI_Brain",
      );

      final xray = await _api.imageRetrieveByPatientId(
        patientId: _patientId,
        recordType: "X-Ray_Chest",
      );

      // 3) blood tests
      final blood = await _api.getBloodtestByPatientId(patientId: _patientId);

      // Build a simple "Recent Medical Records" list (take most recent from each bucket)
      final List<Map<String, dynamic>> records = [];

      Map<String, dynamic>? latestFromList(List<dynamic> items) {
        final parsed = items
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        if (parsed.isEmpty) return null;

        parsed.sort((a, b) {
          final ad = DateTime.tryParse((a["RecordDate"] ?? a["record_time"] ?? a["date"] ?? "").toString());
          final bd = DateTime.tryParse((b["RecordDate"] ?? b["record_time"] ?? b["date"] ?? "").toString());
          if (ad == null && bd == null) return 0;
          if (ad == null) return 1;
          if (bd == null) return -1;
          return bd.compareTo(ad);
        });

        return parsed.first;
      }

      final latestMri = latestFromList(mri);
      final latestXray = latestFromList(xray);

      // blood may be list or map
      Map<String, dynamic>? latestBlood;
      if (blood is List) {
        latestBlood = latestFromList(blood);
      } else if (blood is Map && blood["success"] is List) {
        latestBlood = latestFromList(blood["success"]);
      }

      if (latestMri != null) records.add({"type": "MRI", "body": "Brain", "raw": latestMri});
      if (latestXray != null) records.add({"type": "X-ray", "body": "Chest", "raw": latestXray});
      if (latestBlood != null) records.add({"type": "Blood Test", "body": "General", "raw": latestBlood});

      setState(() {
        meds = presList;
        recentRecords = records;
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  String _formatRecordDate(Map<String, dynamic> raw) {
    final s = (raw["RecordDate"] ?? raw["record_time"] ?? raw["date"] ?? "").toString();
    final dt = DateTime.tryParse(s);
    if (dt == null) return "—";
    return DateFormat("MMM d, yyyy").format(dt.toLocal());
    }

  String _medName(Map<String, dynamic> m) {
  final candidates = [
    m["MedicationName"],
    m["Medication"],
    m["medicineName"],
    m["drugName"],
    m["DrugName"],
    m["name"],
    m["Title"],
  ];
  for (final v in candidates) {
    if (v != null && v.toString().trim().isNotEmpty) return v.toString();
  }
  return "Medication";
}

  String _medDose(Map<String, dynamic> m) {
  final dose = (m["Dosage"] ?? m["dosage"] ?? m["Dose"] ?? m["Strength"] ?? "").toString().trim();
  final freq = (m["Frequency"] ?? m["frequency"] ?? m["Schedule"] ?? m["Instructions"] ?? "").toString().trim();

  final combined = [dose, freq].where((x) => x.isNotEmpty).join("  •  ");
  return combined.isEmpty ? "—" : combined;
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
          : (error != null ? _errorBox() : _content()),
    );
  }

  Widget _errorBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Health Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Text("Failed to load health summary:\n$error",
            style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _fetchHealth,
          child: const Text("Retry"),
        ),
      ],
    );
  }

  Widget _content() {
    final showMeds = meds.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Health Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),

        const Text("Current Medication",
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        if (showMeds.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F7FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text("No medications found."),
          )
        else
          ...showMeds.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _medTile(_medName(m), _medDose(m)),
              )),

        const SizedBox(height: 12),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_circle_outline),
              label: const Text("Request Refill"),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              child: const Text("View All Medication  >"),
            )
          ],
        ),

        const Divider(height: 26),

        const Text("Recent Medical Records",
            style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),

        _recordsTable(),
        const SizedBox(height: 10),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text("View All Medical Records  >"),
          ),
        ),
      ],
    );
  }

  Widget _medTile(String name, String dosage) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F7FB),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      children: [
        Expanded(
          flex: 6,
          child: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 5,
          child: Text(
            dosage,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.left,
          ),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.chevron_right, color: Colors.black45),
      ],
    ),
  );
}

  Widget _recordsTable() {
    TextStyle header = const TextStyle(color: Colors.black54, fontWeight: FontWeight.w700);
    TextStyle cell = const TextStyle(color: Colors.black87);

    Widget row(String a, String b, String c) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          Expanded(flex: 3, child: Text(a, style: cell)),
          Expanded(flex: 3, child: Text(b, style: cell)),
          Expanded(flex: 3, child: Text(c, style: cell)),
          const Icon(Icons.chevron_right, size: 18, color: Colors.black45),
        ]),
      );
    }

    if (recentRecords.isEmpty) {
      return Column(
        children: [
          Row(children: [
            Expanded(flex: 3, child: Text("Test Type", style: header)),
            Expanded(flex: 3, child: Text("Body Part", style: header)),
            Expanded(flex: 3, child: Text("Date", style: header)),
           const SizedBox(width: 18),
        ]),
        const Divider(height: 18),
        row("MRI", "Brain", "—"),
        row("X-ray", "Chest", "—"),
        row("Blood Test", "General", "—"),
      ],
    );
  }

    return Column(
      children: [
        Row(children: [
          Expanded(flex: 3, child: Text("Test Type", style: header)),
          Expanded(flex: 3, child: Text("Body Part", style: header)),
          Expanded(flex: 3, child: Text("Date", style: header)),
          const SizedBox(width: 18),
        ]),
        const Divider(height: 18),
        ...recentRecords.take(3).map((r) {
          final raw = (r["raw"] is Map) ? Map<String, dynamic>.from(r["raw"]) : <String, dynamic>{};
          return row(
            r["type"].toString(),
            r["body"].toString(),
            _formatRecordDate(raw),
          );
        }),
      ],
    );
  }
}