import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_l10n_en.dart';
import 'app_l10n_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppL10n
/// returned by `AppL10n.of(context)`.
///
/// Applications need to include `AppL10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppL10n.localizationsDelegates,
///   supportedLocales: AppL10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppL10n.supportedLocales
/// property.
abstract class AppL10n {
  AppL10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppL10n of(BuildContext context) {
    return Localizations.of<AppL10n>(context, AppL10n)!;
  }

  static const LocalizationsDelegate<AppL10n> delegate = _AppL10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'AURA'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In pt, this message translates to:
  /// **'Apagar'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @add.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get add;

  /// No description provided for @yes.
  ///
  /// In pt, this message translates to:
  /// **'Sim'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In pt, this message translates to:
  /// **'Não'**
  String get no;

  /// No description provided for @days.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{{count} dia} other{{count} dias}}'**
  String days(int count);

  /// No description provided for @homeGreeting.
  ///
  /// In pt, this message translates to:
  /// **'Olá'**
  String get homeGreeting;

  /// No description provided for @last30Days.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 30 dias'**
  String get last30Days;

  /// No description provided for @painNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem dor de cabeça'**
  String get painNone;

  /// No description provided for @painLeve.
  ///
  /// In pt, this message translates to:
  /// **'Dor leve'**
  String get painLeve;

  /// No description provided for @painModerada.
  ///
  /// In pt, this message translates to:
  /// **'Moderada'**
  String get painModerada;

  /// No description provided for @painForte.
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get painForte;

  /// No description provided for @medicationTaken.
  ///
  /// In pt, this message translates to:
  /// **'Tomou medicação'**
  String get medicationTaken;

  /// No description provided for @medicationSos.
  ///
  /// In pt, this message translates to:
  /// **'Medicação SOS'**
  String get medicationSos;

  /// No description provided for @registerCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Registar crise'**
  String get registerCrisis;

  /// No description provided for @qaCalendar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get qaCalendar;

  /// No description provided for @qaShare.
  ///
  /// In pt, this message translates to:
  /// **'Partilhar'**
  String get qaShare;

  /// No description provided for @qaMedication.
  ///
  /// In pt, this message translates to:
  /// **'Medicação'**
  String get qaMedication;

  /// No description provided for @qaAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Preparar Consulta'**
  String get qaAppointment;

  /// No description provided for @qaData.
  ///
  /// In pt, this message translates to:
  /// **'Estatísticas'**
  String get qaData;

  /// No description provided for @settings.
  ///
  /// In pt, this message translates to:
  /// **'Definições'**
  String get settings;

  /// No description provided for @welcomeTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo'**
  String get welcomeTitle;

  /// No description provided for @welcomeBody.
  ///
  /// In pt, this message translates to:
  /// **'Regista a tua primeira crise quando precisares. Os teus dados ficam neste dispositivo e na tua conta.'**
  String get welcomeBody;

  /// No description provided for @summaryLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o resumo: {error}'**
  String summaryLoadError(Object error);

  /// No description provided for @medicationWorkedTitle.
  ///
  /// In pt, this message translates to:
  /// **'A medicação funcionou?'**
  String get medicationWorkedTitle;

  /// No description provided for @respNone.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get respNone;

  /// No description provided for @respPartial.
  ///
  /// In pt, this message translates to:
  /// **'Parcial'**
  String get respPartial;

  /// No description provided for @respTotal.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get respTotal;

  /// No description provided for @calendar.
  ///
  /// In pt, this message translates to:
  /// **'Calendário'**
  String get calendar;

  /// No description provided for @monthPrev.
  ///
  /// In pt, this message translates to:
  /// **'Mês anterior'**
  String get monthPrev;

  /// No description provided for @monthNext.
  ///
  /// In pt, this message translates to:
  /// **'Mês seguinte'**
  String get monthNext;

  /// No description provided for @statCrises.
  ///
  /// In pt, this message translates to:
  /// **'Crises'**
  String get statCrises;

  /// No description provided for @statAvgIntensity.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade média'**
  String get statAvgIntensity;

  /// No description provided for @statAffectedDays.
  ///
  /// In pt, this message translates to:
  /// **'Dias afetados'**
  String get statAffectedDays;

  /// No description provided for @legendLeve.
  ///
  /// In pt, this message translates to:
  /// **'Leve'**
  String get legendLeve;

  /// No description provided for @legendModerada.
  ///
  /// In pt, this message translates to:
  /// **'Moderada'**
  String get legendModerada;

  /// No description provided for @legendForte.
  ///
  /// In pt, this message translates to:
  /// **'Forte'**
  String get legendForte;

  /// No description provided for @tierSemDor.
  ///
  /// In pt, this message translates to:
  /// **'Sem dor'**
  String get tierSemDor;

  /// No description provided for @dayFuture.
  ///
  /// In pt, this message translates to:
  /// **'Dia futuro.'**
  String get dayFuture;

  /// No description provided for @noCrisesThisDay.
  ///
  /// In pt, this message translates to:
  /// **'Sem crises registadas neste dia.'**
  String get noCrisesThisDay;

