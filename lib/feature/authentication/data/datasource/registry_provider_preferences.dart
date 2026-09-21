import 'package:registro_elettronico/feature/authentication/domain/model/registry_provider.dart';
import 'package:registro_elettronico/utils/constants/preferences_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegistryProviderPreferences {
  final SharedPreferences preferences;

  RegistryProviderPreferences(this.preferences);

  RegistryProvider? read() => registryProviderFromStorage(
        preferences.getString(PrefsConstants.registryProvider),
      );

  Future<void> write(RegistryProvider provider) => preferences.setString(
        PrefsConstants.registryProvider,
        provider.storageValue,
      );
}
