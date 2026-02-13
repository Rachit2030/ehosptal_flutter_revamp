// import 'package:flutter/material.dart';

// class AppointmentsSection extends StatefulWidget {
//   const AppointmentsSection({super.key});

//   @override
//   State<AppointmentsSection> createState() => _AppointmentsSectionState();
// }

// class _AppointmentsSectionState extends State<AppointmentsSection> {
//   final TextEditingController _search = TextEditingController();
//   String _query = "";

//   String selectedDateLabel = "June 20th, 2025 (Today)";

//   final List<Map<String, dynamic>> _appointments = [
//     {
//       "time": "9:00 AM – 9:30 AM",
//       "patient": "Charlie Kim",
//       "reason": "Blood Pressure Follow-up",
//       "signed": true,
//       "billed": false,
//       "status": "No Show",
//     },
//     {
//       "time": "9:45 AM – 10:00 AM",
//       "patient": "Daniel Okafor",
//       "reason": "Annual Physical Exam",
//       "signed": false,
//       "billed": true,
//       "status": "Done",
//     },
//     {
//       "time": "10:15 AM – 10:45 AM",
//       "patient": "Sophia Nguyen",
//       "reason": "Acne Treatment",
//       "signed": true,
//       "billed": false,
//       "status": "In Room",
//     },
//     {
//       "time": "11:15 AM – 11:30 AM",
//       "patient": "Chloe Martin",
//       "reason": "Medication Refill",
//       "signed": false,
//       "billed": false,
//       "status": "Ready",
//     },
//     {
//       "time": "3:00 PM – 3:30 PM",
//       "patient": "Lucas Schneider",
//       "reason": "Cholesterol Follow-up",
//       "signed": false,
//       "billed": false,
//       "status": "Arrive",
//     },
//     {
//       "time": "3:30 PM – 4:00 PM",
//       "patient": "Jing Zhao",
//       "reason": "Medication Refill",
//       "signed": true,
//       "billed": true,
//       "status": "Confirmed",
//     },
//     {
//       "time": "4:30 PM – 4:45 PM",
//       "patient": "Fatima El-Sayed",
//       "reason": "Skin Rash Examination",
//       "signed": false,
//       "billed": false,
//       "status": "Pending",
//     },
//   ];

//   @override
//   void initState() {
//     super.initState();
//     _search.addListener(() => setState(() => _query = _search.text.trim().toLowerCase()));
//   }

//   @override
//   void dispose() {
//     _search.dispose();
//     super.dispose();
//   }

//   List<Map<String, dynamic>> get filtered {
//     if (_query.isEmpty) return _appointments;
//     return _appointments.where((a) {
//       final patient = (a["patient"] as String).toLowerCase();
//       final reason = (a["reason"] as String).toLowerCase();
//       return patient.contains(_query) || reason.contains(_query);
//     }).toList();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isMobile = MediaQuery.of(context).size.width < 900;

//     return Container(
//       padding: EdgeInsets.all(isMobile ? 12 : 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 30,
//             offset: const Offset(0, 14),
//             color: Colors.black.withOpacity(0.06),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Wrap(
//             alignment: WrapAlignment.spaceBetween,
//             runSpacing: 12,
//             spacing: 12,
//             children: [
//               const Text(
//                 "Appointments",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
//               ),
//               _DateSelector(label: selectedDateLabel),
//             ],
//           ),
//           const SizedBox(height: 12),

//           TextField(
//             controller: _search,
//             decoration: InputDecoration(
//               hintText: "Search by patient name or reason for visit here",
//               suffixIcon: const Icon(Icons.search),
//               filled: true,
//               fillColor: const Color(0xFFF5F6F8),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//           ),

//           const SizedBox(height: 12),

//           Expanded(
//             child: isMobile ? _MobileList(items: filtered) : _Table(
//               items: filtered,
//               onStatusChanged: (i, v) => setState(() => filtered[i]["status"] = v),
//             ),
//           ),

