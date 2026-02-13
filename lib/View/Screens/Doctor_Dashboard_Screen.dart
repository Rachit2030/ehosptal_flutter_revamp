import 'package:ehosptal_flutter_revamp/View/Screens/Patient_List_Screen.dart';
import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  State<DoctorDashboardScreen> createState() =>
      _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  int selectedIndex = 0; // 0 = Dashboard, 1 = Patients, etc.

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3F51B5);
    const bg = Color(0xFFF5F7FB);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: bg,

          appBar: isMobile
              ? AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: primary),
                  title: const Text(
                    "eHospital",
                    style: TextStyle(color: primary),
                  ),
                )
              : null,

          drawer: isMobile
              ? _buildSidebar(primary, isDrawer: true)
              : null,

          body: Row(
            children: [
              if (!isMobile)
                SizedBox(
                  width: 240,
                  child: _buildSidebar(primary, isDrawer: false),
                ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ================= CONTENT SWITCHER =================
  Widget _buildContent() {
    if (selectedIndex == 0) {
      return _dashboardContent();
    } else if (selectedIndex == 1) {
      return const PatientListScreen(); // 👈 use your patient screen here
    } else {
      return const Center(child: Text("Coming Soon"));
    }
  }

  Widget _dashboardContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF3F51B5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            "Hello Dr. ${widget.doctor["Fname"]},",
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 30),
        const Text("Dashboard Content Here"),
      ],
    );
  }

  // ================= SIDEBAR =================
  Widget _buildSidebar(Color primary, {required bool isDrawer}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            "eHospital",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3F51B5),
            ),
          ),
          const SizedBox(height: 30),

          _menuItem(Icons.dashboard, "Dashboard", 0),
          _menuItem(Icons.people, "Patients", 1),
          _menuItem(Icons.calendar_today, "Calendar", 2),
          _menuItem(Icons.message, "Messages", 3),

          const Spacer(),

          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          )
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, int index) {
    const primary = Color(0xFF3F51B5);
    final selected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: selected
          ? BoxDecoration(
              color: const Color(0xFFE8EAF6),
              borderRadius: BorderRadius.circular(10),
            )
          : null,
      child: InkWell(
        onTap: () {
          setState(() {
            selectedIndex = index;
          });

          // close drawer if mobile
          Navigator.of(context).maybePop();
        },
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? primary : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                color: selected ? primary : Colors.grey,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
