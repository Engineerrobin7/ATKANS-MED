
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class PatientSearchScreen extends StatefulWidget {
  const PatientSearchScreen({super.key});

  @override
  State<PatientSearchScreen> createState() => _PatientSearchScreenState();
}

class _PatientSearchScreenState extends State<PatientSearchScreen> {
  final _searchController = TextEditingController();
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Patient'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter Patient Phone or ID',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => _searchController.clear(),
                ),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
              style: const TextStyle(color: Colors.white),
              onSubmitted: (value) {
                // Perform search
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchController.text.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search, size: 64, color: Colors.grey.shade800),
                          const SizedBox(height: 16),
                          const Text('Search for a patient to request access', 
                            style: TextStyle(color: Colors.grey)
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        // Dummy result
                        Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.black,
                              child: const Text('AS', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            title: const Text('Ankit Sharma', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            subtitle: const Text('+91 98765 43210', style: TextStyle(color: Colors.grey)),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                _showRequestDialog(context);
                              },
                              child: const Text('Request Access'),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Request Access', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select duration for access:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: ['1 Hour', '24 Hours', '7 Days']
                  .map((e) => ChoiceChip(
                        label: Text(e, style: TextStyle(color: e == '24 Hours' ? Colors.black : Colors.white)),
                        selected: e == '24 Hours',
                        selectedColor: Theme.of(context).primaryColor,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.white.withOpacity(0.2)),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        onSelected: (val) {},
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
             const TextField(
              decoration: InputDecoration(
                labelText: 'Reason for access',
                labelStyle: TextStyle(color: Colors.grey),
                hintText: 'e.g., Routine Checkup',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
              ),
              style: TextStyle(color: Colors.white),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request Sent')));
            },
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }
}
