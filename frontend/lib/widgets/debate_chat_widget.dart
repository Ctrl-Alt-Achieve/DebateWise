import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/firebase_service.dart';
import '../theme.dart';

class DebateChatWidget extends StatefulWidget {
  const DebateChatWidget({super.key});

  @override
  State<DebateChatWidget> createState() => _DebateChatWidgetState();
}

class _DebateChatWidgetState extends State<DebateChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    
    try {
      Provider.of<FirebaseService>(context, listen: false).sendMessage(text);
    } catch (e) {
      debugPrint("[ERROR] Failed to send message: $e");
    }
    
    _controller.clear();

    // Auto-scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 920),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Glow Effects
          _buildGlowEffects(),
          // Main Card
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildBrowserHeader(),
                _buildChatContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowEffects() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              left: 40,
              bottom: -30,
              child: Container(
                width: 280,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(140),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandBlue.withOpacity(0.15),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -30,
              child: Container(
                width: 280,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(140),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.brandPurple.withOpacity(0.12),
                      blurRadius: 120,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrowserHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.06))),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          _buildDot(const Color(0xFFFF5F57)),
          const SizedBox(width: 8),
          _buildDot(const Color(0xFFFFBD2E)),
          const SizedBox(width: 8),
          _buildDot(const Color(0xFF28C840)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.radio, size: 12, color: Colors.greenAccent.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  "Live",
                  style: TextStyle(color: Colors.greenAccent.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildChatContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Messages area
          Container(
            height: 420,
            margin: const EdgeInsets.only(bottom: 16),
            child: Consumer<FirebaseService>(
              builder: (context, service, child) {
                if (service.messages.isEmpty) {
                  return _buildEmptyState();
                }

                // Auto-scroll when new messages arrive
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    );
                  }
                });

                return RawScrollbar(
                  controller: _scrollController,
                  thumbColor: Colors.white.withOpacity(0.12),
                  radius: const Radius.circular(8),
                  thickness: 4,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(right: 8),
                    itemCount: service.messages.length,
                    itemBuilder: (context, index) {
                      final msg = service.messages[index];
                      final bool isUser = msg.agent == 'User';
                      return _buildMessageBubble(msg.agent, msg.text, isUser);
                    },
                  ),
                );
              },
            ),
          ),

          // Input area
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.brandBlue.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.brandBlue.withOpacity(0.15)),
            ),
            child: Icon(LucideIcons.messageSquare, color: AppTheme.brandBlue.withOpacity(0.5), size: 24),
          ),
          const SizedBox(height: 16),
          const Text(
            'Start a debate',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Type a topic below and our AI agents will discuss it',
            style: TextStyle(color: AppTheme.textGray.withOpacity(0.6), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String agent, String text, bool isUser) {
    final Color agentColor = _getAgentColor(agent);
    final String agentLabel = _getAgentLabel(agent);
    final IconData agentIcon = _getAgentIcon(agent);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: EdgeInsets.only(
        bottom: 12,
        left: isUser ? 40 : 0,
        right: isUser ? 0 : 40,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser
              ? const Color(0xFF1A2332)
              : const Color(0xFF13181F),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isUser ? 14 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 14),
          ),
          border: Border.all(
            color: isUser
                ? AppTheme.brandBlue.withOpacity(0.15)
                : agentColor.withOpacity(0.12),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent header
            Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        agentColor.withOpacity(0.25),
                        agentColor.withOpacity(0.08),
                      ],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: agentColor.withOpacity(0.3)),
                  ),
                  child: Center(
                    child: Icon(agentIcon, size: 14, color: agentColor),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      agentLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: agentColor,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if (!isUser)
                      Text(
                        _getAgentRole(agent),
                        style: TextStyle(
                          fontSize: 10,
                          color: agentColor.withOpacity(0.5),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                  ],
                ),
                const Spacer(),
                if (!isUser)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: agentColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "AI",
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: agentColor.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            // Divider
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.04),
            ),
            const SizedBox(height: 10),
            // Message text
            SelectableText(
              text,
              style: TextStyle(
                color: isUser ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
                fontSize: 14,
                height: 1.65,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _controller,
            onSubmitted: _handleSubmitted,
            style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
            cursorColor: AppTheme.brandBlue,
            decoration: InputDecoration(
              hintText: 'Ask the AI panel to debate any topic...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 15),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildChip(LucideIcons.search, 'Search', AppTheme.brandBlue),
                  const SizedBox(width: 8),
                  _buildChip(LucideIcons.sparkles, 'Think', AppTheme.brandPurple),
                ],
              ),
              Row(
                children: [
                  Text(
                    'DebateWise AI',
                    style: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _handleSubmitted(_controller.text),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppTheme.brandBlue, AppTheme.brandPurple],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.brandBlue.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(LucideIcons.arrowUp, color: Colors.white, size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 13, color: color.withOpacity(0.7)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // --- Agent Metadata ---

  Color _getAgentColor(String agentName) {
    final name = agentName.toLowerCase();
    if (name == 'user') return const Color(0xFF60A5FA); // soft blue
    if (name.contains("skeptic")) return const Color(0xFFF87171); // soft red
    if (name.contains("explain") || name.contains("overexplain")) return const Color(0xFF38BDF8); // sky blue
    if (name.contains("question")) return const Color(0xFFFBBF24); // amber
    if (name.contains("arbiter") || name.contains("verdict")) return const Color(0xFFA78BFA); // purple
    if (name.contains("manager")) return const Color(0xFF2DD4BF); // teal
    return const Color(0xFF94A3B8); // slate
  }

  String _getAgentLabel(String agent) {
    final name = agent.toLowerCase();
    if (name == 'user') return 'You';
    if (name.contains("skeptic")) return 'The Skeptic';
    if (name.contains("explain") || name.contains("overexplain")) return 'The Overexplainer';
    if (name.contains("question")) return 'The Questioner';
    if (name.contains("arbiter") || name.contains("verdict")) return 'The Arbiter';
    if (name.contains("manager")) return 'Crew Manager';
    return agent;
  }

  IconData _getAgentIcon(String agent) {
    final name = agent.toLowerCase();
    if (name == 'user') return LucideIcons.user;
    if (name.contains("skeptic")) return LucideIcons.shieldAlert;
    if (name.contains("explain") || name.contains("overexplain")) return LucideIcons.bookOpen;
    if (name.contains("question")) return LucideIcons.helpCircle;
    if (name.contains("arbiter") || name.contains("verdict")) return LucideIcons.scale;
    if (name.contains("manager")) return LucideIcons.brain;
    return LucideIcons.bot;
  }

  String _getAgentRole(String agent) {
    final name = agent.toLowerCase();
    if (name.contains("skeptic")) return 'Challenges assumptions';
    if (name.contains("explain") || name.contains("overexplain")) return 'Deep technical dive';
    if (name.contains("question")) return 'Asks foundational questions';
    if (name.contains("arbiter") || name.contains("verdict")) return 'Final verdict & fact-check';
    if (name.contains("manager")) return 'Orchestrates the debate';
    return '';
  }
}