//           const SizedBox(height: 8),
//           Align(
//             alignment: Alignment.centerRight,
//             child: TextButton(
//               onPressed: () {},
//               child: const Text("View all appointments"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _DateSelector extends StatelessWidget {
//   final String label;
//   const _DateSelector({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
//           decoration: BoxDecoration(
//             color: const Color(0xFFE5E7EB),
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: const Text("Today", style: TextStyle(color: Colors.black54)),
//         ),
//         const SizedBox(width: 10),
//         IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left)),
//         Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
//         IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
//       ],
//     );
//   }
// }

// class _Table extends StatelessWidget {
//   final List<Map<String, dynamic>> items;
//   final void Function(int index, String value) onStatusChanged;

//   const _Table({required this.items, required this.onStatusChanged});

//   @override
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: DataTable(
//         headingRowHeight: 44,
//         dataRowMinHeight: 56,
//         dataRowMaxHeight: 64,
//         columns: const [
//           DataColumn(label: Text("Time")),
//           DataColumn(label: Text("Patient Name")),
//           DataColumn(label: Text("Reason for Visit")),
//           DataColumn(label: Text("Signed")),
//           DataColumn(label: Text("Billed")),
//           DataColumn(label: Text("Status")),
//           DataColumn(label: Text("")),
//         ],
//         rows: List.generate(items.length, (i) {
//           final a = items[i];
//           return DataRow(
//             cells: [
//               DataCell(Text(a["time"])),
//               DataCell(
//                 InkWell(
//                   onTap: () {},
//                   child: Text(
//                     a["patient"],
//                     style: const TextStyle(
//                       color: Color(0xFF1E4ED8),
//                       fontWeight: FontWeight.w700,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ),
//               DataCell(Text(a["reason"])),
//               DataCell(_BoolIcon(value: a["signed"] == true)),
//               DataCell(_BoolIcon(value: a["billed"] == true, dollar: true)),
//               DataCell(_StatusPill(
//                 value: a["status"],
//                 onChanged: (v) => onStatusChanged(i, v),
//               )),
//               const DataCell(Icon(Icons.more_horiz)),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }

// class _MobileList extends StatelessWidget {
//   final List<Map<String, dynamic>> items;
//   const _MobileList({required this.items});

//   @override
//   Widget build(BuildContext context) {
//     if (items.isEmpty) return const Center(child: Text("No appointments"));

//     return ListView.separated(
//       itemCount: items.length,
//       separatorBuilder: (_, __) => const Divider(height: 1),
//       itemBuilder: (_, i) {
//         final a = items[i];
//         return ListTile(
//           title: Text(a["patient"], style: const TextStyle(fontWeight: FontWeight.w800)),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 6),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(a["time"], style: const TextStyle(color: Colors.black54)),
//                 const SizedBox(height: 4),
//                 Text(a["reason"]),
//                 const SizedBox(height: 8),
//                 _StatusPill(value: a["status"], onChanged: (_) {}),
//               ],
//             ),
//           ),
//           trailing: const Icon(Icons.more_horiz),
//         );
//       },
//     );
//   }
// }

// class _BoolIcon extends StatelessWidget {
//   final bool value;
//   final bool dollar;
//   const _BoolIcon({required this.value, this.dollar = false});

//   @override
//   Widget build(BuildContext context) {
//     if (dollar) {
//       return Icon(
//         Icons.attach_money,
//         color: value ? const Color(0xFF1E4ED8) : Colors.black26,
//       );
//     }
//     return Icon(
//       Icons.edit,
//       color: value ? const Color(0xFF1E4ED8) : Colors.black26,
//     );
//   }
// }

// class _StatusPill extends StatelessWidget {
//   final String value;
//   final ValueChanged<String> onChanged;

//   const _StatusPill({required this.value, required this.onChanged});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(999),
//         border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           items: const [
//             DropdownMenuItem(value: "No Show", child: Text("No Show")),
//             DropdownMenuItem(value: "Done", child: Text("Done")),
//             DropdownMenuItem(value: "In Room", child: Text("In Room")),
//             DropdownMenuItem(value: "Ready", child: Text("Ready")),
//             DropdownMenuItem(value: "Arrive", child: Text("Arrive")),
//             DropdownMenuItem(value: "Confirmed", child: Text("Confirmed")),
//             DropdownMenuItem(value: "Pending", child: Text("Pending")),
//           ],
//           onChanged: (v) => v == null ? null : onChanged(v),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';

class AppointmentsSection extends StatefulWidget {
  const AppointmentsSection({super.key});

  @override
  State<AppointmentsSection> createState() => _AppointmentsSectionState();
}

class _AppointmentsSectionState extends State<AppointmentsSection> {
  final TextEditingController _search = TextEditingController();
  String _query = "";

  String selectedDateLabel = "June 20th, 2025 (Today)";

  final List<Map<String, dynamic>> _appointments = [
    {
      "time": "9:00 AM – 9:30 AM",
      "patient": "Charlie Kim",
      "reason": "Blood Pressure Follow-up",
      "signed": true,
      "billed": false,
      "status": "No Show",
    },
    {
      "time": "9:45 AM – 10:00 AM",
      "patient": "Daniel Okafor",
      "reason": "Annual Physical Exam",
      "signed": false,
      "billed": true,
      "status": "Done",
    },
    {
      "time": "10:15 AM – 10:45 AM",
      "patient": "Sophia Nguyen",
      "reason": "Acne Treatment",
      "signed": true,
      "billed": false,
      "status": "In Room",
    },
    {
      "time": "11:15 AM – 11:30 AM",
      "patient": "Chloe Martin",
      "reason": "Medication Refill",
      "signed": false,
      "billed": false,
      "status": "Ready",
    },
    {
      "time": "3:00 PM – 3:30 PM",
      "patient": "Lucas Schneider",
      "reason": "Cholesterol Follow-up",
      "signed": false,
      "billed": false,
      "status": "Arrive",
    },
    {
      "time": "3:30 PM – 4:00 PM",
      "patient": "Jing Zhao",
      "reason": "Medication Refill",
      "signed": true,
      "billed": true,
      "status": "Confirmed",
    },
    {
      "time": "4:30 PM – 4:45 PM",
      "patient": "Fatima El-Sayed",
      "reason": "Skin Rash Examination",
      "signed": false,
      "billed": false,
      "status": "Pending",
    },
  ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() {
      setState(() => _query = _search.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get filtered {
    if (_query.isEmpty) return _appointments;
    return _appointments.where((a) {
      final patient = (a["patient"] as String).toLowerCase();
      final reason = (a["reason"] as String).toLowerCase();
      return patient.contains(_query) || reason.contains(_query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 12,
            spacing: 12,
            children: [
              const Text(
                "Appointments",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              _DateSelector(label: selectedDateLabel),
            ],
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _search,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: "Search by patient name or reason for visit here",
              hintStyle: const TextStyle(fontSize: 13, color: Colors.black45),
              suffixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: const Color(0xFFF5F6F8),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: isMobile
                ? _MobileList(items: filtered)
                : _Table(
                    items: filtered,
                    onStatusChanged: (i, v) =>
                        setState(() => filtered[i]["status"] = v),
                  ),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text("View all appointments"),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  final String label;
  const _DateSelector({required this.label});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        // available width inside this widget
        final maxW = c.maxWidth;
        // label gets whatever is left after chip + arrows
        final labelW = (maxW - 140).clamp(90.0, 220.0);

        return Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                "Today",
                style: TextStyle(color: Colors.black54, fontSize: 12.5),
              ),
            ),
            // 
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
              icon: const Icon(Icons.chevron_left),
            ),
            // const SizedBox(width: 6),
            SizedBox(
              width: labelW,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
              ),
            ),
            // const SizedBox(width: 6),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {},
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        );
      },
    );
  }
}


// class _DateSelector extends StatelessWidget {
//   final String label;
//   const _DateSelector({required this.label});

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//           decoration: BoxDecoration(
//             color: const Color(0xFFE5E7EB),
//             borderRadius: BorderRadius.circular(999),
//           ),
//           child: const Text(
//             "Today",
//             style: TextStyle(color: Colors.black54, fontSize: 12.5),
//           ),
//         ),
//         const SizedBox(width: 8),

//         IconButton(
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//           onPressed: () {},
//           icon: const Icon(Icons.chevron_left),
//         ),
//         const SizedBox(width: 8),

//         SizedBox(
//           width: 190,
//           child: Text(
//             label,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             softWrap: false,
//             style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
//           ),
//         ),

//         const SizedBox(width: 8),
//         IconButton(
//           padding: EdgeInsets.zero,
//           constraints: const BoxConstraints(),
//           onPressed: () {},
//           icon: const Icon(Icons.chevron_right),
//         ),
//       ],
//     );
//   }
// }

class _Table extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final void Function(int index, String value) onStatusChanged;

  const _Table({required this.items, required this.onStatusChanged});

  Text _cell(String text, {bool link = false}) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: link ? FontWeight.w700 : FontWeight.w500,
        color: link ? const Color(0xFF1E4ED8) : Colors.black87,
        decoration: link ? TextDecoration.underline : TextDecoration.none,
      ),
    );
  }

  Text _header(String text) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      softWrap: false,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 980),
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 14,
            horizontalMargin: 12,
            headingRowHeight: 44,
            dataRowMinHeight: 56,
            dataRowMaxHeight: 64,
            columns: [
              DataColumn(label: _header("Time")),
              DataColumn(label: _header("Patient Name")),
              DataColumn(label: _header("Reason for Visit")),
              DataColumn(label: _header("Signed")),
              DataColumn(label: _header("Billed")),
              DataColumn(label: _header("Status")),
              const DataColumn(label: Text("")),
            ],
            rows: List.generate(items.length, (i) {
              final a = items[i];
              return DataRow(
                cells: [
                  DataCell(_cell(a["time"])),
                  DataCell(
                    InkWell(
                      onTap: () {},
                      child: _cell(a["patient"], link: true),
                    ),
                  ),
                  DataCell(_cell(a["reason"])),
                  DataCell(_BoolIcon(value: a["signed"] == true)),
                  DataCell(_BoolIcon(value: a["billed"] == true, dollar: true)),
                  DataCell(
                    _StatusPill(
                      value: a["status"],
                      onChanged: (v) => onStatusChanged(i, v),
                    ),
                  ),
                  const DataCell(Icon(Icons.more_horiz, size: 18)),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _MobileList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _MobileList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const Center(child: Text("No appointments"));

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final a = items[i];
        return ListTile(
          title: Text(
            a["patient"],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a["time"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Text(
                  a["reason"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12.5),
                ),
                const SizedBox(height: 8),
                _StatusPill(value: a["status"], onChanged: (_) {}),
              ],
            ),
          ),
          trailing: const Icon(Icons.more_horiz),
        );
      },
    );
  }
}

class _BoolIcon extends StatelessWidget {
  final bool value;
  final bool dollar;
  const _BoolIcon({required this.value, this.dollar = false});

  @override
  Widget build(BuildContext context) {
    if (dollar) {
      return Icon(
        Icons.attach_money,
        size: 20,
        color: value ? const Color(0xFF1E4ED8) : Colors.black26,
      );
    }
    return Icon(
      Icons.edit,
      size: 18,
      color: value ? const Color(0xFF1E4ED8) : Colors.black26,
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _StatusPill({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF93C5FD), width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          style: const TextStyle(fontSize: 12.5, color: Colors.black87),
          items: const [
            DropdownMenuItem(value: "No Show", child: Text("No Show")),
            DropdownMenuItem(value: "Done", child: Text("Done")),
            DropdownMenuItem(value: "In Room", child: Text("In Room")),
            DropdownMenuItem(value: "Ready", child: Text("Ready")),
            DropdownMenuItem(value: "Arrive", child: Text("Arrive")),
            DropdownMenuItem(value: "Confirmed", child: Text("Confirmed")),
            DropdownMenuItem(value: "Pending", child: Text("Pending")),
          ],
          onChanged: (v) => v == null ? null : onChanged(v),
        ),
      ),
    );
  }
}

