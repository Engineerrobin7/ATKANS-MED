
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExecutiveHomeScreen extends StatelessWidget {
  const ExecutiveHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Executive Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _buildStatCard('Total Referrals', '124')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('Earnings', '\$450')),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.go('/executive-home/onboard'),
              child: const Text('Onboard New User'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
            ),
             const SizedBox(height: 20),
             const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
             // List activity
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
