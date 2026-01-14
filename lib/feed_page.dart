
import 'package:flutter/material.dart';
import 'package:nextlevel/l10n/app_localizations.dart';
import 'styles.dart';

class FeedPage extends StatelessWidget {
  const FeedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Text(l10n.feedTitle, style: kPageTitleTextStyle),
    );
  }
}