  /// No description provided for @registerForThisDay.
  ///
  /// In pt, this message translates to:
  /// **'Registar para este dia'**
  String get registerForThisDay;

  /// No description provided for @intensityValue.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade {n}'**
  String intensityValue(int n);

  /// No description provided for @auraTag.
  ///
  /// In pt, this message translates to:
  /// **'aura'**
  String get auraTag;

  /// No description provided for @camAlertTitle.
  ///
  /// In pt, this message translates to:
  /// **'Alerta: Risco de CAM'**
  String get camAlertTitle;

  /// No description provided for @camAlertBody.
  ///
  /// In pt, this message translates to:
  /// **'Registou tomas de medicação SOS em {days} dias este mês. O uso excessivo pode causar Cefaleia por Abuso de Medicação. Recomenda-se partilhar este dado com o seu neurologista.'**
  String camAlertBody(int days);

  /// No description provided for @calendarLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o calendário: {error}'**
  String calendarLoadError(Object error);

  /// No description provided for @daySemantic.
  ///
  /// In pt, this message translates to:
  /// **'Dia {n}'**
  String daySemantic(int n);

  /// No description provided for @crisesCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 crise} other{{count} crises}}'**
  String crisesCount(int count);

  /// No description provided for @withAura.
  ///
  /// In pt, this message translates to:
  /// **', com aura'**
  String get withAura;

  /// No description provided for @newCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Nova crise'**
  String get newCrisis;

  /// No description provided for @editCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Editar crise'**
  String get editCrisis;

  /// No description provided for @crisisSaved.
  ///
  /// In pt, this message translates to:
  /// **'Crise registada'**
  String get crisisSaved;

  /// No description provided for @crisisUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Crise atualizada'**
  String get crisisUpdated;

  /// No description provided for @saveError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao guardar: {error}'**
  String saveError(Object error);

  /// No description provided for @deleteCrisisTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar crise'**
  String get deleteCrisisTitle;

  /// No description provided for @deleteCrisisBody.
  ///
  /// In pt, this message translates to:
  /// **'Esta crise será removida permanentemente.'**
  String get deleteCrisisBody;

  /// No description provided for @deleteError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao apagar: {error}'**
  String deleteError(Object error);

  /// No description provided for @formIntro.
  ///
  /// In pt, this message translates to:
  /// **'Regista o essencial em poucos toques.'**
  String get formIntro;

  /// No description provided for @sectionIntensity.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade da dor'**
  String get sectionIntensity;

  /// No description provided for @sectionAura.
  ///
  /// In pt, this message translates to:
  /// **'Aura'**
  String get sectionAura;

  /// No description provided for @sectionMenstruation.
  ///
  /// In pt, this message translates to:
  /// **'Menstruação'**
  String get sectionMenstruation;

  /// No description provided for @sectionSymptoms.
  ///
  /// In pt, this message translates to:
  /// **'Sintomas'**
  String get sectionSymptoms;

  /// No description provided for @sectionMedicationTaken.
  ///
  /// In pt, this message translates to:
  /// **'Medicação tomada'**
  String get sectionMedicationTaken;

  /// No description provided for @sectionNotesOptional.
  ///
  /// In pt, this message translates to:
  /// **'Notas adicionais · opcional'**
  String get sectionNotesOptional;

  /// No description provided for @notesHint.
  ///
  /// In pt, this message translates to:
  /// **'Algo a registar sobre esta crise?'**
  String get notesHint;

  /// No description provided for @saveCrisis.
  ///
  /// In pt, this message translates to:
  /// **'Guardar crise'**
  String get saveCrisis;

  /// No description provided for @intensityScaleMin.
  ///
  /// In pt, this message translates to:
  /// **'leve'**
  String get intensityScaleMin;

  /// No description provided for @intensityScaleMax.
  ///
  /// In pt, this message translates to:
  /// **'incapacitante'**
  String get intensityScaleMax;

  /// No description provided for @intensityLabelMild.
  ///
  /// In pt, this message translates to:
  /// **'LEVE'**
  String get intensityLabelMild;

  /// No description provided for @intensityLabelModerate.
  ///
  /// In pt, this message translates to:
  /// **'MODERADA'**
  String get intensityLabelModerate;

  /// No description provided for @intensityLabelIntense.
  ///
  /// In pt, this message translates to:
  /// **'INTENSA'**
  String get intensityLabelIntense;

  /// No description provided for @intensityLabelDisabling.
  ///
  /// In pt, this message translates to:
  /// **'INCAPACITANTE'**
  String get intensityLabelDisabling;

  /// No description provided for @intensityOutOf.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade {n} de 10'**
  String intensityOutOf(int n);

  /// No description provided for @symptomNausea.
  ///
  /// In pt, this message translates to:
  /// **'Náusea'**
  String get symptomNausea;

  /// No description provided for @symptomVomiting.
  ///
  /// In pt, this message translates to:
  /// **'Vómito'**
  String get symptomVomiting;

