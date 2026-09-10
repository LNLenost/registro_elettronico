import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/localizations/app_localizations.dart';

class DonateDialog extends StatefulWidget {
  DonateDialog({Key? key}) : super(key: key);

  @override
  _DonateDialogState createState() => _DonateDialogState();
}

class _DonateDialogState extends State<DonateDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            title: Text(AppLocalizations.of(context)!.translate('donation')!),
            subtitle: Text(AppLocalizations.of(context)!
                .translate('donation_thanks')!),
            trailing: Text('0.99€'),
            onTap: () {},
          )
        ],
      ),
    );
  }
}
