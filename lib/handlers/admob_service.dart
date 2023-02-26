import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobService {
  static String? get bannerAdUnit {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7706650657314375/1206438130';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7706650657314375/6624370050';
    }
    return null;
  }

  static String? get interstitialAdUnit {
    if (Platform.isAndroid) {
      return 'ca-app-pub-7706650657314375/2086876167';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-7706650657314375/9058961706';
    }
    return null;
  }

  static final BannerAdListener bannerListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('Ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('Ad failed to load: $error');
    },
    onAdOpened: (ad) => debugPrint('Ad opened'),
    onAdClosed: (ad) => debugPrint('Ad closed'),
  );
}
