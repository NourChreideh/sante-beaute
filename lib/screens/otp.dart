import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlay_dmp_teams/custom/input_decorations.dart';
import 'package:mlay_dmp_teams/screens/login.dart';
import 'package:mlay_dmp_teams/repositories/auth_repository.dart';
import 'package:mlay_dmp_teams/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../helpers/auth_helper.dart';
import '../other_config.dart';
import '../repositories/profile_repository.dart';
import 'main.dart';

class Otp extends StatefulWidget {
  Otp(
      {Key key,
      this.verify_by = "email",
      this.user_id,
      this.fromLogIn = false,
      this.email,
      this.phone,
      this.password})
      : super(key: key);
  final String verify_by;
  final int user_id;
  final bool fromLogIn;
  final String email;
  final String phone;
  final String password;

  @override
  _OtpState createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  //controllers
  TextEditingController _verificationCodeController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    // SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    // SystemChrome.setEnabledSystemUIOverlays(
    //     [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onTapResend() async {
    var resendCodeResponse = await AuthRepository()
        .getResendCodeResponse(widget.user_id, widget.verify_by);

    if (resendCodeResponse.result == false) {
      ToastComponent.showDialog(resendCodeResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(resendCodeResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    }
  }

  onPressConfirm() async {
    var code = _verificationCodeController.text.toString();

    if (code == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context).otp_screen_verification_code_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var confirmCodeResponse =
        await AuthRepository().getConfirmCodeResponse(widget.user_id, code);

    if (confirmCodeResponse.result == false) {
      ToastComponent.showDialog(confirmCodeResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      ToastComponent.showDialog(confirmCodeResponse.message,
          gravity: Toast.center, duration: Toast.lengthLong);

      // if (widget.fromLogIn) {
      var loginResponse = await AuthRepository().getLoginResponse(
          widget.verify_by == 'email' ? widget.email : widget.phone,
          widget.password);
      AuthHelper().setUserData(loginResponse);
      // print(loginResponse.user.id);
      // ToastComponent.showDialog(loginResponse.message,
      //     gravity: Toast.center, duration: Toast.lengthLong);

      // push notification starts
      if (OtherConfig.USE_PUSH_NOTIFICATION) {
        final FirebaseMessaging _fcm = FirebaseMessaging.instance;

        await _fcm.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        String fcmToken = await _fcm.getToken();

        if (fcmToken != null) {
          print("--fcm token--");
          print(fcmToken);
          if (is_logged_in.$ == true) {
            // update device token
            var deviceTokenUpdateResponse = await ProfileRepository()
                .getDeviceTokenUpdateResponse(fcmToken);
          }
        }
      }
      //push norification ends
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Main();
      }));
      // }
      // if (widget.fromLogIn == false) {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return Login();
      //   }));
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    String _verify_by = widget.verify_by; //phone or email
    final _screen_height = MediaQuery.of(context).size.height;
    final _screen_width = MediaQuery.of(context).size.width;
    return Directionality(
      textDirection: app_language_rtl.$ ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            width: double.infinity,
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 0.0, bottom: 15),
                  child: Container(
                    width: 120,
                    height: 100,
                    child: Image.asset(
                      'assets/login_registration_form_logo.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    "${AppLocalizations.of(context).otp_screen_verify_your} " +
                        (_verify_by == "email"
                            ? AppLocalizations.of(context)
                                .otp_screen_email_account
                            : AppLocalizations.of(context)
                                .otp_screen_phone_number),
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                      width: _screen_width * (3 / 4),
                      child: _verify_by == "email"
                          ? Text(
                              AppLocalizations.of(context)
                                  .otp_screen_enter_verification_code_to_email,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: MyTheme.dark_grey, fontSize: 14))
                          : Text(
                              AppLocalizations.of(context)
                                  .otp_screen_enter_verification_code_to_phone,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: MyTheme.dark_grey, fontSize: 14))),
                ),
                Container(
                  width: _screen_width * (3 / 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: 36,
                              child: TextField(
                                controller: _verificationCodeController,
                                autofocus: false,
                                decoration:
                                    InputDecorations.buildInputDecoration_1(
                                        hint_text: "A X B 4 J H"),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: MyTheme.textfield_grey, width: 1),
                              borderRadius: const BorderRadius.all(
                                  Radius.circular(12.0))),
                          child: FlatButton(
                            minWidth: MediaQuery.of(context).size.width,
                            //height: 50,
                            color: MyTheme.accent_color,
                            shape: RoundedRectangleBorder(
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(5.0))),
                            child: Text(
                              AppLocalizations.of(context).otp_screen_confirm,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                            onPressed: () {
                              onPressConfirm();
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: InkWell(
                    onTap: () {
                      onTapResend();
                    },
                    child: Text(
                        AppLocalizations.of(context).otp_screen_resend_code,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            decoration: TextDecoration.underline,
                            fontSize: 13)),
                  ),
                ),
              ],
            )),
          ),
        ),
      ),
    );
  }
}
