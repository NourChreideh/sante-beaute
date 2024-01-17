import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale;

  LocaleProvider() {
    _locale = getLocale();
  }

  Locale getLocale() {
    print(_locale);
    if (_locale == null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        app_language.$ = "sa";
        app_language.save();
        app_mobile_language.$ = "ar";
        app_mobile_language.save();
        app_language_rtl.$ = true;
        app_language_rtl.save();
        notifyListeners();
      });
      _locale = Locale("ar");
    }
    return _locale;
  }

  Locale get locale => _locale;

  void setLocale(String code) {
    _locale = Locale(code, '');
    notifyListeners();
  }
}
