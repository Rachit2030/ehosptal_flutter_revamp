import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class BillingScreen extends StatefulWidget {
  final String doctorId;

  const BillingScreen({super.key, required this.doctorId});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  int selectedTab = 1; // 0 = New Bill, 1 = Bills
  List<Bill> bills = [];
  bool isLoading = true;
  int rowsPerPage = 10;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills() async {
    setState(() => isLoading = true);
    try {
      final String response = await rootBundle.loadString('assets/data/bills.json');
      final List<dynamic> data = json.decode(response);
      setState(() {
        bills = data.map((json) => Bill.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error loading bills: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Text(
                "Billing Management",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 24),

              // Tab Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildTabButton(
                      icon: Icons.receipt_long,
                      label: "New Bill",
                      isSelected: selectedTab == 0,
                      onTap: () => setState(() => selectedTab = 0),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTabButton(
                      icon: Icons.medical_information,
                      label: "Bills",
                      isSelected: selectedTab == 1,
                      onTap: () => setState(() => selectedTab = 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Content
              if (selectedTab == 0)
                NewBillForm(doctorId: widget.doctorId)
              else
                BillsListView(
                  bills: bills,
                  isLoading: isLoading,
                  rowsPerPage: rowsPerPage,
                  currentPage: currentPage,
                  onRowsPerPageChanged: (value) {
                    setState(() {
                      rowsPerPage = value!;
                      currentPage = 0;
                    });
                  },
                  onPageChanged: (page) {
                    setState(() => currentPage = page);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3F51B5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF3F51B5) : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF3F51B5),
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF3F51B5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// New Bill Form Widget
class NewBillForm extends StatefulWidget {
  final String doctorId;

  const NewBillForm({super.key, required this.doctorId});

  @override
  State<NewBillForm> createState() => _NewBillFormState();
}

class _NewBillFormState extends State<NewBillForm> {
  final _formKey = GlobalKey<FormState>();
  String billType = 'OHIP';
  final _patientNameController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  final _ohipNumberController = TextEditingController();
  final _serviceCodeController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? selectedService;
  List<BillItem> billItems = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create New Bill",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
            const SizedBox(height: 24),

            // Bill Type
            const Text("Bill Type", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Radio<String>(
                  value: 'OHIP',
                  groupValue: billType,
                  onChanged: (value) => setState(() => billType = value!),
                ),
                const Text('OHIP'),
                const SizedBox(width: 24),
                Radio<String>(
                  value: 'Private',
                  groupValue: billType,
                  onChanged: (value) => setState(() => billType = value!),
                ),
                const Text('Private'),
              ],
            ),
            const SizedBox(height: 20),

            // Patient Name
            const Text("Patient Name", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _patientNameController,
              decoration: InputDecoration(
                hintText: "Enter patient name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 20),

            // Date
            const Text("Date", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) setState(() => selectedDate = date);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat('yyyy-MM-dd').format(selectedDate)),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // OHIP Billing Information
            const Text(
              "OHIP Billing Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3F51B5),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("OHIP Number*", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _ohipNumberController,
                        decoration: InputDecoration(
                          hintText: "Enter OHIP number",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Service*", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: "Search or select service",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: ['Consultation', 'Surgery', 'Lab Test', 'X-Ray', 'Vaccination']
                            .map((service) => DropdownMenuItem(value: service, child: Text(service)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedService = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Service Code", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _serviceCodeController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Amount", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Amount is automatically set based on service",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Note
            const Text("Note", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Enter note (optional)",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Add OHIP Item Button
            ElevatedButton(
              onPressed: _addBillItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("ADD OHIP ITEM"),
            ),
            const SizedBox(height: 24),

            // Bill Preview
            const Text(
              "Bill Preview",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(child: Text("Code", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Description", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Unit Price", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Unit", style: TextStyle(fontWeight: FontWeight.bold))),
                        Expanded(child: Text("Actions", style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  if (billItems.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text("No items added yet", style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ...billItems.map((item) => _buildBillItemRow(item)).toList(),
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text("Total Amount:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(width: 16),
                        Text(
                          "\$${_calculateTotal().toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF3F51B5)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _submitBill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Submit Bill", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillItemRow(BillItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(child: Text(item.code)),
          Expanded(child: Text(item.description)),
          Expanded(child: Text("\$${item.unitPrice.toStringAsFixed(2)}")),
          Expanded(child: Text(item.unit.toString())),
          Expanded(
            child: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  billItems.remove(item);
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addBillItem() {
    if (_serviceCodeController.text.isNotEmpty && _amountController.text.isNotEmpty) {
      setState(() {
        billItems.add(BillItem(
          code: _serviceCodeController.text,
          description: selectedService ?? 'Service',
          unitPrice: double.tryParse(_amountController.text) ?? 0,
          unit: 1,
        ));
        _serviceCodeController.clear();
        _amountController.clear();
        selectedService = null;
      });
    }
  }

  double _calculateTotal() {
    return billItems.fold(0, (sum, item) => sum + (item.unitPrice * item.unit));
  }

  void _submitBill() {
    if (_formKey.currentState!.validate() && billItems.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bill submitted successfully')),
      );
      // Reset form
      _patientNameController.clear();
      _ohipNumberController.clear();
      _noteController.clear();
      setState(() {
        billItems.clear();
        selectedDate = DateTime.now();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields and add at least one item')),
      );
    }
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _ohipNumberController.dispose();
    _serviceCodeController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }
}

// Bills List View Widget
class BillsListView extends StatelessWidget {
  final List<Bill> bills;
  final bool isLoading;
  final int rowsPerPage;
  final int currentPage;
  final Function(int?) onRowsPerPageChanged;
  final Function(int) onPageChanged;

  const BillsListView({
    super.key,
    required this.bills,
    required this.isLoading,
    required this.rowsPerPage,
    required this.currentPage,
    required this.onRowsPerPageChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final startIndex = currentPage * rowsPerPage;
    final endIndex = (startIndex + rowsPerPage > bills.length) ? bills.length : startIndex + rowsPerPage;
    final displayedBills = bills.sublist(startIndex, endIndex);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bills",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Table
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  ),
                  child: const Row(
                    children: [
                      Expanded(child: Text("Date ↑", style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Time", style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Doctor", style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Patient", style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Type", style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Notes", style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(child: Text("Codes", style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),

                // Rows
                if (displayedBills.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text("No bills found", style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...displayedBills.map((bill) => _buildBillRow(bill)).toList(),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text("Rows per page:"),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: rowsPerPage,
                items: [10, 25, 50].map((value) {
                  return DropdownMenuItem(value: value, child: Text(value.toString()));
                }).toList(),
                onChanged: onRowsPerPageChanged,
              ),
              const SizedBox(width: 24),
              Text("${startIndex + 1}–$endIndex of ${bills.length}"),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: currentPage > 0 ? () => onPageChanged(currentPage - 1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: endIndex < bills.length ? () => onPageChanged(currentPage + 1) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillRow(Bill bill) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(child: Text(DateFormat('MMM dd, yyyy').format(bill.date))),
          Expanded(child: Text(bill.time)),
          Expanded(child: Text(bill.doctor)),
          Expanded(child: Text(bill.patient)),
          Expanded(child: Text(bill.type)),
          Expanded(child: Text(bill.notes, maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(child: Text(bill.codes.join(', '))),
        ],
      ),
    );
  }
}

// Models
class Bill {
  final String id;
  final DateTime date;
  final String time;
  final String doctor;
  final String patient;
  final String type;
  final String notes;
  final List<String> codes;

  Bill({
    required this.id,
    required this.date,
    required this.time,
    required this.doctor,
    required this.patient,
    required this.type,
    required this.notes,
    required this.codes,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      doctor: json['doctor'],
      patient: json['patient'],
      type: json['type'],
      notes: json['notes'],
      codes: List<String>.from(json['codes']),
    );
  }
}

class BillItem {
  final String code;
  final String description;
  final double unitPrice;
  final int unit;

  BillItem({
    required this.code,
    required this.description,
    required this.unitPrice,
    required this.unit,
  });
}