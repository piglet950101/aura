import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app's active locale. Defaults to PT-PT; seeded from the stored profile
/// locale at startup and updated by the Idioma picker (which also persists it).
final localeProvider = StateProvider<Locale>((ref) => const Locale('pt'));

/// Stored locale codes ↔ [Locale]. Codes match `profiles.locale`
/// ('pt-PT' | 'pt-BR' | 'en').
Locale localeFromCode(String? code) {
  switch (code) {
    case 'pt-BR':
    case 'pt_BR':
      return const Locale('pt', 'BR');
    case 'en':
      return const Locale('en');
    default:
      return const Locale('pt');
  }
}

String localeToCode(Locale locale) {
  if (locale.languageCode == 'en') return 'en';
  if (locale.countryCode == 'BR') return 'pt-BR';
  return 'pt-PT';
}