  /// No description provided for @symptomPhotophobia.
  ///
  /// In pt, this message translates to:
  /// **'Sensibilidade à luz'**
  String get symptomPhotophobia;

  /// No description provided for @symptomPhonophobia.
  ///
  /// In pt, this message translates to:
  /// **'Sensibilidade ao som'**
  String get symptomPhonophobia;

  /// No description provided for @symptomDizziness.
  ///
  /// In pt, this message translates to:
  /// **'Tontura'**
  String get symptomDizziness;

  /// No description provided for @symptomFatigue.
  ///
  /// In pt, this message translates to:
  /// **'Fadiga'**
  String get symptomFatigue;

  /// No description provided for @symptomOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro sintoma'**
  String get symptomOther;

  /// No description provided for @symptomAura.
  ///
  /// In pt, this message translates to:
  /// **'Aura'**
  String get symptomAura;

  /// No description provided for @noSymptoms.
  ///
  /// In pt, this message translates to:
  /// **'Sem sintomas'**
  String get noSymptoms;

  /// No description provided for @nothingTaken.
  ///
  /// In pt, this message translates to:
  /// **'Nada tomado'**
  String get nothingTaken;

  /// No description provided for @noMedicationLabel.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma medicação'**
  String get noMedicationLabel;

  /// No description provided for @addAnother.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar outra'**
  String get addAnother;

  /// No description provided for @changeAction.
  ///
  /// In pt, this message translates to:
  /// **'Mudar'**
  String get changeAction;

  /// No description provided for @addAction.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar'**
  String get addAction;

  /// No description provided for @noMedsHint.
  ///
  /// In pt, this message translates to:
  /// **'Ainda não tens medicações. Adiciona-as no menu Medicação.'**
  String get noMedsHint;

  /// No description provided for @medication.
  ///
  /// In pt, this message translates to:
  /// **'Medicação'**
  String get medication;

  /// No description provided for @noMedications.
  ///
  /// In pt, this message translates to:
  /// **'Sem medicações'**
  String get noMedications;

  /// No description provided for @noMedicationsBody.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona os teus medicamentos (SOS ou preventivos) para os registares rapidamente durante uma crise.'**
  String get noMedicationsBody;

  /// No description provided for @addMedication.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar medicação'**
  String get addMedication;

  /// No description provided for @medsLoadError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as medicações: {error}'**
  String medsLoadError(Object error);

  /// No description provided for @newMedication.
  ///
  /// In pt, this message translates to:
  /// **'Nova medicação'**
  String get newMedication;

  /// No description provided for @editMedication.
  ///
  /// In pt, this message translates to:
  /// **'Editar medicação'**
  String get editMedication;

  /// No description provided for @fieldName.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get fieldName;

  /// No description provided for @medNameHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Sumatriptano'**
  String get medNameHint;

  /// No description provided for @fieldDoseOptional.
  ///
  /// In pt, this message translates to:
  /// **'Dose (mg) · opcional'**
  String get fieldDoseOptional;

  /// No description provided for @doseHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: 50'**
  String get doseHint;

  /// No description provided for @fieldType.
  ///
  /// In pt, this message translates to:
  /// **'Tipo'**
  String get fieldType;

  /// No description provided for @kindSos.
  ///
  /// In pt, this message translates to:
  /// **'SOS'**
  String get kindSos;

  /// No description provided for @kindSosDesc.
  ///
  /// In pt, this message translates to:
  /// **'Tomada durante a crise'**
  String get kindSosDesc;

  /// No description provided for @kindPreventive.
  ///
  /// In pt, this message translates to:
  /// **'Preventiva'**
  String get kindPreventive;

  /// No description provided for @kindPreventiveDesc.
  ///
  /// In pt, this message translates to:
  /// **'Diária / preventiva'**
  String get kindPreventiveDesc;

  /// No description provided for @defaultMed.
  ///
  /// In pt, this message translates to:
  /// **'Predefinida'**
  String get defaultMed;

  /// No description provided for @defaultMedDesc.
  ///
  /// In pt, this message translates to:
  /// **'Aparece já selecionada ao registar uma crise.'**
  String get defaultMedDesc;

  /// No description provided for @archiveMedication.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar medicação'**
  String get archiveMedication;

  /// No description provided for @archiveMedBody.
  ///
  /// In pt, this message translates to:
  /// **'A medicação deixa de aparecer na lista, mas o histórico de crises mantém-se intacto.'**
  String get archiveMedBody;

  /// No description provided for @archive.
  ///
  /// In pt, this message translates to:
  /// **'Arquivar'**
  String get archive;

  /// No description provided for @fieldReminder.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete diário'**
  String get fieldReminder;

  /// No description provided for @reminderNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem lembrete'**
  String get reminderNone;

  /// No description provided for @reminderSet.
  ///
  /// In pt, this message translates to:
  /// **'Definir hora'**
  String get reminderSet;

  /// No description provided for @reminderClear.
  ///
  /// In pt, this message translates to:
  /// **'Limpar'**
  String get reminderClear;

