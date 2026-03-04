class BrandData {
  final String name;
  final String logoUrl; // Canonical domain or URL.
  final String
  type; // 'bank', 'subscription', 'ecommerce', 'social', 'email', 'cloud', 'gaming', 'security'
  final String? region; // 'tr', 'global', 'us', 'eu', 'asia'

  const BrandData({
    required this.name,
    required this.logoUrl,
    required this.type,
    this.region,
  });
}

class BrandDatabase {
  // ==================== BANKALAR ====================

  /// Türk Bankaları
  static const List<BrandData> turkishBanks = [
    // Büyük Özel Bankalar
    BrandData(
      name: 'Akbank',
      logoUrl: 'akbank.com',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Garanti BBVA',
      logoUrl: 'garantibbva.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'İş Bankası',
      logoUrl: 'isbank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Yapı Kredi',
      logoUrl: 'yapikredi.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'QNB Finansbank',
      logoUrl: 'qnbfinansbank.com',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'DenizBank',
      logoUrl: 'denizbank.com',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(name: 'TEB', logoUrl: 'teb.com.tr', type: 'bank', region: 'tr'),
    BrandData(
      name: 'Odea Bank',
      logoUrl: 'odeabank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Fibabanka',
      logoUrl: 'fibabanka.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Burgan Bank',
      logoUrl: 'burganbank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Alternatif Bank',
      logoUrl: 'alternatifbank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Aktif Bank',
      logoUrl: 'aktifbank.com.tr',
      type: 'bank',
      region: 'tr',
    ),

    // Kamu Bankaları
    BrandData(
      name: 'Ziraat Bankası',
      logoUrl: 'ziraatbank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Halkbank',
      logoUrl: 'halkbank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'VakıfBank',
      logoUrl: 'vakifbank.com.tr',
      type: 'bank',
      region: 'tr',
    ),

    // Katılım Bankaları
    BrandData(
      name: 'Kuveyt Türk',
      logoUrl: 'kuveytturk.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Albaraka Türk',
      logoUrl: 'albaraka.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Türkiye Finans',
      logoUrl: 'turkiyefinans.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Vakıf Katılım',
      logoUrl: 'vakifkatilim.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Ziraat Katılım',
      logoUrl: 'ziraatkatilim.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Emlak Katılım',
      logoUrl: 'emlakkatilim.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Fiba Katılım',
      logoUrl: 'fibakatilim.com.tr',
      type: 'bank',
      region: 'tr',
    ),

    // Dijital Bankalar
    BrandData(
      name: 'Enpara',
      logoUrl: 'enpara.com',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'ONEBank',
      logoUrl: 'onebank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'HangiKredi',
      logoUrl: 'hangikredi.com',
      type: 'bank',
      region: 'tr',
    ),

    // Yabancı Bankalar (Türkiye)
    BrandData(
      name: 'HSBC Turkey',
      logoUrl: 'hsbc.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'ICBC Turkey',
      logoUrl: 'icbc.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Citibank Turkey',
      logoUrl: 'citibank.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Deutsche Bank Turkey',
      logoUrl: 'db.com',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Bank of America Turkey',
      logoUrl: 'bofa.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Rabobank Turkey',
      logoUrl: 'rabobank.com.tr',
      type: 'bank',
      region: 'tr',
    ),

    // Dijital Cüzdanlar/Ödeme
    BrandData(
      name: 'Papara',
      logoUrl: 'papara.com',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'Paycell',
      logoUrl: 'paycell.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'BKM Express',
      logoUrl: 'bkmexpress.com.tr',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(name: 'GPay', logoUrl: 'gpay.com.tr', type: 'bank', region: 'tr'),
    BrandData(
      name: 'Paribu',
      logoUrl: 'paribu.com',
      type: 'bank',
      region: 'tr',
    ),
    BrandData(
      name: 'BtcTurk',
      logoUrl: 'btcturk.com',
      type: 'bank',
      region: 'tr',
    ),
  ];

  /// Global Bankalar - ABD
  static const List<BrandData> usBanks = [
    BrandData(
      name: 'JPMorgan Chase',
      logoUrl: 'chase.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Bank of America',
      logoUrl: 'bankofamerica.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Wells Fargo',
      logoUrl: 'wellsfargo.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Citibank',
      logoUrl: 'citi.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Goldman Sachs',
      logoUrl: 'goldmansachs.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Morgan Stanley',
      logoUrl: 'morganstanley.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Capital One',
      logoUrl: 'capitalone.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'American Express',
      logoUrl: 'americanexpress.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Discover',
      logoUrl: 'discover.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'US Bank',
      logoUrl: 'usbank.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Truist',
      logoUrl: 'truist.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(name: 'PNC Bank', logoUrl: 'pnc.com', type: 'bank', region: 'us'),
    BrandData(name: 'TD Bank', logoUrl: 'td.com', type: 'bank', region: 'us'),
    BrandData(
      name: 'Charles Schwab',
      logoUrl: 'schwab.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Fidelity',
      logoUrl: 'fidelity.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(name: 'SoFi', logoUrl: 'sofi.com', type: 'bank', region: 'us'),
    BrandData(
      name: 'Ally Bank',
      logoUrl: 'ally.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(
      name: 'Marcus by Goldman Sachs',
      logoUrl: 'marcus.com',
      type: 'bank',
      region: 'us',
    ),
    BrandData(name: 'Chime', logoUrl: 'chime.com', type: 'bank', region: 'us'),
    BrandData(
      name: 'Varo Bank',
      logoUrl: 'varomoney.com',
      type: 'bank',
      region: 'us',
    ),
  ];

  /// Global Bankalar - Avrupa Birliği
  static const List<BrandData> euBanks = [
    BrandData(
      name: 'Deutsche Bank',
      logoUrl: 'deutsche-bank.de',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Commerzbank',
      logoUrl: 'commerzbank.de',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Barclays',
      logoUrl: 'barclays.co.uk',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'HSBC UK',
      logoUrl: 'hsbc.co.uk',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Lloyds Bank',
      logoUrl: 'lloydsbank.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'NatWest',
      logoUrl: 'natwest.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Santander UK',
      logoUrl: 'santander.co.uk',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'BNP Paribas',
      logoUrl: 'bnpparibas.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Crédit Agricole',
      logoUrl: 'credit-agricole.fr',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Société Générale',
      logoUrl: 'societegenerale.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Santander',
      logoUrl: 'santander.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(name: 'BBVA', logoUrl: 'bbva.com', type: 'bank', region: 'eu'),
    BrandData(name: 'ING', logoUrl: 'ing.com', type: 'bank', region: 'eu'),
    BrandData(
      name: 'Rabobank',
      logoUrl: 'rabobank.nl',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'ABN AMRO',
      logoUrl: 'abnamro.nl',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Credit Suisse',
      logoUrl: 'credit-suisse.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(name: 'UBS', logoUrl: 'ubs.com', type: 'bank', region: 'eu'),
    BrandData(
      name: 'Swissquote',
      logoUrl: 'swissquote.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'UniCredit',
      logoUrl: 'unicredit.eu',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Intesa Sanpaolo',
      logoUrl: 'intesasanpaolo.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Nordea',
      logoUrl: 'nordea.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Danske Bank',
      logoUrl: 'danskebank.dk',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(name: 'SEB', logoUrl: 'seb.se', type: 'bank', region: 'eu'),
    BrandData(
      name: 'Handelsbanken',
      logoUrl: 'handelsbanken.se',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(
      name: 'Comdirect',
      logoUrl: 'comdirect.de',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(name: 'N26', logoUrl: 'n26.com', type: 'bank', region: 'eu'),
    BrandData(
      name: 'Revolut',
      logoUrl: 'revolut.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(name: 'Monzo', logoUrl: 'monzo.com', type: 'bank', region: 'eu'),
    BrandData(
      name: 'Starling Bank',
      logoUrl: 'starlingbank.com',
      type: 'bank',
      region: 'eu',
    ),
    BrandData(name: 'Wise', logoUrl: 'wise.com', type: 'bank', region: 'eu'),
  ];

  /// Global Bankalar - Asya
  static const List<BrandData> asiaBanks = [
    BrandData(
      name: 'ICBC',
      logoUrl: 'icbc.com.cn',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'China Construction Bank',
      logoUrl: 'ccb.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Agricultural Bank of China',
      logoUrl: 'abchina.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Bank of China',
      logoUrl: 'boc.cn',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Mitsubishi UFJ',
      logoUrl: 'mufg.jp',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Sumitomo Mitsui',
      logoUrl: 'smbc.co.jp',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Mizuho',
      logoUrl: 'mizuho-fg.co.jp',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'HSBC Asia',
      logoUrl: 'hsbc.com.hk',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'DBS Bank',
      logoUrl: 'dbs.com.sg',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(name: 'OCBC', logoUrl: 'ocbc.com', type: 'bank', region: 'asia'),
    BrandData(name: 'UOB', logoUrl: 'uob.com.sg', type: 'bank', region: 'asia'),
    BrandData(
      name: 'Standard Chartered',
      logoUrl: 'sc.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'HDFC Bank',
      logoUrl: 'hdfcbank.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'ICICI Bank',
      logoUrl: 'icicibank.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'State Bank of India',
      logoUrl: 'sbi.co.in',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Axis Bank',
      logoUrl: 'axisbank.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Kotak Mahindra',
      logoUrl: 'kotak.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Bank of East Asia',
      logoUrl: 'hkbea.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Hang Seng Bank',
      logoUrl: 'hangseng.com',
      type: 'bank',
      region: 'asia',
    ),
    BrandData(
      name: 'Paytm Payments Bank',
      logoUrl: 'paytm.com',
      type: 'bank',
      region: 'asia',
    ),
  ];

  // Tüm bankaların birleşik listesi (geriye dönük uyumluluk)
  static List<BrandData> get banks => [
    ...turkishBanks,
    ...usBanks,
    ...euBanks,
    ...asiaBanks,
  ];

  // ==================== ABONELİKLER ====================

  /// Global Streaming - Video
  static const List<BrandData> videoStreaming = [
    BrandData(
      name: 'Netflix',
      logoUrl: 'netflix.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Disney+',
      logoUrl: 'disneyplus.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Hulu',
      logoUrl: 'hulu.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'HBO Max',
      logoUrl: 'max.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Paramount+',
      logoUrl: 'paramountplus.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Peacock',
      logoUrl: 'peacocktv.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Amazon Prime Video',
      logoUrl: 'primevideo.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Apple TV+',
      logoUrl: 'apple.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'YouTube Premium',
      logoUrl: 'youtube.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Crunchyroll',
      logoUrl: 'crunchyroll.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Funimation',
      logoUrl: 'funimation.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'MUBI',
      logoUrl: 'mubi.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Criterion Channel',
      logoUrl: 'criterionchannel.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Shudder',
      logoUrl: 'shudder.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Discovery+',
      logoUrl: 'discoveryplus.com',
      type: 'subscription',
      region: 'global',
    ),
  ];

  /// Türk Streaming
  static const List<BrandData> turkishStreaming = [
    BrandData(
      name: 'BluTV',
      logoUrl: 'blutv.com',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'Exxen',
      logoUrl: 'exxen.com',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'Gain',
      logoUrl: 'gain.tv',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'Bein Connect',
      logoUrl: 'beinconnect.com.tr',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'Digiturk Play',
      logoUrl: 'digiturk.com.tr',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'Tivibu',
      logoUrl: 'tivibu.com.tr',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'Turkcell TV+',
      logoUrl: 'tvplus.com.tr',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'Vodafone TV',
      logoUrl: 'vodafone.com.tr',
      type: 'subscription',
      region: 'tr',
    ),
    BrandData(
      name: 'TurkNet TV',
      logoUrl: 'turk.net',
      type: 'subscription',
      region: 'tr',
    ),
  ];

  /// Müzik Streaming
  static const List<BrandData> musicStreaming = [
    BrandData(
      name: 'Spotify',
      logoUrl: 'spotify.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Apple Music',
      logoUrl: 'apple.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'YouTube Music',
      logoUrl: 'music.youtube.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Amazon Music',
      logoUrl: 'music.amazon.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Tidal',
      logoUrl: 'tidal.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Deezer',
      logoUrl: 'deezer.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Pandora',
      logoUrl: 'pandora.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'SoundCloud',
      logoUrl: 'soundcloud.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Qobuz',
      logoUrl: 'qobuz.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Napster',
      logoUrl: 'napster.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Audiomack',
      logoUrl: 'audiomack.com',
      type: 'subscription',
      region: 'global',
    ),
  ];

  /// Podcast/Audiobook
  static const List<BrandData> audioContent = [
    BrandData(
      name: 'Audible',
      logoUrl: 'audible.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Storytel',
      logoUrl: 'storytel.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Blinkist',
      logoUrl: 'blinkist.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Scribd',
      logoUrl: 'scribd.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Libro.fm',
      logoUrl: 'libro.fm',
      type: 'subscription',
      region: 'global',
    ),
  ];

  /// SaaS/Productivity
  static const List<BrandData> productivity = [
    BrandData(
      name: 'Microsoft 365',
      logoUrl: 'microsoft.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Google Workspace',
      logoUrl: 'workspace.google.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Notion',
      logoUrl: 'notion.so',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Slack',
      logoUrl: 'slack.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Zoom',
      logoUrl: 'zoom.us',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Adobe Creative Cloud',
      logoUrl: 'adobe.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Figma',
      logoUrl: 'figma.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Sketch',
      logoUrl: 'sketch.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Canva',
      logoUrl: 'canva.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Asana',
      logoUrl: 'asana.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Monday.com',
      logoUrl: 'monday.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Trello',
      logoUrl: 'trello.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Todoist',
      logoUrl: 'todoist.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Evernote',
      logoUrl: 'evernote.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'LastPass',
      logoUrl: 'lastpass.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: '1Password',
      logoUrl: '1password.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Dashlane',
      logoUrl: 'dashlane.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'NordPass',
      logoUrl: 'nordpass.com',
      type: 'subscription',
      region: 'global',
    ),
  ];

  /// AI/Development Tools
  static const List<BrandData> aiAndDevTools = [
    BrandData(
      name: 'ChatGPT Plus',
      logoUrl: 'openai.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Claude Pro',
      logoUrl: 'anthropic.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'GitHub Copilot',
      logoUrl: 'github.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Midjourney',
      logoUrl: 'midjourney.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Jasper',
      logoUrl: 'jasper.ai',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Grammarly',
      logoUrl: 'grammarly.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Perplexity',
      logoUrl: 'perplexity.ai',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'ElevenLabs',
      logoUrl: 'elevenlabs.io',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Runway',
      logoUrl: 'runwayml.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'D-ID',
      logoUrl: 'd-id.com',
      type: 'subscription',
      region: 'global',
    ),
  ];

  /// VPN/Security
  static const List<BrandData> vpnAndSecurity = [
    BrandData(
      name: 'NordVPN',
      logoUrl: 'nordvpn.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'ExpressVPN',
      logoUrl: 'expressvpn.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Surfshark',
      logoUrl: 'surfshark.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'CyberGhost',
      logoUrl: 'cyberghost.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'ProtonVPN',
      logoUrl: 'protonvpn.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Private Internet Access',
      logoUrl: 'privateinternetaccess.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Bitdefender',
      logoUrl: 'bitdefender.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Kaspersky',
      logoUrl: 'kaspersky.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'McAfee',
      logoUrl: 'mcafee.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Norton',
      logoUrl: 'norton.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Malwarebytes',
      logoUrl: 'malwarebytes.com',
      type: 'subscription',
      region: 'global',
    ),
  ];

  /// Fitness/Sağlık
  static const List<BrandData> fitnessAndHealth = [
    BrandData(
      name: 'Peloton',
      logoUrl: 'onepeloton.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Apple Fitness+',
      logoUrl: 'apple.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Nike Training Club',
      logoUrl: 'nike.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Strava',
      logoUrl: 'strava.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'MyFitnessPal',
      logoUrl: 'myfitnesspal.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Fitbit Premium',
      logoUrl: 'fitbit.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Calm',
      logoUrl: 'calm.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Headspace',
      logoUrl: 'headspace.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Duolingo',
      logoUrl: 'duolingo.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Skillshare',
      logoUrl: 'skillshare.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'MasterClass',
      logoUrl: 'masterclass.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Coursera Plus',
      logoUrl: 'coursera.org',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Udemy',
      logoUrl: 'udemy.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'LinkedIn Learning',
      logoUrl: 'linkedin.com',
      type: 'subscription',
      region: 'global',
    ),
  ];

  /// Gazete/Dergi
  static const List<BrandData> newsAndMedia = [
    BrandData(
      name: 'The New York Times',
      logoUrl: 'nytimes.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'The Washington Post',
      logoUrl: 'washingtonpost.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'The Guardian',
      logoUrl: 'theguardian.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Financial Times',
      logoUrl: 'ft.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'The Economist',
      logoUrl: 'economist.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Wall Street Journal',
      logoUrl: 'wsj.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Bloomberg',
      logoUrl: 'bloomberg.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Medium',
      logoUrl: 'medium.com',
      type: 'subscription',
      region: 'global',
    ),
    BrandData(
      name: 'Substack',
      logoUrl: 'substack.com',
      type: 'subscription',
      region: 'global',
    ),
  ];

  // Tüm aboneliklerin birleşik listesi (geriye dönük uyumluluk)
  static List<BrandData> get subscriptions => [
    ...videoStreaming,
    ...turkishStreaming,
    ...musicStreaming,
    ...audioContent,
    ...productivity,
    ...aiAndDevTools,
    ...vpnAndSecurity,
    ...fitnessAndHealth,
    ...newsAndMedia,
  ];

  // ==================== E-TİCARET ====================

  /// Global E-Ticaret
  static const List<BrandData> globalEcommerce = [
    BrandData(
      name: 'Amazon',
      logoUrl: 'amazon.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'eBay',
      logoUrl: 'ebay.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Alibaba',
      logoUrl: 'alibaba.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'AliExpress',
      logoUrl: 'aliexpress.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Etsy',
      logoUrl: 'etsy.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Walmart',
      logoUrl: 'walmart.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Target',
      logoUrl: 'target.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Best Buy',
      logoUrl: 'bestbuy.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'ASOS',
      logoUrl: 'asos.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Zalando',
      logoUrl: 'zalando.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Rakuten',
      logoUrl: 'rakuten.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Flipkart',
      logoUrl: 'flipkart.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'JD.com',
      logoUrl: 'jd.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Shopee',
      logoUrl: 'shopee.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Lazada',
      logoUrl: 'lazada.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Wayfair',
      logoUrl: 'wayfair.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Newegg',
      logoUrl: 'newegg.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Mercado Libre',
      logoUrl: 'mercadolibre.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'OLX',
      logoUrl: 'olx.com',
      type: 'ecommerce',
      region: 'global',
    ),
    BrandData(
      name: 'Wildberries',
      logoUrl: 'wildberries.ru',
      type: 'ecommerce',
      region: 'global',
    ),
  ];

  /// Türk E-Ticaret
  static const List<BrandData> turkishEcommerce = [
    BrandData(
      name: 'Trendyol',
      logoUrl: 'trendyol.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Hepsiburada',
      logoUrl: 'hepsiburada.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(name: 'n11', logoUrl: 'n11.com', type: 'ecommerce', region: 'tr'),
    BrandData(
      name: 'Amazon Turkey',
      logoUrl: 'amazon.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Çiçek Sepeti',
      logoUrl: 'ciceksepeti.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Getir',
      logoUrl: 'getir.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Migros Sanalmarket',
      logoUrl: 'migros.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'CarrefourSA',
      logoUrl: 'carrefoursa.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'MediaMarkt Turkey',
      logoUrl: 'mediamarkt.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Teknosa',
      logoUrl: 'teknosa.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Vatan Bilgisayar',
      logoUrl: 'vatanbilgisayar.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'İtopya',
      logoUrl: 'itopya.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'GamePower',
      logoUrl: 'gamepower.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Bimeks',
      logoUrl: 'bimeks.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'PttAVM',
      logoUrl: 'pttavm.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Morhipo',
      logoUrl: 'morhipo.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Boyner',
      logoUrl: 'boyner.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Defacto',
      logoUrl: 'defacto.com.tr',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'LC Waikiki',
      logoUrl: 'lcwaikiki.com',
      type: 'ecommerce',
      region: 'tr',
    ),
    BrandData(
      name: 'Koton',
      logoUrl: 'koton.com',
      type: 'ecommerce',
      region: 'tr',
    ),
  ];

  // Tüm e-ticaret birleşik liste
  static List<BrandData> get ecommerce => [
    ...globalEcommerce,
    ...turkishEcommerce,
  ];

  // ==================== SOSYAL MEDYA ====================
  static const List<BrandData> socialMedia = [
    BrandData(
      name: 'Facebook',
      logoUrl: 'facebook.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Instagram',
      logoUrl: 'instagram.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Twitter',
      logoUrl: 'twitter.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(name: 'X', logoUrl: 'x.com', type: 'social', region: 'global'),
    BrandData(
      name: 'LinkedIn',
      logoUrl: 'linkedin.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'TikTok',
      logoUrl: 'tiktok.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'YouTube',
      logoUrl: 'youtube.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Snapchat',
      logoUrl: 'snapchat.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Pinterest',
      logoUrl: 'pinterest.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Reddit',
      logoUrl: 'reddit.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Discord',
      logoUrl: 'discord.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Twitch',
      logoUrl: 'twitch.tv',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Telegram',
      logoUrl: 'telegram.org',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'WhatsApp',
      logoUrl: 'whatsapp.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Threads',
      logoUrl: 'threads.net',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Bluesky',
      logoUrl: 'bsky.app',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Mastodon',
      logoUrl: 'mastodon.social',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Tumblr',
      logoUrl: 'tumblr.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Quora',
      logoUrl: 'quora.com',
      type: 'social',
      region: 'global',
    ),
    BrandData(
      name: 'Nextdoor',
      logoUrl: 'nextdoor.com',
      type: 'social',
      region: 'global',
    ),
  ];

  // ==================== E-POSTA SERVİSLERİ ====================
  static const List<BrandData> emailServices = [
    BrandData(
      name: 'Gmail',
      logoUrl: 'gmail.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'Outlook',
      logoUrl: 'outlook.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'Yahoo Mail',
      logoUrl: 'yahoo.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'ProtonMail',
      logoUrl: 'proton.me',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'iCloud Mail',
      logoUrl: 'icloud.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'Yandex Mail',
      logoUrl: 'yandex.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'Mail.ru',
      logoUrl: 'mail.ru',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'Zoho Mail',
      logoUrl: 'zoho.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'Fastmail',
      logoUrl: 'fastmail.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(name: 'GMX', logoUrl: 'gmx.com', type: 'email', region: 'global'),
    BrandData(
      name: 'Tutanota',
      logoUrl: 'tutanota.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(name: 'Hey', logoUrl: 'hey.com', type: 'email', region: 'global'),
    BrandData(
      name: 'AOL Mail',
      logoUrl: 'aol.com',
      type: 'email',
      region: 'global',
    ),
    BrandData(
      name: 'Zoho',
      logoUrl: 'zoho.com',
      type: 'email',
      region: 'global',
    ),
  ];

  // ==================== BULUT DEPOLAMA ====================
  static const List<BrandData> cloudStorage = [
    BrandData(
      name: 'Google Drive',
      logoUrl: 'drive.google.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'Dropbox',
      logoUrl: 'dropbox.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'OneDrive',
      logoUrl: 'onedrive.live.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'iCloud',
      logoUrl: 'icloud.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(name: 'Box', logoUrl: 'box.com', type: 'cloud', region: 'global'),
    BrandData(
      name: 'Mega',
      logoUrl: 'mega.nz',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'pCloud',
      logoUrl: 'pcloud.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'Sync.com',
      logoUrl: 'sync.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'Yandex Disk',
      logoUrl: 'disk.yandex.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'Amazon Drive',
      logoUrl: 'amazon.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'IDrive',
      logoUrl: 'idrive.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'Backblaze',
      logoUrl: 'backblaze.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'SpiderOak',
      logoUrl: 'spideroak.com',
      type: 'cloud',
      region: 'global',
    ),
    BrandData(
      name: 'SugarSync',
      logoUrl: 'sugarsync.com',
      type: 'cloud',
      region: 'global',
    ),
  ];

  // ==================== OYUN PLATFORMLARI ====================
  static const List<BrandData> gaming = [
    BrandData(
      name: 'Steam',
      logoUrl: 'steampowered.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Epic Games Store',
      logoUrl: 'epicgames.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'PlayStation Network',
      logoUrl: 'playstation.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Xbox Live',
      logoUrl: 'xbox.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Nintendo eShop',
      logoUrl: 'nintendo.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'GOG',
      logoUrl: 'gog.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'EA App',
      logoUrl: 'ea.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Ubisoft Connect',
      logoUrl: 'ubisoft.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Battle.net',
      logoUrl: 'battle.net',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'GeForce NOW',
      logoUrl: 'geforcenow.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Xbox Game Pass',
      logoUrl: 'xbox.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'PlayStation Plus',
      logoUrl: 'playstation.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Discord Nitro',
      logoUrl: 'discord.com',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Twitch',
      logoUrl: 'twitch.tv',
      type: 'gaming',
      region: 'global',
    ),
    BrandData(
      name: 'Humble Bundle',
      logoUrl: 'humblebundle.com',
      type: 'gaming',
      region: 'global',
    ),
  ];

  // ==================== ŞİFRE YÖNETİCİLERİ (Meta) ====================
  static const List<BrandData> passwordManagers = [
    BrandData(
      name: '1Password',
      logoUrl: '1password.com',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'LastPass',
      logoUrl: 'lastpass.com',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'Dashlane',
      logoUrl: 'dashlane.com',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'Bitwarden',
      logoUrl: 'bitwarden.com',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'NordPass',
      logoUrl: 'nordpass.com',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'Keeper',
      logoUrl: 'keepersecurity.com',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'RoboForm',
      logoUrl: 'roboform.com',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'Proton Pass',
      logoUrl: 'proton.me',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'Enpass',
      logoUrl: 'enpass.io',
      type: 'security',
      region: 'global',
    ),
    BrandData(
      name: 'LogMeOnce',
      logoUrl: 'logmeonce.com',
      type: 'security',
      region: 'global',
    ),
  ];

  // ==================== TÜM MARKALAR ====================
  static List<BrandData> get allBrands => [
    ...banks,
    ...subscriptions,
    ...ecommerce,
    ...socialMedia,
    ...emailServices,
    ...cloudStorage,
    ...gaming,
    ...passwordManagers,
  ];

  // ==================== ARAMA FONKSİYONLARI ====================

  static List<BrandData> getBankSuggestions(String query) {
    if (query.isEmpty) return banks.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return banks
        .where(
          (bank) => _normalizeForSearch(bank.name).contains(normalizedQuery),
        )
        .toList();
  }

  static List<BrandData> getSubscriptionSuggestions(String query) {
    if (query.isEmpty) return subscriptions.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return subscriptions
        .where(
          (subscription) =>
              _normalizeForSearch(subscription.name).contains(normalizedQuery),
        )
        .toList();
  }

  static List<BrandData> getEcommerceSuggestions(String query) {
    if (query.isEmpty) return ecommerce.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return ecommerce
        .where(
          (item) => _normalizeForSearch(item.name).contains(normalizedQuery),
        )
        .toList();
  }

  static List<BrandData> getSocialMediaSuggestions(String query) {
    if (query.isEmpty) return socialMedia.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return socialMedia
        .where(
          (item) => _normalizeForSearch(item.name).contains(normalizedQuery),
        )
        .toList();
  }

  static List<BrandData> getEmailServiceSuggestions(String query) {
    if (query.isEmpty) return emailServices.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return emailServices
        .where(
          (item) => _normalizeForSearch(item.name).contains(normalizedQuery),
        )
        .toList();
  }

  static List<BrandData> getCloudStorageSuggestions(String query) {
    if (query.isEmpty) return cloudStorage.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return cloudStorage
        .where(
          (item) => _normalizeForSearch(item.name).contains(normalizedQuery),
        )
        .toList();
  }

  static List<BrandData> getGamingSuggestions(String query) {
    if (query.isEmpty) return gaming.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return gaming
        .where(
          (item) => _normalizeForSearch(item.name).contains(normalizedQuery),
        )
        .toList();
  }

  static List<BrandData> getPasswordManagerSuggestions(String query) {
    if (query.isEmpty) return passwordManagers.take(5).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return passwordManagers
        .where(
          (item) => _normalizeForSearch(item.name).contains(normalizedQuery),
        )
        .toList();
  }

  /// Tüm markalarda ara
  static List<BrandData> getAllSuggestions(String query) {
    if (query.isEmpty) return allBrands.take(10).toList();
    final normalizedQuery = _normalizeForSearch(query);
    return allBrands
        .where(
          (brand) => _normalizeForSearch(brand.name).contains(normalizedQuery),
        )
        .toList();
  }

  /// Bölgeye göre filtrele
  static List<BrandData> getByRegion(String region) {
    return allBrands.where((brand) => brand.region == region).toList();
  }

  /// Türe göre filtrele
  static List<BrandData> getByType(String type) {
    return allBrands.where((brand) => brand.type == type).toList();
  }

  static String _normalizeForSearch(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .trim();
  }

  // ==================== İSTATİSTİKLER ====================
  static Map<String, int> getStats() {
    return {
      'total': allBrands.length,
      'banks': banks.length,
      'subscriptions': subscriptions.length,
      'ecommerce': ecommerce.length,
      'socialMedia': socialMedia.length,
      'emailServices': emailServices.length,
      'cloudStorage': cloudStorage.length,
      'gaming': gaming.length,
      'passwordManagers': passwordManagers.length,
      'turkish': allBrands.where((b) => b.region == 'tr').length,
      'global': allBrands.where((b) => b.region == 'global').length,
      'us': allBrands.where((b) => b.region == 'us').length,
      'eu': allBrands.where((b) => b.region == 'eu').length,
      'asia': allBrands.where((b) => b.region == 'asia').length,
    };
  }
}
