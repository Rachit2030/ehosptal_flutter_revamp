import 'package:flutter/material.dart';

class DoctorDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> doctor;

  const DoctorDashboardScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    const primary = Color(0xFF3F51B5);
    const bg = Color(0xFFF5F7FB);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        return Scaffold(
          backgroundColor: bg,

          // ✅ AppBar only on mobile (hamburger shows automatically if drawer exists)
          appBar: isMobile
              ? AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: primary),
                  title: const Text(
                    "eHospital",
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,

          // ✅ Drawer only on mobile
          drawer: isMobile ? _Sidebar(primary: primary, isDrawer: true) : null,

          body: Row(
            children: [
              // ✅ Sidebar fixed only on desktop/web
              if (!isMobile)
                const SizedBox(
                  width: 240,
                  child: _Sidebar(primary: primary, isDrawer: false),
                ),

              // ✅ Main content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Welcome Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Hello Dr. ${doctor["Fname"] ?? ""},",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Appointments",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Responsive content area
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Text(
                                    "Appointments Table Coming Soon...",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // You can add stats cards here later (like screenshot)
                              // Example placeholder:
                              if (isMobile)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _StatCard(
                                        title: "Total Patients",
                                        value: "78",
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _StatCard(
                                        title: "Appointments",
                                        value: "7",
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ✅ Sidebar widget used for both Drawer (mobile) and Fixed sidebar (web)
class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.primary, required this.isDrawer});

  final Color primary;
  final bool isDrawer;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!isDrawer) ...[
            const SizedBox(height: 10),
            Center(
              child: Text(
                "eHospital",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ] else ...[
            DrawerHeader(
              margin: EdgeInsets.zero,
              child: Row(
                children: [
                  Icon(Icons.local_hospital, color: primary),
                  const SizedBox(width: 10),
                  Text(
                    "eHospital",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          _menuItem(context, Icons.dashboard, "Dashboard", true),
          _menuItem(context, Icons.person, "Profile", false),
          _menuItem(context, Icons.people, "Patient", false),
          _menuItem(context, Icons.message, "Messages", false),
          _menuItem(context, Icons.event, "Planning", false),
          _menuItem(context, Icons.calendar_today, "Calendar", false),
          _menuItem(context, Icons.receipt_long, "Billing", false),
          _menuItem(context, Icons.help_outline, "Help", false),

          const Spacer(),

          // Optional logout
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextButton.icon(
              onPressed: () {
                if (isDrawer) Navigator.pop(context); // close drawer

                // TODO: logout logic / clear token
                Navigator.pop(context); // go back to login screen
              },
              icon: const Icon(Icons.logout),
              label: const Text("Logout"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(
    BuildContext context,
    IconData icon,
    String title,
    bool selected,
  ) {
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
          // ✅ Close drawer on mobile after click
          if (isDrawer) Navigator.pop(context);

          // TODO: Navigate to different pages based on title
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
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple stat card (optional, mobile-friendly)
class _StatCard extends StatelessWidget {
  const _StatCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