  /// No description provided for @reminderOnlyPreventive.
  ///
  /// In pt, this message translates to:
  /// **'Disponível apenas para medicação preventiva.'**
  String get reminderOnlyPreventive;

  /// No description provided for @reminderAt.
  ///
  /// In pt, this message translates to:
  /// **'Diariamente · {time}'**
  String reminderAt(String time);

  /// No description provided for @sectionMedPreventive.
  ///
  /// In pt, this message translates to:
  /// **'Medicação Preventiva'**
  String get sectionMedPreventive;

  /// No description provided for @sectionMedSos.
  ///
  /// In pt, this message translates to:
  /// **'Medicação SOS / Crise'**
  String get sectionMedSos;

  /// No description provided for @sectionMedEnded.
  ///
  /// In pt, this message translates to:
  /// **'Tratamentos terminados'**
  String get sectionMedEnded;

  /// No description provided for @fieldSubtype.
  ///
  /// In pt, this message translates to:
  /// **'Tipo de preventiva'**
  String get fieldSubtype;

  /// No description provided for @subtypePill.
  ///
  /// In pt, this message translates to:
  /// **'Comprimido Diário'**
  String get subtypePill;

  /// No description provided for @subtypeInjection.
  ///
  /// In pt, this message translates to:
  /// **'Injeção'**
  String get subtypeInjection;

  /// No description provided for @fieldInjectionPeriod.
  ///
  /// In pt, this message translates to:
  /// **'Periodicidade'**
  String get fieldInjectionPeriod;

  /// No description provided for @periodMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Mensal'**
  String get periodMonthly;

  /// No description provided for @periodQuarterly.
  ///
  /// In pt, this message translates to:
  /// **'Trimestral'**
  String get periodQuarterly;

  /// No description provided for @fieldStartDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de início'**
  String get fieldStartDate;

  /// No description provided for @startDateNotSet.
  ///
  /// In pt, this message translates to:
  /// **'Escolher data de início'**
  String get startDateNotSet;

  /// No description provided for @endTreatmentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Terminar tratamento'**
  String get endTreatmentTitle;

  /// No description provided for @endTreatmentBody.
  ///
  /// In pt, this message translates to:
  /// **'A medicação deixa de aparecer na lista ativa, mas o histórico mantém-se para consulta.'**
  String get endTreatmentBody;

  /// No description provided for @endTreatmentCta.
  ///
  /// In pt, this message translates to:
  /// **'Terminar'**
  String get endTreatmentCta;

  /// No description provided for @treatmentEndedOn.
  ///
  /// In pt, this message translates to:
  /// **'Terminado em {date}'**
  String treatmentEndedOn(String date);

  /// No description provided for @treatmentStartedOn.
  ///
  /// In pt, this message translates to:
  /// **'Desde {date}'**
  String treatmentStartedOn(String date);

  /// No description provided for @injectionScheduleLabel.
  ///
  /// In pt, this message translates to:
  /// **'{period} · próx. {date}'**
  String injectionScheduleLabel(String period, String date);

  /// No description provided for @testReminderNow.
  ///
  /// In pt, this message translates to:
  /// **'Testar lembrete agora'**
  String get testReminderNow;

  /// No description provided for @testReminderNowDesc.
  ///
  /// In pt, this message translates to:
  /// **'Mostra a notificação para confirmares que o canal funciona'**
  String get testReminderNowDesc;

  /// No description provided for @testReminderSent.
  ///
  /// In pt, this message translates to:
  /// **'Notificação enviada — verifica a barra de estado'**
  String get testReminderSent;

  /// No description provided for @exactAlarmFallback.
  ///
  /// In pt, this message translates to:
  /// **'Lembrete agendado, mas o Android pode atrasá-lo. Para disparar à hora exata, ativa “Alarmes e lembretes” nas definições do sistema.'**
  String get exactAlarmFallback;

  /// No description provided for @openSystemSettings.
  ///
  /// In pt, this message translates to:
  /// **'Abrir definições'**
  String get openSystemSettings;

  /// No description provided for @medsReminderTitle.
  ///
  /// In pt, this message translates to:
  /// **'Hora da medicação preventiva'**
  String get medsReminderTitle;

  /// No description provided for @medsReminderBody.
  ///
  /// In pt, this message translates to:
  /// **'Está na hora de tomar {name}.'**
  String medsReminderBody(String name);

  /// No description provided for @notificationPermissionDenied.
  ///
  /// In pt, this message translates to:
  /// **'Sem permissão de notificações — o lembrete não vai disparar.'**
  String get notificationPermissionDenied;

  /// No description provided for @sectionProfile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get sectionProfile;

  /// No description provided for @profileSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Nome e dados para o relatório médico'**
  String get profileSubtitle;

  /// No description provided for @sectionPrivacyData.
  ///
  /// In pt, this message translates to:
  /// **'Privacidade e dados'**
  String get sectionPrivacyData;

