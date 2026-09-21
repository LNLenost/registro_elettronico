enum RegistryProvider {
  classeViva,
  didUp,
}

extension RegistryProviderValue on RegistryProvider {
  String get storageValue {
    switch (this) {
      case RegistryProvider.classeViva:
        return 'classeviva';
      case RegistryProvider.didUp:
        return 'didup';
    }
  }

  String get label {
    switch (this) {
      case RegistryProvider.classeViva:
        return 'ClasseViva';
      case RegistryProvider.didUp:
        return 'didUP';
    }
  }

}

RegistryProvider? registryProviderFromStorage(String? value) {
  switch (value) {
    case 'classeviva':
      return RegistryProvider.classeViva;
    case 'didup':
      return RegistryProvider.didUp;
    default:
      return null;
  }
}
