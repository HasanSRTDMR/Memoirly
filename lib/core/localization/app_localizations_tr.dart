// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Arşiv';

  @override
  String get onboardingHeadline => 'Düşüncelerin.\nSadece senin.';

  @override
  String get onboardingSub => 'Şifreli senkron. Günlüğün seninle kalır.';

  @override
  String get skip => 'ATLA';

  @override
  String get next => 'İLERİ';

  @override
  String get getStarted => 'BAŞLA';

  @override
  String get onboardingPage2Title => 'Özgürce yaz';

  @override
  String get onboardingPage2Body =>
      'Duygu, etiket ve anları sakin bir alanda kaydet.';

  @override
  String get onboardingPage3Title => 'Bul ve düşün';

  @override
  String get onboardingPage3Body =>
      'Arşivde ara, takvime bak, içgörülerini oku.';

  @override
  String get archiveTitle => 'Arşiv';

  @override
  String get menu => 'Menü';

  @override
  String get account => 'Hesap';

  @override
  String get goodMorning => 'Günaydın, günlükçü';

  @override
  String get goodAfternoon => 'İyi günler, günlükçü';

  @override
  String get goodEvening => 'İyi akşamlar, günlükçü';

  @override
  String get captureThoughts => 'Düşüncelerini yakala';

  @override
  String get captureThoughtsBody => 'Boş sayfa, netliğe davet. Aklında ne var?';

  @override
  String get startWriting => 'Yazmaya başla';

  @override
  String get reflectToday => 'Bugünü düşün';

  @override
  String get recentArchive => 'Son arşiv';

  @override
  String get home => 'Ana sayfa';

  @override
  String get search => 'Ara';

  @override
  String get calendar => 'Takvim';

  @override
  String get insights => 'İçgörüler';

  @override
  String get settings => 'Ayarlar';

  @override
  String get newEntry => 'Yeni kayıt';

  @override
  String get autoSaving => 'Otomatik kaydediliyor…';

  @override
  String get save => 'Kaydet';

  @override
  String get writeThoughts => 'Düşüncelerini yaz…';

  @override
  String get mood => 'Ruh hali';

  @override
  String get addTags => '#etiket ekle…';

  @override
  String get entryDetail => 'Kayıt';

  @override
  String get edit => 'Düzenle';

  @override
  String get delete => 'Sil';

  @override
  String get deleteConfirmTitle => 'Kayıt silinsin mi?';

  @override
  String get deleteConfirmBody => 'Bu işlem geri alınamaz.';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get timelineView => 'Zaman çizelgesi';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count KAYIT',
      one: '1 KAYIT',
      zero: '0 KAYIT',
    );
    return '$_temp0';
  }

  @override
  String get searchYourThoughts => 'Düşüncelerinde ara…';

  @override
  String get tags => 'Etiketler';

  @override
  String get date => 'Tarih';

  @override
  String get clearFilters => 'Filtreleri temizle';

  @override
  String get silenceInLibrary => 'Kütüphanede sessizlik…';

  @override
  String get noSearchResults =>
      'Aramanla eşleşen kayıt yok. Daha genel kelimeler dene.';

  @override
  String get popularMoods => 'Popüler ruh halleri';

  @override
  String get recentExplorations => 'Son keşifler';

  @override
  String get weeklyOverview => 'Haftalık özet';

  @override
  String weeklyWroteDays(int days) {
    return 'Bu hafta $days gün yazdın.';
  }

  @override
  String get weeklyConsistency => 'Yansımaların giderek daha tutarlı.';

  @override
  String get moodRhythm => 'Ruh hali ritmi';

  @override
  String get last7Days => 'Son 7 gün';

  @override
  String get volume => 'Hacim';

  @override
  String get avgWordsPerDay => 'Günlük ortalama kelime';

  @override
  String get words => 'kelime';

  @override
  String get themes => 'Temalar';

  @override
  String get frequentlyTagged => 'Sık kullanılan etiketler';

  @override
  String get totalEntries => 'Toplam kayıt';

  @override
  String get moodDistribution => 'Ruh hali dağılımı';

  @override
  String get settingsTitle => 'Ayarlar';

  @override
  String get settingsSubtitle => 'Özel alanını yapılandır';

  @override
  String get security => 'Güvenlik';

  @override
  String get passcodeLock => 'PIN kilidi';

  @override
  String get passcodeLockDesc => 'Uygulamayı açmak için PIN iste';

  @override
  String get biometricAuth => 'Biyometrik doğrulama';

  @override
  String get biometricAuthDesc => 'Face ID veya Touch ID kullan';

  @override
  String get appearance => 'Görünüm';

  @override
  String get lightMode => 'Açık tema';

  @override
  String get darkMode => 'Koyu tema';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Sistem';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get dataManagement => 'Veri yönetimi';

  @override
  String get exportTxt => 'TXT olarak dışa aktar';

  @override
  String get resetLocalData => 'Yerel veriyi sıfırla';

  @override
  String get resetLocalDataConfirm =>
      'Bu cihazdaki tüm günlük kayıtları silinsin mi? Geri alınamaz.';

  @override
  String get privacyFirst => 'Gizlilik öncelikli';

  @override
  String get privacyQuote =>
      'Günlüğün kontrolün altında kalmak için tasarlandı.';

  @override
  String versionLabel(String version) {
    return 'Memoirly sürüm $version';
  }

  @override
  String get welcomeBack => 'Tekrar hoş geldin';

  @override
  String get enterPin => 'Düşüncelerinin kilidini açmak için PIN gir';

  @override
  String get useBiometrics => 'Biyometri kullan';

  @override
  String get forgotPin => 'PIN unuttum';

  @override
  String get emergency => 'Acil';

  @override
  String get setPinTitle => 'PIN oluştur';

  @override
  String get confirmPinTitle => 'PIN doğrula';

  @override
  String get pinsDoNotMatch => 'PIN\'ler eşleşmiyor';

  @override
  String get wrongPin => 'Yanlış PIN';

  @override
  String get faceId => 'Face ID';

  @override
  String get signInAnonymously => 'Devam et';

  @override
  String get authError =>
      'Giriş yapılamadı. Ağ ve Firebase yapılandırmasını kontrol edin.';

  @override
  String get explore => 'Keşfet';

  @override
  String get privateSanctuary => 'Özel sığınak';

  @override
  String entryNo(int n) {
    return 'Kayıt no. $n';
  }

  @override
  String get shareEntry => 'Paylaş';

  @override
  String get yesterday => 'Dün';

  @override
  String get today => 'Bugün';

  @override
  String get moodPeaceful => 'Huzurlu';

  @override
  String get moodReflective => 'Düşünceli';

  @override
  String get moodProductive => 'Verimli';

  @override
  String get moodAnxious => 'Endişeli';

  @override
  String get moodGrateful => 'Minnettar';

  @override
  String get moodSerene => 'Sakin';

  @override
  String get moodMelancholic => 'Melankolik';

  @override
  String get moodInspired => 'İlhamlı';

  @override
  String get moodQuiet => 'Sessiz';

  @override
  String get moodNeutral => 'Nötr';

  @override
  String get moodJoyful => 'Neşeli';

  @override
  String get moodLow => 'Düşük';

  @override
  String get moodCalm => 'Dingin';

  @override
  String get moodStressed => 'Stresli';

  @override
  String get selectMonth => 'Ay seç';

  @override
  String get ok => 'Tamam';

  @override
  String get loading => 'Yükleniyor…';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti';

  @override
  String get emptyJournal => 'Henüz kayıt yok. Yazmaya başla.';

  @override
  String get titleHint => 'Başlık (isteğe bağlı)';
}
