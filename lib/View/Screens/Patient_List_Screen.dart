import 'package:flutter/material.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Demo data (replace with API later)
  final List<Map<String, dynamic>> _allPatients = [
    {
      "name": "Charlie Kim",
      "age": 45,
      "gender": "Male",
      "status": "Active",
      "lastAppointment": "2025-06-05",
      "lastDiagnosis": "Blood Pressure Follow-up",
    },
    {
      "name": "Marcus Thompson",
      "age": 45,
      "gender": "Male",
      "status": "Active",
      "lastAppointment": "2025-06-04",
      "lastDiagnosis": "Type 2 Diabetes Mellitus",
    },
    {
      "name": "Chloe Bertrand",
      "age": 38,
      "gender": "Female",
      "status": "Active",
      "lastAppointment": "2025-06-03",
      "lastDiagnosis": "Lower Back Pain",
    },
    {
      "name": "Sophia Nguyen",
      "age": 61,
      "gender": "Female",
      "status": "Active",
      "lastAppointment": "2025-06-03",
      "lastDiagnosis": "Hypertension",
    },
    {
      "name": "Mason Clark",
      "age": 57,
      "gender": "Male",
      "status": "Active",
      "lastAppointment": "2025-06-02",
      "lastDiagnosis": "COPD",
    },
    {
      "name": "Hana Takahashi",
      "age": 31,
      "gender": "Female",
      "status": "Inactive",
      "lastAppointment": "2025-01-05",
      "lastDiagnosis": "Seasonal Allergic Rhinitis",
    },
    {
      "name": "Olivia Mendes",
      "age": 34,
      "gender": "Male",
      "status": "Inactive",
      "lastAppointment": "2025-01-04",
      "lastDiagnosis": "Acute Sinusitis",
    },
  ];

  List<Map<String, dynamic>> _filtered = [];

  // very simple pagination demo
  int _page = 1;
  final int _pageSize = 8;

  @override
  void initState() {
    super.initState();
    _filtered = List<Map<String, dynamic>>.from(_allPatients);
    _searchController.addListener(_applySearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();
    setState(() {
      _page = 1;
      if (q.isEmpty) {
        _filtered = List<Map<String, dynamic>>.from(_allPatients);
      } else {
        _filtered = _allPatients
            .where((p) => (p["name"] as String).toLowerCase().contains(q))
            .toList();
      }
    });
  }

  List<Map<String, dynamic>> get _paged {
    final start = (_page - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, _filtered.length);
    if (start >= _filtered.length) return [];
    return _filtered.sublist(start, end);
  }

  int get _totalPages {
    final pages = (_filtered.length / _pageSize).ceil();
    return pages == 0 ? 1 : pages;
  }

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3F51B5);
    const bg = Color(0xFFF5F7FB);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: primary),
            title: const Text(
              "Your Patient List",
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== search + action buttons row
                Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _SearchBox(controller: _searchController),
                    _ActionButton(
                      label: "AI Chatbots",
                      icon: Icons.smart_toy_outlined,
                      onTap: () {},
                    ),
                    _ActionButton(
                      label: "Analytics",
                      icon: Icons.bar_chart_outlined,
                      onTap: () {},
                    ),
                    _ActionButton(
                      label: "Filter",
                      icon: Icons.filter_alt_outlined,
                      onTap: () {},
                    ),
                    _ActionButton(
                      label: "Archive",
                      icon: Icons.archive_outlined,
                      onTap: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
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
                    child: isMobile ? _mobileList(primary) : _desktopTable(primary),
                  ),
                ),

                const SizedBox(height: 14),

                // ===== pagination footer
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: _page > 1
                          ? () => setState(() => _page -= 1)
                          : null,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text("Previous"),
                    ),
                    const Spacer(),
                    _PageNumbers(
                      current: _page,
                      total: _totalPages,
                      onSelect: (p) => setState(() => _page = p),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _page < _totalPages
                          ? () => setState(() => _page += 1)
                          : null,
                      icon: const Icon(Icons.chevron_right),
                      label: const Text("Next"),
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------- Desktop Table ----------
  Widget _desktopTable(Color primary) {
    final rows = _paged;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Table header row
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            "Patients",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: DataTable(
              headingRowHeight: 46,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 60,
              columns: const [
                DataColumn(label: Text("Name")),
                DataColumn(label: Text("Age")),
                DataColumn(label: Text("Gender")),
                DataColumn(label: Text("Status")),
                DataColumn(label: Text("Last Appointment")),
                DataColumn(label: Text("Last Diagnosis")),
              ],
              rows: rows.map((p) {
                return DataRow(
                  cells: [
                    DataCell(
                      InkWell(
                        onTap: () {},
                        child: Text(
                          p["name"],
                          style: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text("${p["age"]}")),
                    DataCell(Text("${p["gender"]}")),
                    DataCell(_StatusDropdown(
                      value: p["status"],
                      onChanged: (v) => setState(() => p["status"] = v),
                    )),
                    DataCell(Text("${p["lastAppointment"]}")),
                    DataCell(Text("${p["lastDiagnosis"]}")),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Mobile List ----------
  Widget _mobileList(Color primary) {
    final rows = _paged;

    if (rows.isEmpty) {
      return const Center(
        child: Text("No patients found", style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = rows[i];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          title: Text(
            p["name"],
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Age: ${p["age"]} • Gender: ${p["gender"]}"),
                const SizedBox(height: 4),
                Text("Last Appt: ${p["lastAppointment"]}"),
                const SizedBox(height: 4),
                Text("Dx: ${p["lastDiagnosis"]}"),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusDropdown(
                    value: p["status"],
                    onChanged: (v) => setState(() => p["status"] = v),
                  ),
                ),
              ],
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {},
        );
      },
    );
  }
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 520,
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: "Enter patient name",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3F51B5);

    return SizedBox(
      height: 42,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _StatusDropdown({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = value.toLowerCase() == "active";
    final borderColor = isActive ? const Color(0xFF22C55E) : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          borderRadius: BorderRadius.circular(12),
          items: const [
            DropdownMenuItem(value: "Active", child: Text("Active")),
            DropdownMenuItem(value: "Inactive", child: Text("Inactive")),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class _PageNumbers extends StatelessWidget {
  final int current;
  final int total;
  final ValueChanged<int> onSelect;

  const _PageNumbers({
    required this.current,
    required this.total,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // show up to 7 numbers around current
    final start = (current - 3).clamp(1, total);
    final end = (start + 6).clamp(1, total);

    return Row(
      children: [
        for (int p = start; p <= end; p++)
          InkWell(
            onTap: () => onSelect(p),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: p == current ? const Color(0xFFEEF2FF) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                "$p",
                style: TextStyle(
                  fontWeight: p == current ? FontWeight.w800 : FontWeight.w600,
                  color: p == current ? const Color(0xFF3F51B5) : Colors.black54,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
