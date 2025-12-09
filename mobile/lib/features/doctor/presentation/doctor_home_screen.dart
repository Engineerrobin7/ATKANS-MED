
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_controller.dart';

class DoctorHomeScreen extends ConsumerWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Portal'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Active Access Requests', 
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white, 
                  fontWeight: FontWeight.bold
                )
              ),
              IconButton(onPressed: (){}, icon: const Icon(Icons.refresh, color: Colors.grey))
            ],
          ),
          const SizedBox(height: 16),
          // List of patients
           Card(
            color: const Color(0xFF1E1E1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                child: const Text('JD', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: const Text('John Doe', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Access expires in 2 hours', style: TextStyle(color: Colors.grey)),
              trailing: Chip(
                label: const Text('Active', style: TextStyle(color: Colors.black, fontSize: 12)), 
                backgroundColor: Theme.of(context).primaryColor,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.grey),
          const SizedBox(height: 24),
          Text('Quick Actions', 
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white, 
              fontWeight: FontWeight.bold
            )
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/doctor-home/search'),
            icon: const Icon(Icons.search),
            label: const Text('Request Access to Patient Record'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              backgroundColor: const Color(0xFF2C2C2C),
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
