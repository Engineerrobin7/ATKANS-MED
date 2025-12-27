import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// Mock Models
class DoctorAccess {
  final String id;
  final String name;
  final String specialty;
  final String hospital;
  final bool isPending;

  DoctorAccess({
    required this.id,
    required this.name,
    required this.specialty,
    required this.hospital,
    this.isPending = false,
  });
}

// Mock State Controller
class AccessControlNotifier extends StateNotifier<List<DoctorAccess>> {
  AccessControlNotifier() : super([
    DoctorAccess(id: '1', name: 'Dr. John Doe', specialty: 'Cardiology', hospital: 'City Hospital', isPending: true),
    DoctorAccess(id: '2', name: 'Dr. Sarah Smith', specialty: 'Dermatology', hospital: 'Mayo Clinic', isPending: false),
  ]);

  void approveRequest(String id) {
    state = [
      for (final doc in state)
        if (doc.id == id)
          DoctorAccess(id: doc.id, name: doc.name, specialty: doc.specialty, hospital: doc.hospital, isPending: false)
        else
          doc
    ];
  }

  void rejectRequest(String id) {
    state = state.where((doc) => doc.id != id).toList();
  }

  void revokeAccess(String id) {
    state = state.where((doc) => doc.id != id).toList();
  }
}

final accessControlProvider = StateNotifierProvider<AccessControlNotifier, List<DoctorAccess>>((ref) {
  return AccessControlNotifier();
});

class AccessControlScreen extends ConsumerWidget {
  const AccessControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final doctors = ref.watch(accessControlProvider);
    final pending = doctors.where((d) => d.isPending).toList();
    final active = doctors.where((d) => !d.isPending).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Doctor Access', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: theme.iconTheme,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pending.isNotEmpty) ...[
              Text('Access Requests', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.primaryColor)),
              const SizedBox(height: 10),
              ...pending.map((doc) => _buildRequestCard(context, ref, doc)),
              const SizedBox(height: 24),
            ],

            Text('Active Doctors', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: theme.textTheme.bodyMedium?.color)),
            const SizedBox(height: 10),
            if (active.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text('No doctors have access currently.', style: TextStyle(color: theme.textTheme.bodySmall?.color)),
              ),
            ...active.map((doc) => _buildActiveCard(context, ref, doc)),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, WidgetRef ref, DoctorAccess doc) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(backgroundColor: theme.primaryColor.withOpacity(0.1), child: Icon(Icons.person, color: theme.primaryColor)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
                    Text('${doc.specialty} • ${doc.hospital}', style: GoogleFonts.outfit(fontSize: 12, color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ref.read(accessControlProvider.notifier).rejectRequest(doc.id),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ref.read(accessControlProvider.notifier).approveRequest(doc.id),
                    style: ElevatedButton.styleFrom(backgroundColor: theme.primaryColor),
                    child: Text('Grant Access', style: TextStyle(color: theme.colorScheme.onPrimary)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildActiveCard(BuildContext context, WidgetRef ref, DoctorAccess doc) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.blue.withOpacity(0.1), child: const Icon(Icons.medical_services, color: Colors.blueAccent)),
        title: Text(doc.name, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: theme.textTheme.bodyLarge?.color)),
        subtitle: Text(doc.specialty, style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _confirmRevoke(context, ref, doc),
        ),
      ),
    );
  }

  void _confirmRevoke(BuildContext context, WidgetRef ref, DoctorAccess doc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Revoke Access?'),
        content: Text('Are you sure you want to remove ${doc.name}? They will no longer be able to view your records.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(accessControlProvider.notifier).revokeAccess(doc.id);
              Navigator.pop(context);
            },
            child: const Text('Revoke', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
