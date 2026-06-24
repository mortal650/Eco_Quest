import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final ecoMentorServiceProvider = Provider<EcoMentorService>((ref) {
  return EcoMentorService(FirebaseFirestore.instance, FirebaseAuth.instance);
});

class EcoMentorService {
  const EcoMentorService(this._firestore, this._auth);
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  Future<List<Map<String, String>>> getConversation() async {
    if (_uid == null) return [];
    final snap = await _firestore
        .collection('users')
        .doc(_uid)
        .collection('mentor_conversations')
        .orderBy('timestamp')
        .get();
    return snap.docs
        .map((d) => Map<String, String>.from(d.data()))
        .toList();
  }

  Future<void> sendMessage(String message) async {
    if (_uid == null) return;
    final col = _firestore
        .collection('users')
        .doc(_uid)
        .collection('mentor_conversations');

    await col.add({
      'role': 'user',
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final reply = _generateReply(message);
    await col.add({
      'role': 'mentor',
      'message': reply,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  String _generateReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('plastic') || lower.contains('waste')) {
      return 'Great question! Reducing plastic starts with small swaps — reusable bags, bottles, and containers make a huge difference over time.';
    }
    if (lower.contains('energy') || lower.contains('electricity')) {
      return 'Consider switching to LED bulbs and unplugging idle devices. Even small changes can reduce your energy bill and carbon footprint!';
    }
    if (lower.contains('water')) {
      return 'Fixing leaks and taking shorter showers are easy wins. Did you know a running tap wastes about 6 liters per minute?';
    }
    if (lower.contains('food') || lower.contains('eat')) {
      return 'Trying meatless Mondays is a great start. Plant-based meals use up to 90% less water and produce far fewer emissions.';
    }
    if (lower.contains('streak') || lower.contains('motivation')) {
      return 'You are doing amazing! Consistency is key — even small daily actions compound into massive impact over time.';
    }
    return 'That is a wonderful thought! Every eco-friendly choice you make matters. Keep exploring the modules to learn more ways to help the planet.';
  }
}

class AiMentorScreen extends ConsumerStatefulWidget {
  const AiMentorScreen({super.key});

  @override
  ConsumerState<AiMentorScreen> createState() => _AiMentorScreenState();
}

class _AiMentorScreenState extends ConsumerState<AiMentorScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, String>> _messages = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final msgs = await ref.read(ecoMentorServiceProvider).getConversation();
    setState(() {
      _messages = msgs;
      _loading = false;
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    setState(() => _loading = true);
    await ref.read(ecoMentorServiceProvider).sendMessage(text);
    await _loadMessages();
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Eco Mentor'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.smart_toy,
                                size: 64,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Ask me anything about sustainable living!',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scroll,
                        padding: const EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, i) {
                          final msg = _messages[i];
                          final isUser = msg['role'] == 'user';
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? Theme.of(context).colorScheme.primaryContainer
                                    : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(msg['message'] ?? ''),
                            ),
                          );
                        },
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Ask about sustainability...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _loading ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
