enum RegistryProvider {
  classeViva,
  didUp,
  classeVivaDocente,
}

extension RegistryProviderValue on RegistryProvider {
  String get storageValue {
    switch (this) {
      case RegistryProvider.classeViva:
        return 'classeviva';
      case RegistryProvider.didUp:
        return 'didup';
      case RegistryProvider.classeVivaDocente:
        return 'classeviva_docente';
    }
  }

  String get label {
    switch (this) {
      case RegistryProvider.classeViva:
        return 'ClasseViva';
      case RegistryProvider.didUp:
        return 'didUP';
      case RegistryProvider.classeVivaDocente:
        return 'ClasseViva (SPID/CIE)';
    }
  }

}

RegistryProvider? registryProviderFromStorage(String? value) {
  switch (value) {
    case 'classeviva':
      return RegistryProvider.classeViva;
    case 'didup':
      return RegistryProvider.didUp;
    case 'classeviva_docente':
      return RegistryProvider.classeVivaDocente;
    default:
      return null;
  }
}
