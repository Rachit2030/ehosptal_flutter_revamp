import 'package:ehosptal_flutter_revamp/View/Screens/Patient_List_Screen.dart';
import 'package:ehosptal_flutter_revamp/View/Widgets/Appointments_Section.dart';
import 'package:ehosptal_flutter_revamp/View/Widgets/Tasks_Section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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
  child: SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: _buildContent(), // dashboard will now scroll
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
  final isMobile = MediaQuery.of(context).size.width < 900;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Top row
      Row(
        children: [
          const Expanded(
            child: Text(
              "Doctor Portal  /  Dashboard",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFB76BFF), Color(0xFF6B7CFF)],
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              "AI Assistant",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          const Icon(Icons.notifications_none, color: Colors.black54),
          const SizedBox(width: 10),
          const Icon(Icons.person_outline, color: Colors.black54),
        ],
      ),

      const SizedBox(height: 14),

      // Banner
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1E4ED8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Hello, Doctor\nWish you a wonderful day at work.",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),

      const SizedBox(height: 16),

      // ✅ Fixed heights so Appointments/Tasks can safely use Expanded internally
      if (isMobile) ...[
        const SizedBox(height: 560, child: AppointmentsSection()),
        const SizedBox(height: 14),
        const SizedBox(height: 720, child: TasksSection()),
      ] else ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Expanded(
              flex: 7,
              child: SizedBox(height: 680, child: AppointmentsSection()),
            ),
            SizedBox(width: 14),
            Expanded(
              flex: 3,
              child: SizedBox(height: 680, child: TasksSection()),
            ),
          ],
        ),
      ],

      const SizedBox(height: 24),
    ],
  );
}



  // ================= SIDEBAR =================
  Widget _buildSidebar(Color primary, {required bool isDrawer}) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const SizedBox(height: 20),
           Center(
  child: SvgPicture.asset(
    "assets/ehospital_logo.svg",
    height: 54,
    fit: BoxFit.fill,
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
