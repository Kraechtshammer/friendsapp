import '../../domain/chat_app.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/labels.dart';
import '../common.dart';
import '../kept_icon.dart';
import '../material.dart';
import '../widgets/kept_card.dart';

/// "How do I get a chat link?": per app, where the username or link is
/// found. Only what the developer tested is on this page (02-design.md §8,
/// 2026-11-18). [current] (the app chosen on the edit page) comes first.
class ChatLinkHelpPage extends StatelessWidget {
  const ChatLinkHelpPage({super.key, this.current});

  final ChatApp? current;

  static String? _text(ChatApp app, AppLocalizations l10n) => switch (app) {
    ChatApp.telegram => l10n.chatLinkHelpTelegram,
    ChatApp.discord => l10n.chatLinkHelpDiscord,
    ChatApp.linkedin => l10n.chatLinkHelpLinkedin,
    ChatApp.instagram => l10n.chatLinkHelpInstagram,
    ChatApp.snapchat => l10n.chatLinkHelpSnapchat,
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final apps = [
      for (final app in ChatApp.values)
        if (_text(app, l10n) != null) app,
    ];
    final current = this.current;
    if (current != null && apps.remove(current)) apps.insert(0, current);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.chatLinkHelpTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.chatLinkHelpIntro, style: context.text.bodyLarge),
          const SizedBox(height: 16),
          for (final app in apps) ...[
            KeptCard(
              small: true,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  KeptIcon(messengerIcon(app), size: 32),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text(
                          messengerLabel(app, l10n),
                          style: context.text.titleMedium,
                        ),
                        Text(_text(app, l10n)!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Text(l10n.chatLinkHelpOthers, style: context.text.bodyMedium),
        ],
      ),
    );
  }
}
