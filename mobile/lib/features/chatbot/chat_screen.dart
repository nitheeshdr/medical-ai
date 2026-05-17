import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/api_client.dart';
import '../../providers/health_data_provider.dart';
import '../../providers/prescriptions_provider.dart';
import '../reports/report_upload_screen.dart';

// ── Chat session list provider ─────────────────────────────────────────────────

final chatSessionsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  try {
    final api = ref.read(apiClientProvider);
    final res = await api.get('/chat');
    final body = res.data;
    final list = body is List ? body : (body['sessions'] ?? body['chats'] ?? []);
    return (list as List).map((e) => Map<String, dynamic>.from(e as Map)).toList();
  } catch (_) {
    return [];
  }
});

// ── Single session message state ──────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  const _ChatMessage({required this.text, required this.isUser, required this.time});
}

class _ChatNotifier extends Notifier<List<_ChatMessage>> {
  String _sessionId = '';

  @override
  List<_ChatMessage> build() => [
    _ChatMessage(
      text: "Hi! I'm MediNova AI 🩺\nAsk me anything about your health — symptoms, medications, reports, or lifestyle advice.",
      isUser: false,
      time: DateTime.now(),
    ),
  ];

  void initSession(String id, List<_ChatMessage> initial) {
    _sessionId = id;
    if (initial.isNotEmpty) {
      state = initial;
    }
  }

  Future<void> sendMessage(String text, {Map<String, dynamic>? contextData}) async {
    if (text.trim().isEmpty) return;
    state = [...state, _ChatMessage(text: text, isUser: true, time: DateTime.now())];
    state = [...state, _ChatMessage(text: '', isUser: false, time: DateTime.now())];

    try {
      final token = await const FlutterSecureStorage().read(key: AppConstants.jwtKey) ?? '';
      final dio = Dio();
      final response = await dio.post(
        '${AppConstants.baseUrl}/ai/chat',
        data: jsonEncode({
          'message': text,
          'sessionId': _sessionId,
          if (contextData != null) 'contextData': contextData,
        }),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'text/event-stream',
          },
          responseType: ResponseType.stream,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );

      final stream = (response.data as ResponseBody).stream;
      String accumulated = '';

      await for (final bytes in stream) {
        if (!ref.mounted) break;
        for (final line in utf8.decode(bytes).split('\n')) {
          if (!line.startsWith('data: ')) continue;
          final payload = line.substring(6).trim();
          if (payload == '[DONE]') break;
          try {
            final delta = (jsonDecode(payload) as Map<String, dynamic>)['text'] as String? ?? '';
            accumulated += delta;
            if (!ref.mounted) break;
            final msgs = List<_ChatMessage>.from(state);
            msgs[msgs.length - 1] = _ChatMessage(text: accumulated, isUser: false, time: DateTime.now());
            state = msgs;
          } catch (_) {}
        }
      }

      if (ref.mounted && accumulated.isEmpty) {
        _setLastMessage('Sorry, I didn\'t receive a response. Please try again.');
      }
    } catch (e) {
      if (!ref.mounted) return;
      final msg = e is DioException
          ? (e.response?.statusCode == 401
              ? 'Please sign in to use the AI chat.'
              : e.response?.statusCode == 413
                  ? 'Message too large. Try a shorter question.'
                  : 'Connection error: ${e.message}')
          : 'Unable to reach AI. Check your connection.';
      _setLastMessage(msg);
    }
  }

  void _setLastMessage(String text) {
    if (!ref.mounted) return;
    final msgs = List<_ChatMessage>.from(state);
    msgs[msgs.length - 1] = _ChatMessage(text: text, isUser: false, time: DateTime.now());
    state = msgs;
  }
}

final _chatProvider = NotifierProvider<_ChatNotifier, List<_ChatMessage>>(_ChatNotifier.new);

// ── Chat List Screen ──────────────────────────────────────────────────────────

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  String _timeAgo(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs       = Theme.of(context).colorScheme;
    final tt       = Theme.of(context).textTheme;
    final sessions = ref.watch(chatSessionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Chat'),
        actions: [
          IconButton(
            tooltip: 'New conversation',
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: () => _openChat(context, ref, null, []),
          ),
        ],
      ),
      body: sessions.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyState(onNewChat: () => _openChat(context, ref, null, [])),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyState(onNewChat: () => _openChat(context, ref, null, []));
          }
          return RefreshIndicator(
            onRefresh: () => ref.refresh(chatSessionsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 0, indent: 72),
              itemBuilder: (_, i) {
                final s = list[i];
                final messages = (s['messages'] as List?) ?? [];
                
                final initialMessages = messages.map((m) => _ChatMessage(
                  text: m['content'] as String? ?? '',
                  isUser: m['role'] == 'user',
                  time: DateTime.tryParse(m['timestamp']?.toString() ?? '') ?? DateTime.now(),
                )).toList();
                
                final lastMsg  = messages.isNotEmpty
                    ? (messages.last['content'] as String? ?? '')
                    : 'No messages yet';
                final sessionId = s['_id'] as String? ?? '';
                final title    = s['title'] as String? ??
                    (messages.isNotEmpty ? (messages.first['content'] as String? ?? 'Health Consultation') : 'Health Consultation');

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: cs.primaryContainer,
                    child: Icon(Icons.psychology_rounded, color: cs.primary, size: 20),
                  ),
                  title: Text(
                    title.length > 40 ? '${title.substring(0, 40)}…' : title,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    lastMsg.length > 60 ? '${lastMsg.substring(0, 60)}…' : lastMsg,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(_timeAgo(s['updatedAt'] as String?),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                      const SizedBox(height: 4),
                      Badge(
                         isLabelVisible: messages.isNotEmpty,
                        label: Text('${messages.length}'),
                        child: const SizedBox(width: 8),
                      ),
                    ],
                  ),
                  onTap: () => _openChat(context, ref, sessionId, initialMessages),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        onPressed: () => _openChat(context, ref, null, []),
        icon: const Icon(Icons.add_comment_rounded),
        label: const Text('New Chat'),
      ),
    );
  }

  void _openChat(BuildContext context, WidgetRef ref, String? sessionId, List<_ChatMessage> initialMessages) {
    final sid = sessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}';
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ProviderScope(
        overrides: [_chatProvider.overrideWith(() => _ChatNotifier()..initSession(sid, initialMessages))],
        child: _ChatConversationScreen(
          sessionArg: {'sessionId': sid, 'messages': initialMessages},
        ),
      ),
    )).then((_) => ref.invalidate(chatSessionsProvider));
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onNewChat;
  const _EmptyState({required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.psychology_rounded, size: 48, color: cs.primary),
          ),
          const SizedBox(height: 24),
          Text('MediNova AI', style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Your personal health assistant.\nAsk about symptoms, medications & more.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 32),
          FilledButton.icon(
            onPressed: onNewChat,
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('Start a Conversation'),
          ),
        ],
      ),
    );
  }
}

