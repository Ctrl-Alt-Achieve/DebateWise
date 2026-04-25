import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../widgets/debate_chat_widget.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Rainbow gradient border at top
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.brandPink,
                    AppTheme.brandOrange,
                    AppTheme.brandYellow,
                    AppTheme.brandGreen,
                    AppTheme.brandBlue,
                    AppTheme.brandPurple,
                  ],
                ),
              ),
            ),
            
            _buildNavBar(),
            
            // Hero Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: Column(
                children: [
                  const Text(
                    "The fastest, ultra-realistic\nintelligent debate platform",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w500,
                      height: 1.1,
                      color: AppTheme.textWhite,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "DebateWise is your all-in-one AI panel,\nfor complex topics and fact-checking.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.textGray,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // CTA Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.textWhite,
                          foregroundColor: AppTheme.backgroundBlack,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text("Start Debate for free", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textWhite,
                          side: const BorderSide(color: AppTheme.borderGray),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                        child: const Text("See how it works"),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Firebase Connected Chat Demo
            const DebateChatWidget(),

            // Features Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
              child: _buildFeaturesGrid(),
            ),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [AppTheme.brandPink, AppTheme.brandOrange, AppTheme.brandBlue],
                  ),
                ),
                child: Center(
                  child: Container(width: 12, height: 12, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(2))),
                ),
              ),
              const SizedBox(width: 8),
              const Text("DebateWise", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Colors.white)),
            ],
          ),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text("Sign In", style: TextStyle(color: AppTheme.textGray))),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textWhite,
                  side: const BorderSide(color: AppTheme.borderGray),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("Join Session"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesGrid() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _buildFeatureCard(LucideIcons.messageSquare, "Multiple Personas", "Skeptic, Overexplainer, and Arbiter agents.")),
            const SizedBox(width: 24),
            Expanded(child: _buildFeatureCard(LucideIcons.brain, "Fact Check", "Advanced web grounding with Google Search.")),
            const SizedBox(width: 24),
            Expanded(child: _buildFeatureCard(LucideIcons.zap, "Real-time stream", "Firebase connected live streaming thoughts.")),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0x4D111827), // bg-gray-900/30
        border: Border.all(color: AppTheme.borderGray),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.cardGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(desc, style: const TextStyle(color: AppTheme.textGray, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppTheme.borderGray)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("© 2025 DebateWise AI.", style: TextStyle(color: AppTheme.textGray, fontSize: 14)),
          Row(
            children: [
              TextButton(onPressed: () {}, child: const Text("Privacy", style: TextStyle(color: AppTheme.textGray, fontSize: 14))),
              TextButton(onPressed: () {}, child: const Text("Terms", style: TextStyle(color: AppTheme.textGray, fontSize: 14))),
            ],
          )
        ],
      ),
    );
  }
}