  /// No description provided for @privacyNote.
  ///
  /// In pt, this message translates to:
  /// **'Os teus dados ficam no dispositivo e num servidor europeu (Frankfurt), isolados por utilizador, sem anúncios.'**
  String get privacyNote;

  /// No description provided for @exportData.
  ///
  /// In pt, this message translates to:
  /// **'Exportar os meus dados'**
  String get exportData;

  /// No description provided for @exportSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Recebe tudo em ficheiro JSON'**
  String get exportSubtitle;

  /// No description provided for @deleteAccount.
  ///
  /// In pt, this message translates to:
  /// **'Apagar conta e dados'**
  String get deleteAccount;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Remove tudo, sem retorno'**
  String get deleteAccountSubtitle;

  /// No description provided for @sectionAbout.
  ///
  /// In pt, this message translates to:
  /// **'Sobre'**
  String get sectionAbout;

  /// No description provided for @aboutLine.
  ///
  /// In pt, this message translates to:
  /// **'AURA · Diário da Enxaqueca'**
  String get aboutLine;

  /// No description provided for @deleteConfirmBody.
  ///
  /// In pt, this message translates to:
  /// **'Isto apaga permanentemente todas as crises, medicação e perfil, no dispositivo e no servidor. Para confirmar, escreve APAGAR.'**
  String get deleteConfirmBody;

  /// No description provided for @confirmWord.
  ///
  /// In pt, this message translates to:
  /// **'APAGAR'**
  String get confirmWord;

  /// No description provided for @accountDeleted.
  ///
  /// In pt, this message translates to:
  /// **'Conta e dados apagados'**
  String get accountDeleted;

  /// No description provided for @exportError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao exportar: {error}'**
  String exportError(Object error);

  /// No description provided for @exportSubject.
  ///
  /// In pt, this message translates to:
  /// **'Os meus dados · AURA'**
  String get exportSubject;

  /// No description provided for @sectionLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get sectionLanguage;

  /// No description provided for @langPtPt.
  ///
  /// In pt, this message translates to:
  /// **'Português (Portugal)'**
  String get langPtPt;

  /// No description provided for @langPtBr.
  ///
  /// In pt, this message translates to:
  /// **'Português (Brasil)'**
  String get langPtBr;

  /// No description provided for @langEn.
  ///
  /// In pt, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @sectionSupportAndPro.
  ///
  /// In pt, this message translates to:
  /// **'Suporte e versão Pro'**
  String get sectionSupportAndPro;

  /// No description provided for @contactSupport.
  ///
  /// In pt, this message translates to:
  /// **'Contactar suporte'**
  String get contactSupport;

  /// No description provided for @contactSupportDesc.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda, comentário ou sugestões'**
  String get contactSupportDesc;

  /// No description provided for @rateApp.
  ///
  /// In pt, this message translates to:
  /// **'Avaliar app'**
  String get rateApp;

  /// No description provided for @rateAppDesc.
  ///
  /// In pt, this message translates to:
  /// **'Deixa uma avaliação na loja'**
  String get rateAppDesc;

  /// No description provided for @shareApp.
  ///
  /// In pt, this message translates to:
  /// **'Partilhar app'**
  String get shareApp;

  /// No description provided for @shareAppDesc.
  ///
  /// In pt, this message translates to:
  /// **'Recomenda a um amigo'**
  String get shareAppDesc;

  /// No description provided for @unlockPro.
  ///
  /// In pt, this message translates to:
  /// **'Desbloquear versão Pro'**
  String get unlockPro;

  /// No description provided for @unlockProDesc.
  ///
  /// In pt, this message translates to:
  /// **'Funcionalidades premium em breve'**
  String get unlockProDesc;

  /// No description provided for @shareAppText.
  ///
  /// In pt, this message translates to:
  /// **'Acompanha as tuas enxaquecas com a AURA · Diário da Enxaqueca.'**
  String get shareAppText;

  /// No description provided for @supportEmailSubject.
  ///
  /// In pt, this message translates to:
  /// **'AURA · Suporte'**
  String get supportEmailSubject;

  /// No description provided for @proComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve — a versão Pro chega após o lançamento na loja.'**
  String get proComingSoon;

  /// No description provided for @fieldEmail.
  ///
  /// In pt, this message translates to:
  /// **'Email'**
  String get fieldEmail;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'exemplo@dominio.com'**
  String get emailHint;

  /// No description provided for @profileTitle.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @profileIntro.
  ///
  /// In pt, this message translates to:
  /// **'Opcional — aparece no cabeçalho do relatório para o médico.'**
  String get profileIntro;

  /// No description provided for @profileNameHint.
  ///
  /// In pt, this message translates to:
  /// **'O teu nome'**
  String get profileNameHint;

  /// No description provided for @fieldBirthYear.
  ///
  /// In pt, this message translates to:
  /// **'Ano de nascimento'**
  String get fieldBirthYear;

  /// No description provided for @birthYearHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: 1990'**
  String get birthYearHint;

  /// No description provided for @fieldSex.
  ///
  /// In pt, this message translates to:
  /// **'Sexo'**
  String get fieldSex;

