import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/glass_card.dart';

class PatientSearchScreen extends ConsumerStatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  ConsumerState<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends ConsumerState<PatientSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Patient> _allPatients = [];
  List<Patient> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  void _loadPatients() {
    // Demo data - replace with Firestore
    _allPatients.addAll([
      Patient(
        id: '1',
        name: 'John Doe',
        phone: '+1 234 567 8900',
        email: 'john@example.com',
        lastVisit: DateTime.now().subtract(const Duration(days: 5)),
        hasActiveAccess: false,
      ),
      Patient(
        id: '2',
        name: 'Jane Smith',
        phone: '+1 234 567 8901',
        email: 'jane@example.com',
        lastVisit: DateTime.now().subtract(const Duration(days: 12)),
        hasActiveAccess: true,
      ),
      Patient(
        id: '3',
        name: 'Robert Johnson',
        phone: '+1 234 567 8902',
        email: 'robert@example.com',
        lastVisit: DateTime.now().subtract(const Duration(days: 30)),
        hasActiveAccess: false,
      ),
    ]);
  }

  void _search(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = _allPatients
            .where((p) =>
                p.name.toLowerCase().contains(query.toLowerCase()) ||
                p.phone.contains(query) ||
                p.email.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _requestAccess(Patient patient) {
    showDialog(
      context: context,
      builder: (context) => _AccessRequestDialog(patient: patient),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Patients'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _search,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by name, phone, or email',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _search('');
                        },
                        icon: const Icon(Icons.clear, color: Colors.grey),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? _searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                            const SizedBox(height: 16),
                            Text(
                              'No patients found',
                              style: TextStyle(color: Colors.grey[400], fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          return _buildPatientCard(_searchResults[index]);
                        },
                      )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_search, size: 80, color: Colors.grey[600]),
                        const SizedBox(height: 16),
                        Text(
                          'Search for patients',
                          style: TextStyle(fontSize: 18, color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter name, phone, or email',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientCard(Patient patient) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
            child: Text(
              patient.name[0].toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      patient.phone,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      'Last visit: ${_formatDate(patient.lastVisit)}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (patient.hasActiveAccess)
            Chip(
              label: const Text('Active', style: TextStyle(color: Colors.white, fontSize: 11)),
              backgroundColor: Colors.green,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            )
          else
            ElevatedButton(
              onPressed: () => _requestAccess(patient),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Request Access'),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 30) return '${diff.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _AccessRequestDialog extends StatefulWidget {
  final Patient patient;

  const _AccessRequestDialog({required this.patient});

  @override
  State<_AccessRequestDialog> createState() => _AccessRequestDialogState();
}

class _AccessRequestDialogState extends State<_AccessRequestDialog> {
  final TextEditingController _reasonController = TextEditingController();
  int _selectedDuration = 24; // hours

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Request Access', style: TextStyle(color: Colors.white)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient: ${widget.patient.name}',
            style: TextStyle(color: Colors.grey[300], fontSize: 14),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Reason for Access',
              labelStyle: TextStyle(color: Colors.grey[400]),
              hintText: 'e.g., Follow-up consultation, Treatment review',
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 12),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Access Duration:', style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildDurationChip(24, '24 Hours'),
              _buildDurationChip(168, '7 Days'),
              _buildDurationChip(720, '30 Days'),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Patient will be notified and can approve/deny',
                    style: TextStyle(color: Colors.blue[200], fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_reasonController.text.isNotEmpty) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✓ Access request sent to ${widget.patient.name}'),
                  backgroundColor: Theme.of(context).primaryColor,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.black,
          ),
          child: const Text('Send Request'),
        ),
      ],
    );
  }

  Widget _buildDurationChip(int hours, String label) {
    final isSelected = _selectedDuration == hours;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedDuration = hours);
      },
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: const Color(0xFF2C2C2C),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

class Patient {
  final String id;
  final String name;
  final String phone;
  final String email;
  final DateTime lastVisit;
  final bool hasActiveAccess;

  Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.lastVisit,
    required this.hasActiveAccess,
  });
}
