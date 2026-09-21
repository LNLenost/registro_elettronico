import 'package:flutter/material.dart';
import 'package:registro_elettronico/core/infrastructure/app_injection.dart';
import 'package:registro_elettronico/feature/authentication/data/datasource/registry_provider_preferences.dart';
import 'package:registro_elettronico/feature/authentication/domain/model/registry_provider.dart';
import 'package:registro_elettronico/feature/authentication/presentation/login_page.dart';

class RegistryProviderPage extends StatelessWidget {
  const RegistryProviderPage({Key? key}) : super(key: key);

  Future<void> _select(BuildContext context, RegistryProvider provider) async {
    await RegistryProviderPreferences(sl()).write(provider);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => LoginPage(provider: provider)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scegli il registro')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Quale registro vuoi usare?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => _select(context, RegistryProvider.classeViva),
              child: const Text('ClasseViva'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _select(context, RegistryProvider.didUp),
              child: const Text('didUP'),
            ),
          ],
        ),
      ),
    );
  }
}