  /// No description provided for @sexF.
  ///
  /// In pt, this message translates to:
  /// **'Feminino'**
  String get sexF;

  /// No description provided for @sexM.
  ///
  /// In pt, this message translates to:
  /// **'Masculino'**
  String get sexM;

  /// No description provided for @sexOther.
  ///
  /// In pt, this message translates to:
  /// **'Outro'**
  String get sexOther;

  /// No description provided for @sexNa.
  ///
  /// In pt, this message translates to:
  /// **'Prefiro não dizer'**
  String get sexNa;

  /// No description provided for @reportTitle.
  ///
  /// In pt, this message translates to:
  /// **'Relatório de Registos (PDF)'**
  String get reportTitle;

  /// No description provided for @periodLast30.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 30 dias'**
  String get periodLast30;

  /// No description provided for @periodLast90.
  ///
  /// In pt, this message translates to:
  /// **'Últimos 90 dias'**
  String get periodLast90;

  /// No description provided for @reportError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível gerar o relatório: {error}'**
  String reportError(Object error);

  /// No description provided for @appointments.
  ///
  /// In pt, this message translates to:
  /// **'Preparar Consulta'**
  String get appointments;

  /// No description provided for @hit6Title.
  ///
  /// In pt, this message translates to:
  /// **'Impacto na Qualidade de Vida (HIT-6)'**
  String get hit6Title;

  /// No description provided for @hit6Intro.
  ///
  /// In pt, this message translates to:
  /// **'Responde a 6 perguntas (≈1 minuto). O resultado fica no relatório médico e atualiza-se a cada 30 dias.'**
  String get hit6Intro;

  /// No description provided for @hit6CardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Impacto na Qualidade de Vida (HIT-6)'**
  String get hit6CardTitle;

  /// No description provided for @hit6CardBody.
  ///
  /// In pt, this message translates to:
  /// **'Responde ao questionário standard (6 perguntas) para avaliar o impacto da enxaqueca nas últimas 4 semanas e atualizar o teu relatório médico.'**
  String get hit6CardBody;

  /// No description provided for @hit6CardCta.
  ///
  /// In pt, this message translates to:
  /// **'Responder (1 min)'**
  String get hit6CardCta;

  /// No description provided for @hit6Submit.
  ///
  /// In pt, this message translates to:
  /// **'Submeter respostas'**
  String get hit6Submit;

  /// No description provided for @hit6Submitted.
  ///
  /// In pt, this message translates to:
  /// **'Resultado HIT-6 guardado'**
  String get hit6Submitted;

  /// No description provided for @hit6QuestionLabel.
  ///
  /// In pt, this message translates to:
  /// **'Pergunta {n} de 6'**
  String hit6QuestionLabel(int n);

  /// No description provided for @hit6Q1.
  ///
  /// In pt, this message translates to:
  /// **'Quando tens dores de cabeça, com que frequência são severas?'**
  String get hit6Q1;

  /// No description provided for @hit6Q2.
  ///
  /// In pt, this message translates to:
  /// **'Com que frequência as dores de cabeça limitam a tua capacidade de fazer atividades diárias (trabalho doméstico, trabalho, escola ou atividades sociais)?'**
  String get hit6Q2;

  /// No description provided for @hit6Q3.
  ///
  /// In pt, this message translates to:
  /// **'Quando tens dor de cabeça, com que frequência desejas poder deitar-te?'**
  String get hit6Q3;

  /// No description provided for @hit6Q4.
  ///
  /// In pt, this message translates to:
  /// **'Nas últimas 4 semanas, com que frequência te sentiste cansado para trabalhar ou fazer atividades diárias por causa das dores de cabeça?'**
  String get hit6Q4;

  /// No description provided for @hit6Q5.
  ///
  /// In pt, this message translates to:
  /// **'Nas últimas 4 semanas, com que frequência te sentiste farto ou irritado por causa das dores de cabeça?'**
  String get hit6Q5;

  /// No description provided for @hit6Q6.
  ///
  /// In pt, this message translates to:
  /// **'Nas últimas 4 semanas, com que frequência as dores de cabeça limitaram a tua capacidade de concentração no trabalho ou atividades diárias?'**
  String get hit6Q6;

  /// No description provided for @hit6Never.
  ///
  /// In pt, this message translates to:
  /// **'Nunca'**
  String get hit6Never;

  /// No description provided for @hit6Rarely.
  ///
  /// In pt, this message translates to:
  /// **'Raramente'**
  String get hit6Rarely;

  /// No description provided for @hit6Sometimes.
  ///
  /// In pt, this message translates to:
  /// **'Às vezes'**
  String get hit6Sometimes;

  /// No description provided for @hit6VeryOften.
  ///
  /// In pt, this message translates to:
  /// **'Muito frequentemente'**
  String get hit6VeryOften;

  /// No description provided for @hit6Always.
  ///
  /// In pt, this message translates to:
  /// **'Sempre'**
  String get hit6Always;

