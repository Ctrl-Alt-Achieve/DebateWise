import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme.dart';
import '../widgets/debate_chat_widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _howItWorksKey = GlobalKey();
  final GlobalKey _aboutKey = GlobalKey();
  final GlobalKey _chatKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundBlack,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            // Rainbow gradient border at top
            Container(
              height: 3,
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
              child: Column(
                children: [
                  // Pill badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.brandBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.brandBlue.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.sparkles, size: 14, color: AppTheme.brandBlue),
                        const SizedBox(width: 8),
                        Text(
                          "Powered by CrewAI & Gemini",
                          style: TextStyle(
                            color: AppTheme.brandBlue,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "The fastest, ultra-realistic\nintelligent debate platform",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                      color: AppTheme.textWhite,
                      letterSpacing: -1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "DebateWise is your all-in-one AI panel\nfor complex topics and fact-checking.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      color: AppTheme.textGray,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // CTA Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPrimaryCTA(),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => _scrollTo(_howItWorksKey),
                        icon: const Icon(LucideIcons.play, size: 16),
                        label: const Text("See how it works"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textWhite,
                          side: BorderSide(color: Colors.white.withOpacity(0.15)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Firebase Connected Chat Demo
            DebateChatWidget(key: _chatKey),

            const SizedBox(height: 40),

            // Features Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
              child: _buildFeaturesGrid(),
            ),

            // How It Works Section
            _buildHowItWorksSection(),

            // About Section
            _buildAboutSection(),

            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryCTA() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          colors: [AppTheme.brandBlue, AppTheme.brandPurple],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _scrollTo(_chatKey),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        ),
        child: const Text("Start Debate", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.brandPink, AppTheme.brandOrange, AppTheme.brandBlue],
                  ),
                ),
                child: Center(
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                "DebateWise",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white, letterSpacing: -0.5),
              ),
            ],
          ),
          // Nav links
          Row(
            children: [
              TextButton(
                onPressed: () => _scrollTo(_howItWorksKey),
                child: const Text("How it works", style: TextStyle(color: AppTheme.textGray, fontSize: 14)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _scrollTo(_aboutKey),
                child: const Text("About", style: TextStyle(color: AppTheme.textGray, fontSize: 14)),
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
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.messageSquare,
                "Multiple Personas",
                "Skeptic, Overexplainer, Questioner, and Arbiter agents debate your topic from every angle.",
                AppTheme.brandPink,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.brain,
                "Fact Checking",
                "Advanced web grounding with Google Search ensures every claim is verified in real-time.",
                AppTheme.brandBlue,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: _buildFeatureCard(
                LucideIcons.zap,
                "Real-time Stream",
                "Firebase-powered live streaming of agent thoughts — watch the debate unfold instantly.",
                AppTheme.brandGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String desc, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1A),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: TextStyle(color: AppTheme.textGray, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  // ─── HOW IT WORKS ─────────────────────────────────────────────

  Widget _buildHowItWorksSection() {
    return Container(
      key: _howItWorksKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      decoration: BoxDecoration(
        color: const Color(0xFF050A12),
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.white.withOpacity(0.04)),
        ),
      ),
      child: Column(
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.brandPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.brandPurple.withOpacity(0.2)),
            ),
            child: Text(
              "HOW IT WORKS",
              style: TextStyle(
                color: AppTheme.brandPurple,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "From question to verdict\nin four steps",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              height: 1.2,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Our multi-agent architecture ensures every topic is explored, challenged, and resolved.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textGray, fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 56),

          // Steps
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              children: [
                _buildStep(
                  "01",
                  "You Ask a Question",
                  "Type any topic — from \"explain bubble sort\" to \"is AI consciousness possible.\" Your input is sent to Firebase in real-time, instantly triggering the backend AI crew.",
                  LucideIcons.messageCircle,
                  AppTheme.brandBlue,
                ),
                _buildStepConnector(),
                _buildStep(
                  "02",
                  "The Overexplainer Dives Deep",
                  "The first agent generates a dense, technical explanation of your topic, intentionally overloading it with jargon — setting the stage for the debate.",
                  LucideIcons.bookOpen,
                  const Color(0xFF38BDF8),
                ),
                _buildStepConnector(),
                _buildStep(
                  "03",
                  "The Skeptic Challenges Everything",
                  "A second agent tears apart the explanation, poking holes in assumptions, highlighting edge cases, and raising counterarguments. Meanwhile, the Questioner asks foundational questions.",
                  LucideIcons.shieldAlert,
                  const Color(0xFFF87171),
                ),
                _buildStepConnector(),
                _buildStep(
                  "04",
                  "The Arbiter Delivers the Verdict",
                  "The final agent reviews the entire debate, fact-checks claims using live web search, and delivers an objective, clear verdict — the truth, distilled.",
                  LucideIcons.scale,
                  AppTheme.brandPurple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String title, String desc, IconData icon, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step number circle
        Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(color: color.withOpacity(0.25), width: 1.5),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 22),
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      number,
                      style: TextStyle(
                        color: color.withOpacity(0.4),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  desc,
                  style: TextStyle(color: AppTheme.textGray, fontSize: 14, height: 1.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector() {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: Row(
        children: [
          Container(
            width: 2,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.08),
                  Colors.white.withOpacity(0.02),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── ABOUT SECTION ────────────────────────────────────────────

  Widget _buildAboutSection() {
    return Container(
      key: _aboutKey,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              // Section header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.brandGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.brandGreen.withOpacity(0.2)),
                ),
                child: Text(
                  "ABOUT",
                  style: TextStyle(
                    color: AppTheme.brandGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Built for deeper understanding",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "DebateWise was born from a simple observation: students learn better when ideas are challenged, questioned, and defended. Instead of passively reading one explanation, our platform simulates an entire panel of experts — each with a unique perspective — debating your topic in real-time.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textGray, fontSize: 15, height: 1.7),
              ),
              const SizedBox(height: 48),

              // Tech stack cards
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _buildTechCard(
                        "Multi-Agent Architecture",
                        "Built with CrewAI's hierarchical process, where a Manager LLM orchestrates four specialized agents — each with distinct personalities and goals.",
                        LucideIcons.layers,
                        AppTheme.brandBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTechCard(
                        "Gemini 3 Flash",
                        "Powered by Google's latest Gemini 3 Flash model for fast, high-quality reasoning. The Shadow Auditor runs in parallel for bias detection.",
                        LucideIcons.cpu,
                        AppTheme.brandPurple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildTechCard(
                        "Firebase Real-time",
                        "Frontend and backend communicate through Firebase Realtime Database, enabling instant message streaming with no polling or page refreshes.",
                        LucideIcons.radio,
                        AppTheme.brandGreen,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Architecture summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F1A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.gitBranch, color: AppTheme.textGray, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          "System Architecture",
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildArchRow("Flutter Web App", "→", "Firebase Realtime DB", "→", "Python CrewAI Backend"),
                    const SizedBox(height: 16),
                    Container(
                      height: 1,
                      color: Colors.white.withOpacity(0.04),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTechPill("Flutter", const Color(0xFF02569B)),
                        _buildTechPill("Firebase", const Color(0xFFFFA000)),
                        _buildTechPill("CrewAI", const Color(0xFF10B981)),
                        _buildTechPill("Gemini", AppTheme.brandBlue),
                        _buildTechPill("Python", const Color(0xFF3776AB)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTechCard(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: TextStyle(color: AppTheme.textGray, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildArchRow(String a, String arrow1, String b, String arrow2, String c) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildArchNode(a),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(LucideIcons.arrowRight, color: Colors.white.withOpacity(0.15), size: 18),
        ),
        _buildArchNode(b),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Icon(LucideIcons.arrowRight, color: Colors.white.withOpacity(0.15), size: 18),
        ),
        _buildArchNode(c),
      ],
    );
  }

  Widget _buildArchNode(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildTechPill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "© 2025 DebateWise AI. Built with CrewAI.",
            style: TextStyle(color: AppTheme.textGray.withOpacity(0.6), fontSize: 13),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {},
                child: Text("Privacy", style: TextStyle(color: AppTheme.textGray.withOpacity(0.6), fontSize: 13)),
              ),
              TextButton(
                onPressed: () {},
                child: Text("Terms", style: TextStyle(color: AppTheme.textGray.withOpacity(0.6), fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
