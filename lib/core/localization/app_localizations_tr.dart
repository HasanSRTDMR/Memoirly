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
  String get entrySaving => 'Kaydediliyor…';

  @override
  String get entrySaved => 'Kaydedildi';

  @override
  String get entryAutoSaveHint => 'Yazdıkça kaydedilir';

  @override
  String get pickEntryDateTime => 'Tarih ve saat seç';

  @override
  String get doneClose => 'Bitti';

  @override
  String get save => 'Kaydet';

  @override
  String get writeThoughts => 'Düşüncelerini yaz…';

  @override
  String get mood => 'Ruh hali';

  @override
  String get addTags => '#etiket veya virgülle (ör. tatil, yaz)';

  @override
  String get addImage => 'Görsel ekle';

  @override
  String get textColor => 'Yazı rengi';

  @override
  String get textColorDefault => 'Varsayılan';

  @override
  String get archiveListIcon => 'Ana sayfa ikonu';

  @override
  String get archiveListIconAuto => 'Otomatik';

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
  String get moodRhythm => 'Haftalık yazım';

  @override
  String get writingByDayHint =>
      'Her sütun bir gün. Çubuk ne kadar yüksekse o gün o kadar çok kayıt açmışsın.';

  @override
  String get last7Days => 'Bu hafta';

  @override
  String get volume => 'Kelime grafiği';

  @override
  String get avgWordsPerDay =>
      'Yazdığın günlere göre bu haftanın günlük ortalaması';

  @override
  String get avgWordsPerEntry => 'Bu haftaki her yazımda ortalama kelime';

  @override
  String get insightsWordsTotalSubtitle =>
      'Bu haftadaki tüm kayıtlarda toplam kelime';

  @override
  String insightsWordsAvgPerEntryLine(int avg) {
    return 'Kayıt başına ortalama: $avg kelime';
  }

  @override
  String get wordsPerEntryChartHint =>
      'Her çubuk bir kayıt (bu hafta, eskiden yeniye). Yükseklik o kayıttaki kelime sayısı (başlık+gövde). Alttaki sayı bu haftanın toplamı.';

  @override
  String get wordsPerDayChartHint =>
      'Üstteki günlerle aynı sıra: her çubuk o gün yazdığın toplam kelime.';

  @override
  String get insightsWordsChartEmpty => 'Bu hafta henüz yazım yok.';

  @override
  String get insightsPeriodToday => 'Bugün';

  @override
  String get insightsPeriodWeek => 'Bu hafta';

  @override
  String get insightsPeriodMonth => 'Bu ay';

  @override
  String get insightsPeriodYear => 'Bu yıl';

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
  String get moodValenceTitle => 'Ruh hali ortalaman';

  @override
  String get moodValenceSubtitle =>
      'Sağdaki menüden aralık seç. O dönemdeki kayıtlarda seçtiğin ruh hallerinin birleşimi; metin analizi değil, etiketlere göre hesaplanır.';

  @override
  String moodValenceScoreOf100(int score) {
    return '$score/100';
  }

  @override
  String moodValenceSample(int count) {
    return '$count kayıtta ruh hali seçilmiş';
  }

  @override
  String get moodValenceEmpty => 'Henüz ortalama yok';

  @override
  String get moodValenceEmptyBody =>
      'Yazarken ruh hali seçtiğinde, burada tüm arşivine göre bir ton özeti görünür.';

  @override
  String get moodTonePhraseVeryPositive =>
      'Yazıların genelde neşeli ve açık bir tonda.';

  @override
  String get moodTonePhrasePositive =>
      'Genelde olumlu ve sıcak bir çizgidesin.';

  @override
  String get moodTonePhraseBalanced => 'Duygusal olarak dengeli bir görünüm.';

  @override
  String get moodTonePhraseDifficult =>
      'Bazı kayıtlar daha ağır; bu normal ve sık geçicidir.';

  @override
  String get moodTonePhraseHeavy =>
      'Son kayıtların daha zorlayıcı duygular taşıyor; kendine nazik ol.';

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
  String get importTxt => 'TXT\'den içe aktar';

  @override
  String get importTxtSelectFile => 'Dosya seç';

  @override
  String get importTxtHint =>
      'Memoirly\'den dışa aktardığınız bir TXT dosyası seçin. Kayıtlar arşivinize eklenir.';

  @override
  String get importTxtError => 'Dosya okunamadı veya tanınmadı.';

  @override
  String get importTxtEmpty => 'Bu dosyada kayıt bulunamadı.';

  @override
  String importedEntriesCount(int count) {
    return '$count kayıt içe aktarıldı.';
  }

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
  String get imagePickerError =>
      'Galeri açılamadı. Uygulamayı tamamen durdurup yeniden çalıştırın (hot restart değil); emülatörde Google Play’li bir sistem görüntüsü deneyin.';

  @override
  String get emptyJournal => 'Henüz kayıt yok. Yazmaya başla.';

  @override
  String get titleHint => 'Başlık (isteğe bağlı)';

  @override
  String get firestoreApiDisabled =>
      'Bu Google Cloud projesinde Cloud Firestore API etkin değil. Google Cloud Console’da \"Cloud Firestore API\"yi açın, bir dakika bekleyip tekrar deneyin.';

  @override
  String get firestoreRulesHint =>
      'API açıksa Firestore güvenlik kurallarını ve Firebase’de Anonim girişin açık olduğunu kontrol edin.';

  @override
  String get quickNavTitle => 'Git';

  @override
  String get accountSheetTitle => 'Oturumunuz';

  @override
  String get anonymousSessionCloud =>
      'Anonim oturum. Kayıtlar bu kullanıcı için Firebase ile senkronize edilir.';

  @override
  String get anonymousSessionLocal =>
      'Yerel mod: veriler yalnızca bu cihazda kalır.';

  @override
  String get userIdLabel => 'Kullanıcı kimliği';

  @override
  String get close => 'Kapat';
}