  /// No description provided for @hit6CategoryLittle.
  ///
  /// In pt, this message translates to:
  /// **'Pouco/Sem impacto'**
  String get hit6CategoryLittle;

  /// No description provided for @hit6CategorySome.
  ///
  /// In pt, this message translates to:
  /// **'Algum impacto'**
  String get hit6CategorySome;

  /// No description provided for @hit6CategorySubstantial.
  ///
  /// In pt, this message translates to:
  /// **'Impacto substancial'**
  String get hit6CategorySubstantial;

  /// No description provided for @hit6CategorySevere.
  ///
  /// In pt, this message translates to:
  /// **'Impacto severo'**
  String get hit6CategorySevere;

  /// No description provided for @hit6ScoreLabel.
  ///
  /// In pt, this message translates to:
  /// **'Score atual: {score}'**
  String hit6ScoreLabel(int score);

  /// No description provided for @appointmentsIntro.
  ///
  /// In pt, this message translates to:
  /// **'Histórico, próximas consultas e relatório para o médico.'**
  String get appointmentsIntro;

  /// No description provided for @generateReport.
  ///
  /// In pt, this message translates to:
  /// **'Gerar relatório médico'**
  String get generateReport;

  /// No description provided for @generateReportDesc.
  ///
  /// In pt, this message translates to:
  /// **'PDF com as crises e medicação para a próxima consulta'**
  String get generateReportDesc;

  /// No description provided for @sectionUpcoming.
  ///
  /// In pt, this message translates to:
  /// **'Próxima consulta'**
  String get sectionUpcoming;

  /// No description provided for @sectionPast.
  ///
  /// In pt, this message translates to:
  /// **'Histórico'**
  String get sectionPast;

  /// No description provided for @sectionReportForDoctor.
  ///
  /// In pt, this message translates to:
  /// **'Relatório para o médico'**
  String get sectionReportForDoctor;

  /// No description provided for @scheduleAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Agendar'**
  String get scheduleAppointment;

  /// No description provided for @webAccessCode.
  ///
  /// In pt, this message translates to:
  /// **'Código de Acesso Web'**
  String get webAccessCode;

  /// No description provided for @webAccessCodeDesc.
  ///
  /// In pt, this message translates to:
  /// **'Link para o médico consultar online'**
  String get webAccessCodeDesc;

  /// No description provided for @webAccessComingSoon.
  ///
  /// In pt, this message translates to:
  /// **'Em breve — link partilhável após o lançamento.'**
  String get webAccessComingSoon;

  /// No description provided for @viewAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver tudo'**
  String get viewAll;

  /// No description provided for @noAppointments.
  ///
  /// In pt, this message translates to:
  /// **'Sem consultas registadas'**
  String get noAppointments;

  /// No description provided for @noAppointmentsBody.
  ///
  /// In pt, this message translates to:
  /// **'Adiciona a próxima consulta para a teres à mão.'**
  String get noAppointmentsBody;

  /// No description provided for @addAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar consulta'**
  String get addAppointment;

  /// No description provided for @newAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Nova consulta'**
  String get newAppointment;

  /// No description provided for @editAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Editar consulta'**
  String get editAppointment;

  /// No description provided for @saveAppointment.
  ///
  /// In pt, this message translates to:
  /// **'Guardar consulta'**
  String get saveAppointment;

  /// No description provided for @appointmentSaved.
  ///
  /// In pt, this message translates to:
  /// **'Consulta guardada'**
  String get appointmentSaved;

  /// No description provided for @appointmentUpdated.
  ///
  /// In pt, this message translates to:
  /// **'Consulta atualizada'**
  String get appointmentUpdated;

  /// No description provided for @deleteAppointmentTitle.
  ///
  /// In pt, this message translates to:
  /// **'Apagar consulta'**
  String get deleteAppointmentTitle;

  /// No description provided for @deleteAppointmentBody.
  ///
  /// In pt, this message translates to:
  /// **'A consulta será removida permanentemente.'**
  String get deleteAppointmentBody;

  /// No description provided for @fieldDate.
  ///
  /// In pt, this message translates to:
  /// **'Data'**
  String get fieldDate;

  /// No description provided for @fieldTime.
  ///
  /// In pt, this message translates to:
  /// **'Hora'**
  String get fieldTime;

  /// No description provided for @fieldDoctor.
  ///
  /// In pt, this message translates to:
  /// **'Médico'**
  String get fieldDoctor;

  /// No description provided for @doctorHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Dr. Silva'**
  String get doctorHint;

  /// No description provided for @fieldLocation.
  ///
  /// In pt, this message translates to:
  /// **'Local'**
  String get fieldLocation;

  /// No description provided for @locationHint.
  ///
  /// In pt, this message translates to:
  /// **'Ex.: Hospital de Santa Maria'**
  String get locationHint;

  /// No description provided for @fieldAppointmentNotes.
  ///
  /// In pt, this message translates to:
  /// **'Notas · opcional'**
  String get fieldAppointmentNotes;

