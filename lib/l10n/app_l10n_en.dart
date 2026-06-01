// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppL10nEn extends AppL10n {
  AppL10nEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AURA';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get add => 'Add';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String days(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '$count day',
    );
    return '$_temp0';
  }

  @override
  String get homeGreeting => 'Hello';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get painNone => 'No headache';

  @override
  String get painLeve => 'Mild pain';

  @override
  String get painModerada => 'Moderate';

  @override
  String get painForte => 'Severe';

  @override
  String get medicationTaken => 'Took medication';

  @override
  String get medicationSos => 'Acute (SOS) medication';

  @override
  String get registerCrisis => 'Log a crisis';

  @override
  String get qaCalendar => 'Calendar';

  @override
  String get qaShare => 'Share';

  @override
  String get qaMedication => 'Medication';

  @override
  String get qaAppointment => 'Doctor visit';

  @override
  String get qaData => 'Data';

  @override
  String get settings => 'Settings';

  @override
  String get welcomeTitle => 'Welcome';

  @override
  String get welcomeBody =>
      'Log your first crisis whenever you need to. Your data stays on this device and in your account.';

  @override
  String summaryLoadError(Object error) {
    return 'Couldn\'t load the summary: $error';
  }

  @override
  String get medicationWorkedTitle => 'Did the medication work?';

  @override
  String get respNone => 'None';

  @override
  String get respPartial => 'Partial';

  @override
  String get respTotal => 'Total';

  @override
  String get calendar => 'Calendar';

  @override
  String get monthPrev => 'Previous month';

  @override
  String get monthNext => 'Next month';

  @override
  String get statCrises => 'Crises';

  @override
  String get statAvgIntensity => 'Avg. intensity';

  @override
  String get statAffectedDays => 'Affected days';

  @override
  String get legendLeve => 'Mild';

  @override
  String get legendModerada => 'Moderate';

  @override
  String get legendForte => 'Severe';

  @override
  String get tierSemDor => 'No pain';

  @override
  String get dayFuture => 'Future day.';

  @override
  String get noCrisesThisDay => 'No crises logged on this day.';

  @override
  String get registerForThisDay => 'Log for this day';

  @override
  String intensityValue(int n) {
    return 'Intensity $n';
  }

  @override
  String get auraTag => 'aura';

  @override
  String calendarLoadError(Object error) {
    return 'Couldn\'t load the calendar: $error';
  }

  @override
  String daySemantic(int n) {
    return 'Day $n';
  }

  @override
  String crisesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count crises',
      one: '1 crisis',
    );
    return '$_temp0';
  }

  @override
  String get withAura => ', with aura';

  @override
  String get newCrisis => 'New crisis';

  @override
  String get editCrisis => 'Edit crisis';

  @override
  String get crisisSaved => 'Crisis logged';

  @override
  String get crisisUpdated => 'Crisis updated';

  @override
  String saveError(Object error) {
    return 'Error saving: $error';
  }

  @override
  String get deleteCrisisTitle => 'Delete crisis';

  @override
  String get deleteCrisisBody => 'This crisis will be permanently removed.';

  @override
  String deleteError(Object error) {
    return 'Error deleting: $error';
  }

  @override
  String get formIntro => 'Log the essentials in a few taps.';

  @override
  String get sectionIntensity => 'Pain intensity';

  @override
  String get sectionAura => 'Aura';

  @override
  String get sectionSymptoms => 'Symptoms';

  @override
  String get sectionMedicationTaken => 'Medication taken';

  @override
  String get sectionNotesOptional => 'Additional notes · optional';

  @override
  String get notesHint => 'Anything to note about this crisis?';

  @override
  String get saveCrisis => 'Save crisis';

  @override
  String get intensityScaleMin => 'mild';

  @override
  String get intensityScaleMax => 'disabling';

  @override
  String get intensityLabelMild => 'MILD';

  @override
  String get intensityLabelModerate => 'MODERATE';

  @override
  String get intensityLabelIntense => 'INTENSE';

  @override
  String get intensityLabelDisabling => 'DISABLING';

  @override
  String intensityOutOf(int n) {
    return 'Intensity $n of 10';
  }

  @override
  String get symptomNausea => 'Nausea';

  @override
  String get symptomVomiting => 'Vomiting';

  @override
  String get symptomPhotophobia => 'Light sensitivity';

  @override
  String get symptomPhonophobia => 'Sound sensitivity';

  @override
  String get symptomDizziness => 'Dizziness';

  @override
  String get symptomFatigue => 'Fatigue';

  @override
  String get symptomOther => 'Other symptom';

  @override
  String get symptomAura => 'Aura';

  @override
  String get noSymptoms => 'No symptoms';

  @override
  String get nothingTaken => 'Nothing taken';

  @override
  String get noMedicationLabel => 'No medication';

  @override
  String get addAnother => 'Add another';

  @override
  String get changeAction => 'Change';

  @override
  String get addAction => 'Add';

  @override
  String get noMedsHint => 'You don\'t have any medications yet. Add them in the Medication menu.';

  @override
  String get medication => 'Medication';

  @override
  String get noMedications => 'No medications';

  @override
  String get noMedicationsBody =>
      'Add your medications (acute or preventive) to log them quickly during a crisis.';

  @override
  String get addMedication => 'Add medication';

  @override
  String medsLoadError(Object error) {
    return 'Couldn\'t load medications: $error';
  }

  @override
  String get newMedication => 'New medication';

  @override
  String get editMedication => 'Edit medication';

  @override
  String get fieldName => 'Name';

  @override
  String get medNameHint => 'e.g. Sumatriptan';

  @override
  String get fieldDoseOptional => 'Dose (mg) · optional';

  @override
  String get doseHint => 'e.g. 50';

  @override
  String get fieldType => 'Type';

  @override
  String get kindSos => 'Acute (SOS)';

  @override
  String get kindSosDesc => 'Taken during a crisis';

  @override
  String get kindPreventive => 'Preventive';

  @override
  String get kindPreventiveDesc => 'Daily / preventive';

  @override
  String get defaultMed => 'Default';

  @override
  String get defaultMedDesc => 'Pre-selected when logging a crisis.';

  @override
  String get archiveMedication => 'Archive medication';

  @override
  String get archiveMedBody =>
      'The medication stops showing in the list, but the crisis history stays intact.';

  @override
  String get archive => 'Archive';

  @override
  String get fieldReminder => 'Daily reminder';

  @override
  String get reminderNone => 'No reminder';

  @override
  String get reminderSet => 'Set time';

  @override
  String get reminderClear => 'Clear';

  @override
  String get reminderOnlyPreventive => 'Available only for preventive medication.';

  @override
  String reminderAt(String time) {
    return 'Daily at $time';
  }

  @override
  String get medsReminderTitle => 'Time for your preventive medication';

  @override
  String medsReminderBody(String name) {
    return 'Time to take $name.';
  }

  @override
  String get notificationPermissionDenied =>
      'Notifications permission denied — the reminder won\'t fire.';

  @override
  String get sectionProfile => 'Profile';

  @override
  String get profileSubtitle => 'Name and details for the medical report';

  @override
  String get sectionPrivacyData => 'Privacy and data';

  @override
  String get privacyNote =>
      'Your data stays on the device and on a European server (Frankfurt), isolated per user, with no ads.';

  @override
  String get exportData => 'Export my data';

  @override
  String get exportSubtitle => 'Get everything as a JSON file';

  @override
  String get deleteAccount => 'Delete account and data';

  @override
  String get deleteAccountSubtitle => 'Removes everything, no undo';

  @override
  String get sectionAbout => 'About';

  @override
  String get aboutLine => 'AURA · Migraine Diary';

  @override
  String get deleteConfirmBody =>
      'This permanently deletes all crises, medication and profile, on the device and the server. To confirm, type DELETE.';

  @override
  String get confirmWord => 'DELETE';

  @override
  String get accountDeleted => 'Account and data deleted';

  @override
  String exportError(Object error) {
    return 'Error exporting: $error';
  }

  @override
  String get exportSubject => 'My data · AURA';

  @override
  String get sectionLanguage => 'Language';

  @override
  String get langPtPt => 'Português (Portugal)';

  @override
  String get langPtBr => 'Português (Brasil)';

  @override
  String get langEn => 'English';

  @override
  String get sectionSupportAndPro => 'Support and Pro';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get contactSupportDesc => 'Help, feedback or suggestions';

  @override
  String get rateApp => 'Rate this app';

  @override
  String get rateAppDesc => 'Leave a review in the store';

  @override
  String get shareApp => 'Share this app';

  @override
  String get shareAppDesc => 'Recommend it to a friend';

  @override
  String get unlockPro => 'Unlock Pro version';

  @override
  String get unlockProDesc => 'Premium features coming soon';

  @override
  String get shareAppText => 'Track your migraines with AURA · Migraine Diary.';

  @override
  String get supportEmailSubject => 'AURA · Support';

  @override
  String get proComingSoon => 'Coming soon — Pro unlocks after the store launch.';

  @override
  String get fieldEmail => 'Email';

  @override
  String get emailHint => 'name@example.com';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileIntro => 'Optional — appears in the header of the report for the doctor.';

  @override
  String get profileNameHint => 'Your name';

  @override
  String get fieldBirthYear => 'Birth year';

  @override
  String get birthYearHint => 'e.g. 1990';

  @override
  String get fieldSex => 'Sex';

  @override
  String get sexF => 'Female';

  @override
  String get sexM => 'Male';

  @override
  String get sexOther => 'Other';

  @override
  String get sexNa => 'Prefer not to say';

  @override
  String get reportTitle => 'Medical report';

  @override
  String get periodLast30 => 'Last 30 days';

  @override
  String get periodLast90 => 'Last 90 days';

  @override
  String reportError(Object error) {
    return 'Couldn\'t generate the report: $error';
  }

  @override
  String get appointments => 'Doctor visits';

  @override
  String get appointmentsIntro => 'History, upcoming appointments and the report for the doctor.';

  @override
  String get generateReport => 'Generate medical report';

  @override
  String get generateReportDesc => 'PDF with crises and medication for the next appointment';

  @override
  String get sectionUpcoming => 'Next appointment';

  @override
  String get sectionPast => 'History';

  @override
  String get sectionReportForDoctor => 'Report for the doctor';

  @override
  String get scheduleAppointment => 'Schedule';

  @override
  String get webAccessCode => 'Web access code';

  @override
  String get webAccessCodeDesc => 'Link for the doctor to view online';

  @override
  String get webAccessComingSoon => 'Coming soon — shareable link after launch.';

  @override
  String get viewAll => 'View all';

  @override
  String get noAppointments => 'No appointments logged';

  @override
  String get noAppointmentsBody => 'Add the next appointment so you have it handy.';

  @override
  String get addAppointment => 'Add appointment';

  @override
  String get newAppointment => 'New appointment';

  @override
  String get editAppointment => 'Edit appointment';

  @override
  String get saveAppointment => 'Save appointment';

  @override
  String get appointmentSaved => 'Appointment saved';

  @override
  String get appointmentUpdated => 'Appointment updated';

  @override
  String get deleteAppointmentTitle => 'Delete appointment';

  @override
  String get deleteAppointmentBody => 'The appointment will be permanently removed.';

  @override
  String get fieldDate => 'Date';

  @override
  String get fieldTime => 'Time';

  @override
  String get fieldDoctor => 'Doctor';

  @override
  String get doctorHint => 'e.g. Dr. Silva';

  @override
  String get fieldLocation => 'Location';

  @override
  String get locationHint => 'e.g. St. Mary\'s Hospital';

  @override
  String get fieldAppointmentNotes => 'Notes · optional';

  @override
  String get appointmentNotesHint => 'Topics to discuss with the doctor';

  @override
  String get selectDate => 'Pick a date';

  @override
  String get selectTime => 'Pick a time';

  @override
  String get statsTitle => 'Data';

  @override
  String get period30 => '30 days';

  @override
  String get period90 => '90 days';

  @override
  String get statIntensity => 'Intensity';

  @override
  String get statDiasSos => 'SOS days';

  @override
  String get sectionCrisesPerWeek => 'Crises per week';

  @override
  String get sectionIntensityDays => 'Intensity (days)';

  @override
  String get sectionFrequentSymptoms => 'Most frequent symptoms';

  @override
  String weekShort(int n) {
    return 'W$n';
  }

  @override
  String statsError(Object error) {
    return 'Couldn\'t load the data: $error';
  }
}