// ── Conversation Screen ───────────────────────────────────────────────────────

class _ChatConversationScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> sessionArg;
  const _ChatConversationScreen({required this.sessionArg});

  @override
  ConsumerState<_ChatConversationScreen> createState() => _ChatConversationState();
}

class _ChatConversationState extends ConsumerState<_ChatConversationScreen> {
  final _ctrl       = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // No need to initSession here anymore since we did it in ProviderScope override!
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    
    // Collect context data
    Map<String, dynamic> contextData = {};
    
    final healthData = ref.read(healthDataProvider).value;
    if (healthData != null && !healthData.containsKey('error')) {
      contextData['healthMetrics'] = healthData;
    }
    
    final prescriptions = ref.read(prescriptionsProvider).value;
    if (prescriptions != null && prescriptions.isNotEmpty) {
      // Just take the most recent prescription's analysis to avoid token bloat
      contextData['latestPrescription'] = prescriptions.first.aiAnalysis ?? 'No analysis available for latest prescription';
    }
    
    final reports = ref.read(reportsProvider).value;
    if (reports != null && reports.isNotEmpty) {
      final latestReport = reports.first;
      contextData['latestReport'] = {
        'type': latestReport['documentType'],
        'analysis': latestReport['aiAnalysis']
      };
    }
    
    ref.read(_chatProvider.notifier).sendMessage(text, contextData: contextData.isNotEmpty ? contextData : null);
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Quick prompt chips
  static const _prompts = [
    '🩺 Check my symptoms',
    '💊 Medication advice',
    '📋 Explain my report',
    '🥗 Diet tips',
    '😴 Improve my sleep',
  ];

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_chatProvider);
    final notifier = ref.read(_chatProvider.notifier);
    final cs       = Theme.of(context).colorScheme;
    final tt       = Theme.of(context).textTheme;

    ref.listen(_chatProvider, (_, __) {
      Future.delayed(const Duration(milliseconds: 50), _scrollToBottom);
    });

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.psychology_rounded, color: cs.primary, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MediNova AI', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              Text('Health Assistant', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            ],
          ),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                return _MessageBubble(message: msg);
              },
            ),
          ),

          // Quick prompts (only show at start)
          if (messages.length == 1)
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _prompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ActionChip(
                  label: Text(_prompts[i], style: tt.labelSmall),
                  onPressed: () {
                    _ctrl.text = _prompts[i].replaceAll(RegExp(r'^[^\w]+'), '');
                    _send();
                  },
                ),
              ),
            ),
          if (messages.length == 1) const SizedBox(height: 8),

          // Input bar
          _ChatInputBar(controller: _ctrl, onSend: _send),
        ],
      ),
    );
  }
}

// ── Message bubble ─────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final _ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs     = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: cs.primaryContainer,
              child: Icon(Icons.psychology_rounded, size: 14, color: cs.primary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? cs.primary : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
              ),
              child: message.text.isEmpty
                  ? _TypingDots(color: cs.onSurfaceVariant)
                  : Text(
                      message.text,
                      style: TextStyle(
                        color: isUser ? cs.onPrimary : cs.onSurface,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: cs.primaryContainer,
            child: Icon(Icons.psychology_rounded, size: 14, color: cs.primary),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: _TypingDots(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  final Color color;
  const _TypingDots({required this.color});
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          final phase = (_ctrl.value * 3 - i).clamp(0.0, 1.0);
          final opacity = (0.3 + 0.7 * (phase < 0.5 ? phase * 2 : (1 - phase) * 2)).clamp(0.3, 1.0);
          return Container(
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            width: 7, height: 7,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: opacity),
              shape: BoxShape.circle,
            ),
          );
        }),
      ),
    );
  }
}

// ── Chat input bar ─────────────────────────────────────────────────────────────

class _ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatInputBar({required this.controller, required this.onSend});
  @override
  State<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<_ChatInputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final has = widget.controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask about your health…',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => widget.onSend(),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: _hasText
                  ? IconButton.filled(
                      icon: const Icon(Icons.send_rounded),
                      onPressed: widget.onSend,
                      style: IconButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        minimumSize: const Size(48, 48),
                      ),
                    )
                  : IconButton.filledTonal(
                      icon: const Icon(Icons.mic_rounded),
                      onPressed: () {},
                      style: IconButton.styleFrom(minimumSize: const Size(48, 48)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
