import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/firebase_service.dart';
import '../theme.dart';

class DebateChatWidget extends StatelessWidget {
  const DebateChatWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 896), // max-w-4xl
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background Glow Effects (simulated with Positioned containers)
          _buildGlowEffects(),
          // Browser Frame
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardGray.withOpacity(0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.borderGray),
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
      child: Stack(
        children: [
          Positioned(
            left: 50,
            bottom: -20,
            child: Container(
              width: 256,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.4),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 100, spreadRadius: 30)
                ]
              ),
            ),
          ),
          Positioned(
            right: 50,
            bottom: -20,
            child: Container(
              width: 256,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.4),
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(color: Colors.red.withOpacity(0.4), blurRadius: 100, spreadRadius: 30)
                ]
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrowserHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0x80111827), // bg-gray-900/50
        border: Border(bottom: BorderSide(color: AppTheme.borderGray)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Row(
        children: [
          _buildMacButton(Colors.redAccent),
          const SizedBox(width: 6),
          _buildMacButton(Colors.amber),
          const SizedBox(width: 6),
          _buildMacButton(Colors.green),
        ],
      ),
    );
  }

  Widget _buildMacButton(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildChatContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Live Chat Messages
          Container(
            height: 300,
            margin: const EdgeInsets.only(bottom: 24),
            child: Consumer<FirebaseService>(
              builder: (context, service, child) {
                if (service.messages.isEmpty) {
                  return const Center(
                    child: Text('Waiting for the debate to begin...', style: TextStyle(color: AppTheme.textGray)),
                  );
                }
                return ListView.builder(
                  itemCount: service.messages.length,
                  itemBuilder: (context, index) {
                    final msg = service.messages[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: _getAgentColor(msg.agent),
                            child: Text(msg.agent.substring(0, 1), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(msg.agent, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white70)),
                                const SizedBox(height: 4),
                                Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Input Box style matching React
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x801F2937),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x80374151)),
            ),
            child: Column(
              children: [
                TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Observe the debate or inject a thought...',
                    hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildActionChip(LucideIcons.search, 'DeepSearch'),
                        const SizedBox(width: 8),
                        _buildActionChip(LucideIcons.sparkles, 'Think', isPurple: true),
                      ],
                    ),
                    Row(
                      children: [
                        const Text('DebateWise AI v1', style: TextStyle(color: AppTheme.textGray, fontSize: 12)),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.chevronDown, color: AppTheme.textGray, size: 14),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF374151),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(LucideIcons.arrowUp, color: Colors.white, size: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionChip(IconData icon, String label, {bool isPurple = false}) {
    Color baseColor = isPurple ? AppTheme.brandPurple : AppTheme.brandBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(0.2),
        border: Border.all(color: baseColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: baseColor),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: baseColor, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Color _getAgentColor(String agentName) {
    if (agentName.toLowerCase().contains("skeptic")) return Colors.redAccent;
    if (agentName.toLowerCase().contains("explain")) return Colors.blueAccent;
    if (agentName.toLowerCase().contains("question")) return Colors.orangeAccent;
    if (agentName.toLowerCase().contains("arbiter")) return Colors.purpleAccent;
    return Colors.grey;
  }
}
