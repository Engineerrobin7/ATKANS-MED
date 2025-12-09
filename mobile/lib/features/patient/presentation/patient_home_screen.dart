import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shimmer/shimmer.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/tilt_3d_card.dart';

class PatientHomeScreen extends ConsumerStatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  ConsumerState<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends ConsumerState<PatientHomeScreen> 
    with TickerProviderStateMixin {
  late AnimationController _cardAnimationController;
  late Animation<double> _cardAnimation;
 
  @override
  void initState() {
    super.initState();
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimationController,
      curve: Curves.easeOutCubic,
    );
    
    _cardAnimationController.forward();
  }

  @override
  void dispose() {
    _cardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Colors.white,
            ],
          ).createShader(bounds),
          child: const Text(
            'My Health Hub',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(authControllerProvider.notifier).signOut();
              context.go('/login');
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Icon(Icons.logout, size: 20),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.08),
              Colors.black,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(seconds: 1));
            },
            color: Theme.of(context).primaryColor,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Welcome Section
                _buildWelcomeSection(),
                const SizedBox(height: 24),
                
                // Quick Stats
                _buildQuickStats(),
                const SizedBox(height: 32),
                
                // Action Cards
                _buildSectionTitle('Quick Actions'),
                const SizedBox(height: 16),
                _buildAnimatedActionCard(
                  index: 0,
                  title: 'Medical Reports',
                  subtitle: 'View & Manage',
                  icon: Icons.description,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.cyan.shade300,
                    ],
                  ),
                  onTap: () => context.go('/patient-home/reports'),
                ),
                _buildAnimatedActionCard(
                  index: 1,
                  title: 'Prescriptions',
                  subtitle: 'Active & History',
                  icon: Icons.medical_services,
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.pink.shade300,
                    ],
                  ),
                  onTap: () {},
                ),
                _buildAnimatedActionCard(
                  index: 2,
                  title: 'Health Timeline',
                  subtitle: 'Track Progress',
                  icon: Icons.timeline,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Colors.yellow.shade300,
                    ],
                  ),
                  onTap: () {},
                ),
                const SizedBox(height: 32),
                
                // Recent Activity
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildWelcomeSection() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.6),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).primaryColor.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.black, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  child: AnimatedTextKit(
                    animatedTexts: [
                      TyperAnimatedText(
                        'John Doe',
                        speed: const Duration(milliseconds: 100),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_active,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Reports',
            value: '24',
            icon: Icons.article,
            color: Colors.blue.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Appointments',
            value: '3',
            icon: Icons.calendar_today,
            color: Colors.purple.shade400,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            label: 'Doctors',
            value: '5',
            icon: Icons.medical_services,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, animation, child) {
        return Transform.scale(
          scale: animation,
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAnimatedActionCard({
    required int index,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _cardAnimationController,
          curve: Interval(
            index * 0.2,
            0.6 + (index * 0.2),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.3, 0),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _cardAnimationController,
            curve: Interval(
              index * 0.2,
              0.6 + (index * 0.2),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: gradient.colors.first.withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Recent Activity'),
        const SizedBox(height: 16),
        _buildActivityItem(
          'Blood Test Results',
          '2 hours ago',
          Icons.science,
          Colors.red.shade300,
        ),
        _buildActivityItem(
          'Prescription Updated',
          'Yesterday',
          Icons.medical_services,
          Colors.blue.shade300,
        ),
        _buildActivityItem(
          'Doctor Consultation',
          '3 days ago',
          Icons.video_call,
          Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
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

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.black),
        label: const Text(
          'Upload Report',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