  /// No description provided for @appointmentNotesHint.
  ///
  /// In pt, this message translates to:
  /// **'Tópicos a discutir com o médico'**
  String get appointmentNotesHint;

  /// No description provided for @selectDate.
  ///
  /// In pt, this message translates to:
  /// **'Escolher data'**
  String get selectDate;

  /// No description provided for @selectTime.
  ///
  /// In pt, this message translates to:
  /// **'Escolher hora'**
  String get selectTime;

  /// No description provided for @statsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Estatísticas'**
  String get statsTitle;

  /// No description provided for @period30.
  ///
  /// In pt, this message translates to:
  /// **'30d'**
  String get period30;

  /// No description provided for @period60.
  ///
  /// In pt, this message translates to:
  /// **'60d'**
  String get period60;

  /// No description provided for @period90.
  ///
  /// In pt, this message translates to:
  /// **'90d'**
  String get period90;

  /// No description provided for @period6m.
  ///
  /// In pt, this message translates to:
  /// **'6m'**
  String get period6m;

  /// No description provided for @period1y.
  ///
  /// In pt, this message translates to:
  /// **'1a'**
  String get period1y;

  /// No description provided for @statIntensity.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade'**
  String get statIntensity;

  /// No description provided for @statDiasSos.
  ///
  /// In pt, this message translates to:
  /// **'Dias SOS'**
  String get statDiasSos;

  /// No description provided for @sectionCrisesPerWeek.
  ///
  /// In pt, this message translates to:
  /// **'Crises por semana'**
  String get sectionCrisesPerWeek;

  /// No description provided for @sectionIntensityDays.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade (dias)'**
  String get sectionIntensityDays;

  /// No description provided for @sectionFrequentSymptoms.
  ///
  /// In pt, this message translates to:
  /// **'Sintomas mais frequentes'**
  String get sectionFrequentSymptoms;

  /// No description provided for @sectionEvolutionImpact.
  ///
  /// In pt, this message translates to:
  /// **'Evolução e impacto'**
  String get sectionEvolutionImpact;

  /// No description provided for @sectionPatterns.
  ///
  /// In pt, this message translates to:
  /// **'Padrões'**
  String get sectionPatterns;

  /// No description provided for @sectionTreatment.
  ///
  /// In pt, this message translates to:
  /// **'Tratamento e eficácia'**
  String get sectionTreatment;

  /// No description provided for @sectionSeverity.
  ///
  /// In pt, this message translates to:
  /// **'Severidade'**
  String get sectionSeverity;

  /// No description provided for @sectionEvents.
  ///
  /// In pt, this message translates to:
  /// **'Eventos específicos'**
  String get sectionEvents;

  /// No description provided for @statHit6.
  ///
  /// In pt, this message translates to:
  /// **'HIT-6'**
  String get statHit6;

  /// No description provided for @statHit6None.
  ///
  /// In pt, this message translates to:
  /// **'Sem registo'**
  String get statHit6None;

  /// No description provided for @weekdayHeatTitle.
  ///
  /// In pt, this message translates to:
  /// **'Intensidade por dia da semana'**
  String get weekdayHeatTitle;

  /// No description provided for @weekdayHeatNoData.
  ///
  /// In pt, this message translates to:
  /// **'Sem crises neste período'**
  String get weekdayHeatNoData;

  /// No description provided for @sosEfficacyTitle.
  ///
  /// In pt, this message translates to:
  /// **'Eficácia da medicação SOS'**
  String get sosEfficacyTitle;

  /// No description provided for @auraTimelineTitle.
  ///
  /// In pt, this message translates to:
  /// **'Linha temporal da aura'**
  String get auraTimelineTitle;

  /// No description provided for @auraTimelineNone.
  ///
  /// In pt, this message translates to:
  /// **'Sem registos de aura no período'**
  String get auraTimelineNone;

  /// No description provided for @menstruationCorrelation.
  ///
  /// In pt, this message translates to:
  /// **'{percent}% das crises coincidem com o período menstrual'**
  String menstruationCorrelation(int percent);

  /// No description provided for @respTotalShort.
  ///
  /// In pt, this message translates to:
  /// **'Total'**
  String get respTotalShort;

  /// No description provided for @respPartialShort.
  ///
  /// In pt, this message translates to:
  /// **'Parcial'**
  String get respPartialShort;

  /// No description provided for @respNoneShort.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma'**
  String get respNoneShort;

  /// No description provided for @weekShort.
  ///
  /// In pt, this message translates to:
  /// **'S{n}'**
  String weekShort(int n);

  /// No description provided for @statsError.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os dados: {error}'**
  String statsError(Object error);
}

class _AppL10nDelegate extends LocalizationsDelegate<AppL10n> {
  const _AppL10nDelegate();

  @override
  Future<AppL10n> load(Locale locale) {
    return SynchronousFuture<AppL10n>(lookupAppL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppL10nDelegate old) => false;
}

AppL10n lookupAppL10n(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppL10nPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppL10nEn();
    case 'pt':
      return AppL10nPt();
  }

  throw FlutterError(
    'AppL10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
