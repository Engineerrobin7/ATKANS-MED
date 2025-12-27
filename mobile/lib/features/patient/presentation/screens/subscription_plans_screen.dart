
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/payment_service.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  late PaymentService _paymentService;

  @override
  void initState() {
    super.initState();
    _paymentService = PaymentService(
      onSuccess: _handlePaymentSuccess,
      onFailure: _handlePaymentError,
      onExternalWallet: (response) {},
    );
  }

  @override
  void dispose() {
    _paymentService.dispose();
    super.dispose();
  }

  void _handlePaymentSuccess(dynamic response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Subscription Activated Successfully!')),
    );
    Navigator.pop(context);
  }

  void _handlePaymentError(dynamic response) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment Failed. Please try again.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.05),
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'ATKANS PRO',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.limeGreen,
                    letterSpacing: 2,
                  ),
                ),
                background: Center(
                  child: Icon(Icons.star, size: 80, color: AppTheme.limeGreen.withValues(alpha: 0.3)),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlock the Full Potential of Your Health Locker',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _buildPlanCard(
                      title: 'Basic',
                      price: 'Free',
                      features: ['10 Report Uploads', 'Single Device', 'Community Support'],
                      color: Colors.grey,
                      isCurrent: true,
                    ),
                    const SizedBox(height: 20),
                    _buildPlanCard(
                      title: 'Silver',
                      price: '₹299/mo',
                      features: ['50 Report Uploads', 'Shared Access (2 Doctors)', 'Priority Chat', 'Family Sharing (2 Max)'],
                      color: const Color(0xFFC0C0C0),
                      onSubscribe: () async {
                        await _paymentService.openCheckout(
                          amount: 299,
                          planId: 'plan_silver', // Make sure this plan exists in Razorpay Dashboard
                          name: "Atkans Med Silver",
                          description: "Monthly Silver Subscription",
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildPlanCard(
                      title: 'Gold',
                      price: '₹999/mo',
                      features: [
                        'Unlimited Uploads',
                        'Unlimited Doctor Sharing',
                        'Video Consultations',
                        'E-Pharmacy Discounts',
                        'Personal Health Concierge',
                        'Advanced Analytics'
                      ],
                      color: AppTheme.limeGreen,
                      isPopular: true,
                      onSubscribe: () async {
                         await _paymentService.openCheckout(
                          amount: 999,
                          planId: 'plan_gold', // Make sure this plan exists in Razorpay Dashboard
                          name: "Atkans Med Gold",
                          description: "Monthly Gold Subscription",
                        );
                      },
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    bool isPopular = false,
    bool isCurrent = false,
    VoidCallback? onSubscribe,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isPopular ? AppTheme.limeGreen : color.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: isPopular ? [
          BoxShadow(
            color: AppTheme.limeGreen.withValues(alpha: 0.2),
            blurRadius: 20,
            spreadRadius: 2,
          )
        ] : [],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.limeGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'MOST POPULAR',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle, size: 18, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    f,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isCurrent ? null : onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent ? Colors.grey : color,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                isCurrent ? 'Current Plan' : 'Select Plan',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
