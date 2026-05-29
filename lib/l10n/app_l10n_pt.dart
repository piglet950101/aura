// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppL10nPt extends AppL10n {
  AppL10nPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'AURA';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Apagar';

  @override
  String get back => 'Voltar';

  @override
  String get add => 'Adicionar';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '$count dia',
    );
    return '$_temp0';
  }

  @override
  String get homeGreeting => 'Olá';

  @override
  String get last30Days => 'Últimos 30 dias';

  @override
  String get painNone => 'Sem dor de cabeça';

  @override
  String get painLeve => 'Dor leve';

  @override
  String get painModerada => 'Moderada';

  @override
  String get painForte => 'Forte';

  @override
  String get medicationTaken => 'Tomou medicação';

  @override
  String get medicationSos => 'Medicação SOS';

  @override
  String get registerCrisis => 'Registar crise';

  @override
  String get qaCalendar => 'Calendário';

  @override
  String get qaShare => 'Partilhar';

  @override
  String get qaMedication => 'Medicação';

  @override
  String get qaAppointment => 'Consulta Médica';

  @override
  String get qaData => 'Dados';

  @override
  String get settings => 'Definições';

  @override
  String get welcomeTitle => 'Bem-vindo';

  @override
  String get welcomeBody =>
      'Regista a tua primeira crise quando precisares. Os teus dados ficam neste dispositivo e na tua conta.';

  @override
  String summaryLoadError(Object error) {
    return 'Não foi possível carregar o resumo: $error';
  }

  @override
  String get medicationWorkedTitle => 'A medicação funcionou?';

  @override
  String get respNone => 'Nenhuma';

  @override
  String get respPartial => 'Parcial';

  @override
  String get respTotal => 'Total';

  @override
  String get calendar => 'Calendário';

  @override
  String get monthPrev => 'Mês anterior';

  @override
  String get monthNext => 'Mês seguinte';

  @override
  String get statCrises => 'Crises';

  @override
  String get statAvgIntensity => 'Intensidade média';

  @override
  String get statAffectedDays => 'Dias afetados';

  @override
  String get legendLeve => 'Leve';

  @override
  String get legendModerada => 'Moderada';

  @override
  String get legendForte => 'Forte';

  @override
  String get tierSemDor => 'Sem dor';

  @override
  String get dayFuture => 'Dia futuro.';

  @override
  String get noCrisesThisDay => 'Sem crises registadas neste dia.';

  @override
  String get registerForThisDay => 'Registar para este dia';

  @override
  String intensityValue(int n) {
    return 'Intensidade $n';
  }

  @override
  String get auraTag => 'aura';

  @override
  String calendarLoadError(Object error) {
    return 'Não foi possível carregar o calendário: $error';
  }

  @override
  String get newCrisis => 'Nova crise';

  @override
  String get editCrisis => 'Editar crise';

  @override
  String get crisisSaved => 'Crise registada';

  @override
  String get crisisUpdated => 'Crise atualizada';

  @override
  String saveError(Object error) {
    return 'Erro ao guardar: $error';
  }

  @override
  String get deleteCrisisTitle => 'Apagar crise';

  @override
  String get deleteCrisisBody => 'Esta crise será removida permanentemente.';

  @override
  String deleteError(Object error) {
    return 'Erro ao apagar: $error';
  }

  @override
  String get formIntro => 'Regista o essencial em poucos toques.';

  @override
  String get sectionIntensity => 'Intensidade da dor';

  @override
  String get sectionAura => 'Aura';

  @override
  String get sectionSymptoms => 'Sintomas';

  @override
  String get sectionMedicationTaken => 'Medicação tomada';

  @override
  String get sectionNotesOptional => 'Notas adicionais · opcional';

  @override
  String get notesHint => 'Algo a registar sobre esta crise?';

  @override
  String get saveCrisis => 'Guardar crise';

  @override
  String get symptomNausea => 'Náusea';

  @override
  String get symptomVomiting => 'Vómito';

  @override
  String get symptomPhotophobia => 'Sensibilidade à luz';

  @override
  String get symptomPhonophobia => 'Sensibilidade ao som';

  @override
  String get symptomDizziness => 'Tontura';

  @override
  String get symptomFatigue => 'Fadiga';

  @override
  String get symptomOther => 'Outro sintoma';

  @override
  String get symptomAura => 'Aura';

  @override
  String get noSymptoms => 'Sem sintomas';

  @override
  String get nothingTaken => 'Nada tomado';

  @override
  String get noMedicationLabel => 'Nenhuma medicação';

  @override
  String get addAnother => 'Adicionar outra';

  @override
  String get changeAction => 'Mudar';

  @override
  String get addAction => 'Adicionar';

  @override
  String get noMedsHint => 'Ainda não tens medicações. Adiciona-as no menu Medicação.';

  @override
  String get medication => 'Medicação';

  @override
  String get noMedications => 'Sem medicações';

  @override
  String get noMedicationsBody =>
      'Adiciona os teus medicamentos (SOS ou preventivos) para os registares rapidamente durante uma crise.';

  @override
  String get addMedication => 'Adicionar medicação';

  @override
  String medsLoadError(Object error) {
    return 'Não foi possível carregar as medicações: $error';
  }

  @override
  String get newMedication => 'Nova medicação';

  @override
  String get editMedication => 'Editar medicação';

  @override
  String get fieldName => 'Nome';

  @override
  String get medNameHint => 'Ex.: Sumatriptano';

  @override
  String get fieldDoseOptional => 'Dose (mg) · opcional';

  @override
  String get doseHint => 'Ex.: 50';

  @override
  String get fieldType => 'Tipo';

  @override
  String get kindSos => 'SOS';

  @override
  String get kindSosDesc => 'Tomada durante a crise';

  @override
  String get kindPreventive => 'Preventiva';

  @override
  String get kindPreventiveDesc => 'Diária / preventiva';

  @override
  String get defaultMed => 'Predefinida';

  @override
  String get defaultMedDesc => 'Aparece já selecionada ao registar uma crise.';

  @override
  String get archiveMedication => 'Arquivar medicação';

  @override
  String get archiveMedBody =>
      'A medicação deixa de aparecer na lista, mas o histórico de crises mantém-se intacto.';

  @override
  String get archive => 'Arquivar';

  @override
  String get sectionProfile => 'Perfil';

  @override
  String get profileSubtitle => 'Nome e dados para o relatório médico';

  @override
  String get sectionPrivacyData => 'Privacidade e dados';

  @override
  String get privacyNote =>
      'Os teus dados ficam no dispositivo e num servidor europeu (Frankfurt), isolados por utilizador, sem anúncios.';

  @override
  String get exportData => 'Exportar os meus dados';

  @override
  String get exportSubtitle => 'Recebe tudo em ficheiro JSON';

  @override
  String get deleteAccount => 'Apagar conta e dados';

  @override
  String get deleteAccountSubtitle => 'Remove tudo, sem retorno';

  @override
  String get sectionAbout => 'Sobre';

  @override
  String get aboutLine => 'AURA · Diário da Enxaqueca';

  @override
  String get deleteConfirmBody =>
      'Isto apaga permanentemente todas as crises, medicação e perfil, no dispositivo e no servidor. Para confirmar, escreve APAGAR.';

  @override
  String get confirmWord => 'APAGAR';

  @override
  String get accountDeleted => 'Conta e dados apagados';

  @override
  String exportError(Object error) {
    return 'Erro ao exportar: $error';
  }

  @override
  String get exportSubject => 'Os meus dados · AURA';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get langPtPt => 'Português (Portugal)';

  @override
  String get langPtBr => 'Português (Brasil)';

  @override
  String get langEn => 'English';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileIntro => 'Opcional — aparece no cabeçalho do relatório para o médico.';

  @override
  String get profileNameHint => 'O teu nome';

  @override
  String get fieldBirthYear => 'Ano de nascimento';

  @override
  String get birthYearHint => 'Ex.: 1990';

  @override
  String get fieldSex => 'Sexo';

  @override
  String get sexF => 'Feminino';

  @override
  String get sexM => 'Masculino';

  @override
  String get sexOther => 'Outro';

  @override
  String get sexNa => 'Prefiro não dizer';

  @override
  String get reportTitle => 'Relatório médico';

  @override
  String get periodLast30 => 'Últimos 30 dias';

  @override
  String get periodLast90 => 'Últimos 90 dias';

  @override
  String reportError(Object error) {
    return 'Não foi possível gerar o relatório: $error';
  }

  @override
  String get statsTitle => 'Dados';

  @override
  String get period30 => '30 dias';

  @override
  String get period90 => '90 dias';

  @override
  String get statIntensity => 'Intensidade';

  @override
  String get statDiasSos => 'Dias SOS';

  @override
  String get sectionCrisesPerWeek => 'Crises por semana';

  @override
  String get sectionIntensityDays => 'Intensidade (dias)';

  @override
  String get sectionFrequentSymptoms => 'Sintomas mais frequentes';

  @override
  String weekShort(int n) {
    return 'S$n';
  }

  @override
  String statsError(Object error) {
    return 'Não foi possível carregar os dados: $error';
  }
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppL10nPtBr extends AppL10nPt {
  AppL10nPtBr() : super('pt_BR');

  @override
  String get appTitle => 'AURA';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get back => 'Voltar';

  @override
  String get add => 'Adicionar';

  @override
  String get yes => 'Sim';

  @override
  String get no => 'Não';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '$count dia',
    );
    return '$_temp0';
  }

  @override
  String get homeGreeting => 'Olá';

  @override
  String get last30Days => 'Últimos 30 dias';

  @override
  String get painNone => 'Sem dor de cabeça';

  @override
  String get painLeve => 'Dor leve';

  @override
  String get painModerada => 'Moderada';

  @override
  String get painForte => 'Forte';

  @override
  String get medicationTaken => 'Tomou medicação';

  @override
  String get medicationSos => 'Medicação SOS';

  @override
  String get registerCrisis => 'Registrar crise';

  @override
  String get qaCalendar => 'Calendário';

  @override
  String get qaShare => 'Compartilhar';

  @override
  String get qaMedication => 'Medicação';

  @override
  String get qaAppointment => 'Consulta Médica';

  @override
  String get qaData => 'Dados';

  @override
  String get settings => 'Configurações';

  @override
  String get welcomeTitle => 'Bem-vindo';

  @override
  String get welcomeBody =>
      'Registre sua primeira crise quando precisar. Seus dados ficam neste dispositivo e na sua conta.';

  @override
  String summaryLoadError(Object error) {
    return 'Não foi possível carregar o resumo: $error';
  }

  @override
  String get medicationWorkedTitle => 'A medicação funcionou?';

  @override
  String get respNone => 'Nenhuma';

  @override
  String get respPartial => 'Parcial';

  @override
  String get respTotal => 'Total';

  @override
  String get calendar => 'Calendário';

  @override
  String get monthPrev => 'Mês anterior';

  @override
  String get monthNext => 'Mês seguinte';

  @override
  String get statCrises => 'Crises';

  @override
  String get statAvgIntensity => 'Intensidade média';

  @override
  String get statAffectedDays => 'Dias afetados';

  @override
  String get legendLeve => 'Leve';

  @override
  String get legendModerada => 'Moderada';

  @override
  String get legendForte => 'Forte';

  @override
  String get tierSemDor => 'Sem dor';

  @override
  String get dayFuture => 'Dia futuro.';

  @override
  String get noCrisesThisDay => 'Sem crises registradas neste dia.';

  @override
  String get registerForThisDay => 'Registrar para este dia';

  @override
  String intensityValue(int n) {
    return 'Intensidade $n';
  }

  @override
  String get auraTag => 'aura';

  @override
  String calendarLoadError(Object error) {
    return 'Não foi possível carregar o calendário: $error';
  }

  @override
  String get newCrisis => 'Nova crise';

  @override
  String get editCrisis => 'Editar crise';

  @override
  String get crisisSaved => 'Crise registrada';

  @override
  String get crisisUpdated => 'Crise atualizada';

  @override
  String saveError(Object error) {
    return 'Erro ao salvar: $error';
  }

  @override
  String get deleteCrisisTitle => 'Excluir crise';

  @override
  String get deleteCrisisBody => 'Esta crise será removida permanentemente.';

  @override
  String deleteError(Object error) {
    return 'Erro ao excluir: $error';
  }

  @override
  String get formIntro => 'Registre o essencial em poucos toques.';

  @override
  String get sectionIntensity => 'Intensidade da dor';

  @override
  String get sectionAura => 'Aura';

  @override
  String get sectionSymptoms => 'Sintomas';

  @override
  String get sectionMedicationTaken => 'Medicação tomada';

  @override
  String get sectionNotesOptional => 'Notas adicionais · opcional';

  @override
  String get notesHint => 'Algo a registrar sobre esta crise?';

  @override
  String get saveCrisis => 'Salvar crise';

  @override
  String get symptomNausea => 'Náusea';

  @override
  String get symptomVomiting => 'Vômito';

  @override
  String get symptomPhotophobia => 'Sensibilidade à luz';

  @override
  String get symptomPhonophobia => 'Sensibilidade ao som';

  @override
  String get symptomDizziness => 'Tontura';

  @override
  String get symptomFatigue => 'Fadiga';

  @override
  String get symptomOther => 'Outro sintoma';

  @override
  String get symptomAura => 'Aura';

  @override
  String get noSymptoms => 'Sem sintomas';

  @override
  String get nothingTaken => 'Nada tomado';

  @override
  String get noMedicationLabel => 'Nenhuma medicação';

  @override
  String get addAnother => 'Adicionar outra';

  @override
  String get changeAction => 'Mudar';

  @override
  String get addAction => 'Adicionar';

  @override
  String get noMedsHint => 'Você ainda não tem medicações. Adicione-as no menu Medicação.';

  @override
  String get medication => 'Medicação';

  @override
  String get noMedications => 'Sem medicações';

  @override
  String get noMedicationsBody =>
      'Adicione seus medicamentos (SOS ou preventivos) para registrá-los rapidamente durante uma crise.';

  @override
  String get addMedication => 'Adicionar medicação';

  @override
  String medsLoadError(Object error) {
    return 'Não foi possível carregar as medicações: $error';
  }

  @override
  String get newMedication => 'Nova medicação';

  @override
  String get editMedication => 'Editar medicação';

  @override
  String get fieldName => 'Nome';

  @override
  String get medNameHint => 'Ex.: Sumatriptano';

  @override
  String get fieldDoseOptional => 'Dose (mg) · opcional';

  @override
  String get doseHint => 'Ex.: 50';

  @override
  String get fieldType => 'Tipo';

  @override
  String get kindSos => 'SOS';

  @override
  String get kindSosDesc => 'Tomada durante a crise';

  @override
  String get kindPreventive => 'Preventiva';

  @override
  String get kindPreventiveDesc => 'Diária / preventiva';

  @override
  String get defaultMed => 'Padrão';

  @override
  String get defaultMedDesc => 'Aparece já selecionada ao registrar uma crise.';

  @override
  String get archiveMedication => 'Arquivar medicação';

  @override
  String get archiveMedBody =>
      'A medicação deixa de aparecer na lista, mas o histórico de crises permanece intacto.';

  @override
  String get archive => 'Arquivar';

  @override
  String get sectionProfile => 'Perfil';

  @override
  String get profileSubtitle => 'Nome e dados para o relatório médico';

  @override
  String get sectionPrivacyData => 'Privacidade e dados';

  @override
  String get privacyNote =>
      'Seus dados ficam no dispositivo e em um servidor europeu (Frankfurt), isolados por usuário, sem anúncios.';

  @override
  String get exportData => 'Exportar meus dados';

  @override
  String get exportSubtitle => 'Receba tudo em arquivo JSON';

  @override
  String get deleteAccount => 'Excluir conta e dados';

  @override
  String get deleteAccountSubtitle => 'Remove tudo, sem retorno';

  @override
  String get sectionAbout => 'Sobre';

  @override
  String get aboutLine => 'AURA · Diário da Enxaqueca';

  @override
  String get deleteConfirmBody =>
      'Isto exclui permanentemente todas as crises, medicação e perfil, no dispositivo e no servidor. Para confirmar, escreva EXCLUIR.';

  @override
  String get confirmWord => 'EXCLUIR';

  @override
  String get accountDeleted => 'Conta e dados excluídos';

  @override
  String exportError(Object error) {
    return 'Erro ao exportar: $error';
  }

  @override
  String get exportSubject => 'Meus dados · AURA';

  @override
  String get sectionLanguage => 'Idioma';

  @override
  String get langPtPt => 'Português (Portugal)';

  @override
  String get langPtBr => 'Português (Brasil)';

  @override
  String get langEn => 'English';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileIntro => 'Opcional — aparece no cabeçalho do relatório para o médico.';

  @override
  String get profileNameHint => 'Seu nome';

  @override
  String get fieldBirthYear => 'Ano de nascimento';

  @override
  String get birthYearHint => 'Ex.: 1990';

  @override
  String get fieldSex => 'Sexo';

  @override
  String get sexF => 'Feminino';

  @override
  String get sexM => 'Masculino';

  @override
  String get sexOther => 'Outro';

  @override
  String get sexNa => 'Prefiro não dizer';

  @override
  String get reportTitle => 'Relatório médico';

  @override
  String get periodLast30 => 'Últimos 30 dias';

  @override
  String get periodLast90 => 'Últimos 90 dias';

  @override
  String reportError(Object error) {
    return 'Não foi possível gerar o relatório: $error';
  }

  @override
  String get statsTitle => 'Dados';

  @override
  String get period30 => '30 dias';

  @override
  String get period90 => '90 dias';

  @override
  String get statIntensity => 'Intensidade';

  @override
  String get statDiasSos => 'Dias SOS';

  @override
  String get sectionCrisesPerWeek => 'Crises por semana';

  @override
  String get sectionIntensityDays => 'Intensidade (dias)';

  @override
  String get sectionFrequentSymptoms => 'Sintomas mais frequentes';

  @override
  String weekShort(int n) {
    return 'S$n';
  }

  @override
  String statsError(Object error) {
    return 'Não foi possível carregar os dados: $error';
  }
}
