import 'package:flutter_test/flutter_test.dart';
import 'package:registro_elettronico/feature/authentication/domain/model/registry_provider.dart';

void main() {
  test('registry providers round-trip through storage values', () {
    for (final provider in RegistryProvider.values) {
      expect(
        registryProviderFromStorage(provider.storageValue),
        provider,
      );
    }
  });

  test('unknown provider values are rejected', () {
    expect(registryProviderFromStorage(null), isNull);
    expect(registryProviderFromStorage('unknown'), isNull);
  });
}
