// import 'package:mlay_dmp_teams/app_config.dart';
// import 'package:mlay_dmp_teams/my_theme.dart';
// import 'package:mlay_dmp_teams/other_config.dart';
// import 'package:mlay_dmp_teams/social_config.dart';
// import 'package:mlay_dmp_teams/ui_elements/auth_ui.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mlay_dmp_teams/custom/input_decorations.dart';
// import 'package:mlay_dmp_teams/custom/intl_phone_input.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
// import 'package:intl_phone_number_input/intl_phone_number_input.dart';
// import 'package:mlay_dmp_teams/screens/registration.dart';
// import 'package:mlay_dmp_teams/screens/main.dart';
// import 'package:mlay_dmp_teams/screens/password_forget.dart';
// import 'package:mlay_dmp_teams/custom/toast_component.dart';
// import 'package:toast/toast.dart';
// import 'package:mlay_dmp_teams/repositories/auth_repository.dart';
// import 'package:mlay_dmp_teams/helpers/auth_helper.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';
// import 'package:mlay_dmp_teams/repositories/profile_repository.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:twitter_login/twitter_login.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'dart:math';
// import 'package:crypto/crypto.dart';
// import 'dart:convert';
// import 'dart:io' show Platform;

// class Login extends StatefulWidget {
//   @override
//   _LoginState createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   String _login_by = "email"; //phone or email
//   String initialCountry = 'US';
//   PhoneNumber phoneCode = PhoneNumber(isoCode: 'US', dialCode: "+1");
//   String _phone = "";

//   //controllers
//   TextEditingController _phoneNumberController = TextEditingController();
//   TextEditingController _emailController = TextEditingController();
//   TextEditingController _passwordController = TextEditingController();

//   @override
//   void initState() {
//     //on Splash Screen hide statusbar
//     SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
//     super.initState();
//   }

//   @override
//   void dispose() {
//     //before going to other screen show statusbar
//     SystemChrome.setEnabledSystemUIOverlays(
//         [SystemUiOverlay.top, SystemUiOverlay.bottom]);
//     super.dispose();
//   }

//   onPressedLogin() async {
//     var email = _emailController.text.toString();
//     var password = _passwordController.text.toString();

//     if (_login_by == 'email' && email == "") {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context).login_screen_email_warning,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     } else if (_login_by == 'phone' && _phone == "") {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context).login_screen_phone_warning,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     } else if (password == "") {
//       ToastComponent.showDialog(
//           AppLocalizations.of(context).login_screen_password_warning,
//           gravity: Toast.center,
//           duration: Toast.lengthLong);
//       return;
//     }

//     var loginResponse = await AuthRepository()
//         .getLoginResponse(_login_by == 'email' ? email : _phone, password);
//     if (loginResponse.result == false) {
//       ToastComponent.showDialog(loginResponse.message,
//           gravity: Toast.center, duration: Toast.lengthLong);
//     } else {
//       ToastComponent.showDialog(loginResponse.message,
//           gravity: Toast.center, duration: Toast.lengthLong);
//       AuthHelper().setUserData(loginResponse);
//       // push notification starts
//       if (OtherConfig.USE_PUSH_NOTIFICATION) {
//         final FirebaseMessaging _fcm = FirebaseMessaging.instance;

//         await _fcm.requestPermission(
//           alert: true,
//           announcement: false,
//           badge: true,
//           carPlay: false,
//           criticalAlert: false,
//           provisional: false,
//           sound: true,
//         );

//         String fcmToken = await _fcm.getToken();

//         if (fcmToken != null) {
//           print("--fcm token--");
//           print(fcmToken);
//           if (is_logged_in.$ == true) {
//             // update device token
//             var deviceTokenUpdateResponse = await ProfileRepository()
//                 .getDeviceTokenUpdateResponse(fcmToken);
//           }
//         }
//       }
//       //push norification ends
//       Navigator.push(context, MaterialPageRoute(builder: (context) {
//         return Main();
//       }));
//     }
//   }

//   onPressedFacebookLogin() async {
//     final facebookLogin =
//         await FacebookAuth.instance.login(loginBehavior: LoginBehavior.webOnly);

//     if (facebookLogin.status == LoginStatus.success) {
//       // get the user data
//       // by default we get the userId, email,name and picture
//       final userData = await FacebookAuth.instance.getUserData();
//       var loginResponse = await AuthRepository().getSocialLoginResponse(
//           "facebook",
//           userData['name'].toString(),
//           userData['email'].toString(),
//           userData['id'].toString(),
//           access_token: facebookLogin.accessToken.token);
//       print("..........................${loginResponse.toString()}");
//       if (loginResponse.result == false) {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);
//       } else {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);

//         AuthHelper().setUserData(loginResponse);
//         Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return Main();
//         }));
//         FacebookAuth.instance.logOut();
//       }
//       // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");

//     } else {
//       print("....Facebook auth Failed.........");
//       print(facebookLogin.status);
//       print(facebookLogin.message);
//     }
//   }

//   onPressedGoogleLogin() async {
//     try {
//       final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

//       print(googleUser.toString());

//       GoogleSignInAuthentication googleSignInAuthentication =
//           await googleUser.authentication;
//       String accessToken = googleSignInAuthentication.accessToken;

//       print("accessToken $accessToken");
//       print("displayName ${googleUser.displayName}");
//       print("email ${googleUser.email}");
//       print("googleUser.id ${googleUser.id}");

//       var loginResponse = await AuthRepository().getSocialLoginResponse(
//           "google", googleUser.displayName, googleUser.email, googleUser.id,
//           access_token: accessToken);

//       if (loginResponse.result == false) {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);
//       } else {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);
//         AuthHelper().setUserData(loginResponse);
//         Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return Main();
//         }));
//       }
//       GoogleSignIn().disconnect();
//     } on Exception catch (e) {
//       print("error is ....... $e");
//       // TODO
//     }
//   }

//   onPressedTwitterLogin() async {
//     try {
//       final twitterLogin = new TwitterLogin(
//           apiKey: SocialConfig().twitter_consumer_key,
//           apiSecretKey: SocialConfig().twitter_consumer_secret,
//           redirectURI: 'mlayecommerceflutterapp://');
//       // Trigger the sign-in flow

//       final authResult = await twitterLogin.login();

//       print("authResult");

//       // print(json.encode(authResult));

//       var loginResponse = await AuthRepository().getSocialLoginResponse(
//           "twitter",
//           authResult.user.name,
//           authResult.user.email,
//           authResult.user.id.toString(),
//           access_token: authResult.authToken,
//           secret_token: authResult.authTokenSecret);

//       if (loginResponse.result == false) {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);
//       } else {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);
//         AuthHelper().setUserData(loginResponse);
//         Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return Main();
//         }));
//       }
//     } on Exception catch (e) {
//       print("error is ....... $e");
//       // TODO
//     }
//   }

//   String generateNonce([int length = 32]) {
//     final charset =
//         '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
//     final random = Random.secure();
//     return List.generate(length, (_) => charset[random.nextInt(charset.length)])
//         .join();
//   }

//   /// Returns the sha256 hash of [input] in hex notation.
//   String sha256ofString(String input) {
//     final bytes = utf8.encode(input);
//     final digest = sha256.convert(bytes);
//     return digest.toString();
//   }

//   signInWithApple() async {
//     // To prevent replay attacks with the credential returned from Apple, we
//     // include a nonce in the credential request. When signing in with
//     // Firebase, the nonce in the id token returned by Apple, is expected to
//     // match the sha256 hash of `rawNonce`.
//     final rawNonce = generateNonce();
//     final nonce = sha256ofString(rawNonce);

//     // Request credential for the currently signed in Apple account.
//     try {
//       final appleCredential = await SignInWithApple.getAppleIDCredential(
//         scopes: [
//           AppleIDAuthorizationScopes.email,
//           AppleIDAuthorizationScopes.fullName,
//         ],
//         nonce: nonce,
//       );

//       var loginResponse = await AuthRepository().getSocialLoginResponse(
//           "apple",
//           appleCredential.givenName,
//           appleCredential.email,
//           appleCredential.userIdentifier,
//           access_token: appleCredential.identityToken);

//       if (loginResponse.result == false) {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);
//       } else {
//         ToastComponent.showDialog(loginResponse.message,
//             gravity: Toast.center, duration: Toast.lengthLong);
//         AuthHelper().setUserData(loginResponse);
//         Navigator.push(context, MaterialPageRoute(builder: (context) {
//           return Main();
//         }));
//       }
//     } on Exception catch (e) {
//       print(e);
//       // TODO
//     }

//     // Create an `OAuthCredential` from the credential returned by Apple.
//     // final oauthCredential = OAuthProvider("apple.com").credential(
//     //   idToken: appleCredential.identityToken,
//     //   rawNonce: rawNonce,
//     // );
//     //print(oauthCredential.accessToken);

//     // Sign in the user with Firebase. If the nonce we generated earlier does
//     // not match the nonce in `appleCredential.identityToken`, sign in will fail.
//     //return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final _screen_height = MediaQuery.of(context).size.height;
//     final _screen_width = MediaQuery.of(context).size.width;
//     return AuthScreen.buildScreen(
//         context,
//         "${AppLocalizations.of(context).login_screen_login_to} " +
//             AppConfig.app_name,
//         buildBody(context, _screen_width));
//   }

//   Widget buildBody(BuildContext context, double _screen_width) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       children: [
//         Container(
//           width: _screen_width * (3 / 4),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   _login_by == "email"
//                       ? AppLocalizations.of(context).login_screen_email
//                       : AppLocalizations.of(context).login_screen_phone,
//                   style: TextStyle(
//                       color: MyTheme.accent_color, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               if (_login_by == "email")
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Container(
//                         height: 36,
//                         child: TextField(
//                           controller: _emailController,
//                           autofocus: false,
//                           decoration: InputDecorations.buildInputDecoration_1(
//                               hint_text: "johndoe@example.com"),
//                         ),
//                       ),
//                       otp_addon_installed.$
//                           ? GestureDetector(
//                               onTap: () {
//                                 setState(() {
//                                   _login_by = "phone";
//                                 });
//                               },
//                               child: Text(
//                                 AppLocalizations.of(context)
//                                     .login_screen_or_login_with_phone,
//                                 style: TextStyle(
//                                     color: MyTheme.accent_color,
//                                     fontStyle: FontStyle.italic,
//                                     decoration: TextDecoration.underline),
//                               ),
//                             )
//                           : Container()
//                     ],
//                   ),
//                 )
//               else
//                 Padding(
//                   padding: const EdgeInsets.only(bottom: 8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//                     children: [
//                       Container(
//                         height: 36,
//                         child: CustomInternationalPhoneNumberInput(
//                           onInputChanged: (PhoneNumber number) {
//                             print(number.phoneNumber);
//                             setState(() {
//                               _phone = number.phoneNumber;
//                             });
//                           },
//                           onInputValidated: (bool value) {
//                             print(value);
//                           },
//                           selectorConfig: SelectorConfig(
//                             selectorType: PhoneInputSelectorType.DIALOG,
//                           ),
//                           ignoreBlank: false,
//                           autoValidateMode: AutovalidateMode.disabled,
//                           selectorTextStyle:
//                               TextStyle(color: MyTheme.font_grey),
//                           textStyle: TextStyle(color: MyTheme.font_grey),
//                           initialValue: phoneCode,
//                           textFieldController: _phoneNumberController,
//                           formatInput: true,
//                           keyboardType: TextInputType.numberWithOptions(
//                               signed: true, decimal: true),
//                           inputDecoration:
//                               InputDecorations.buildInputDecoration_phone(
//                                   hint_text: "01XXX XXX XXX"),
//                           onSaved: (PhoneNumber number) {
//                             print('On Saved: $number');
//                           },
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           setState(() {
//                             _login_by = "email";
//                           });
//                         },
//                         child: Text(
//                           AppLocalizations.of(context)
//                               .login_screen_or_login_with_email,
//                           style: TextStyle(
//                               color: MyTheme.accent_color,
//                               fontStyle: FontStyle.italic,
//                               decoration: TextDecoration.underline),
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 4.0),
//                 child: Text(
//                   AppLocalizations.of(context).login_screen_password,
//                   style: TextStyle(
//                       color: MyTheme.accent_color, fontWeight: FontWeight.w600),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(bottom: 8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Container(
//                       height: 36,
//                       child: TextField(
//                         controller: _passwordController,
//                         autofocus: false,
//                         obscureText: true,
//                         enableSuggestions: false,
//                         autocorrect: false,
//                         decoration: InputDecorations.buildInputDecoration_1(
//                             hint_text: "• • • • • • • •"),
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.push(context,
//                             MaterialPageRoute(builder: (context) {
//                           return PasswordForget();
//                         }));
//                       },
//                       child: Text(
//                         AppLocalizations.of(context)
//                             .login_screen_forgot_password,
//                         style: TextStyle(
//                             color: MyTheme.accent_color,
//                             fontStyle: FontStyle.italic,
//                             decoration: TextDecoration.underline),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 30.0),
//                 child: Container(
//                   height: 45,
//                   decoration: BoxDecoration(
//                       border:
//                           Border.all(color: MyTheme.textfield_grey, width: 1),
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(12.0))),
//                   child: FlatButton(
//                     minWidth: MediaQuery.of(context).size.width,
//                     //height: 50,
//                     color: MyTheme.accent_color,
//                     shape: RoundedRectangleBorder(
//                         borderRadius:
//                             const BorderRadius.all(Radius.circular(6.0))),
//                     child: Text(
//                       AppLocalizations.of(context).login_screen_log_in,
//                       style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600),
//                     ),
//                     onPressed: () {
//                       onPressedLogin();
//                     },
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 15.0, bottom: 15),
//                 child: Center(
//                     child: Text(
//                   AppLocalizations.of(context)
//                       .login_screen_or_create_new_account,
//                   style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
//                 )),
//               ),
//               Container(
//                 height: 45,
//                 child: FlatButton(
//                   minWidth: MediaQuery.of(context).size.width,
//                   //height: 50,
//                   color: MyTheme.amber,
//                   shape: RoundedRectangleBorder(
//                       borderRadius:
//                           const BorderRadius.all(Radius.circular(6.0))),
//                   child: Text(
//                     AppLocalizations.of(context).login_screen_sign_up,
//                     style: TextStyle(
//                         color: MyTheme.accent_color,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600),
//                   ),
//                   onPressed: () {
//                     Navigator.push(context,
//                         MaterialPageRoute(builder: (context) {
//                       return Registration();
//                     }));
//                   },
//                 ),
//               ),
//               Visibility(
//                 visible: allow_google_login.$ || allow_facebook_login.$,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 20.0),
//                   child: Center(
//                       child: Text(
//                     AppLocalizations.of(context).login_screen_login_with,
//                     style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
//                   )),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 15.0),
//                 child: Center(
//                   child: Container(
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Visibility(
//                           visible: allow_google_login.$,
//                           child: InkWell(
//                             onTap: () {
//                               onPressedGoogleLogin();
//                             },
//                             child: Container(
//                               width: 28,
//                               child: Image.asset("assets/google_logo.png"),
//                             ),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 15.0),
//                           child: Visibility(
//                             visible: allow_facebook_login.$,
//                             child: InkWell(
//                               onTap: () {
//                                 onPressedFacebookLogin();
//                               },
//                               child: Container(
//                                 width: 28,
//                                 child: Image.asset("assets/facebook_logo.png"),
//                               ),
//                             ),
//                           ),
//                         ),
//                         if (allow_twitter_login.$)
//                           Padding(
//                             padding: const EdgeInsets.only(left: 15.0),
//                             child: InkWell(
//                               onTap: () {
//                                 onPressedTwitterLogin();
//                               },
//                               child: Container(
//                                 width: 28,
//                                 child: Image.asset("assets/twitter_logo.png"),
//                               ),
//                             ),
//                           ),
//                         if (Platform.isIOS)
//                           Padding(
//                             padding: const EdgeInsets.only(left: 15.0),
//                             // visible: true,
//                             child: InkWell(
//                               onTap: () async {
//                                 signInWithApple();
//                               },
//                               child: Container(
//                                 width: 28,
//                                 child: Image.asset("assets/apple_logo.png"),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         )
//       ],
//     );
//   }
// }

import 'package:flutter/gestures.dart';
import 'package:mlay_dmp_teams/app_config.dart';
import 'package:mlay_dmp_teams/my_theme.dart';
import 'package:mlay_dmp_teams/other_config.dart';
import 'package:mlay_dmp_teams/social_config.dart';
import 'package:mlay_dmp_teams/ui_elements/auth_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mlay_dmp_teams/custom/input_decorations.dart';
import 'package:mlay_dmp_teams/custom/intl_phone_input.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mlay_dmp_teams/screens/registration.dart';
import 'package:mlay_dmp_teams/screens/main.dart';
import 'package:mlay_dmp_teams/screens/password_forget.dart';
import 'package:mlay_dmp_teams/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:mlay_dmp_teams/repositories/auth_repository.dart';
import 'package:mlay_dmp_teams/helpers/auth_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';
import 'package:mlay_dmp_teams/repositories/profile_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:twitter_login/twitter_login.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io' show Platform;

import '../custom/device_info.dart';
import '../providers/firebase_provider.dart';
import 'common_webview_screen.dart';
import 'otp.dart';

class Login extends StatefulWidget {
  const Login({Key key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isAgree = false;
  String _login_by = "phone"; //phone or email
  String initialCountry = 'SA';
  PhoneNumber phoneCode = PhoneNumber(isoCode: 'SA', dialCode: "+966");
  String _phone = "";

  //controllers
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    //on Splash Screen hide statusbar
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    super.initState();
  }

  @override
  void dispose() {
    //before going to other screen show statusbar
    SystemChrome.setEnabledSystemUIOverlays(
        [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  onPressedLogin() async {
    var email = _emailController.text.toString();
    var password = "123456789mlayapponline";

    if (_login_by == 'email' && email == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context).login_screen_email_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (_login_by == 'phone' && _phone == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context).login_screen_phone_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    } else if (password == "") {
      ToastComponent.showDialog(
          AppLocalizations.of(context).login_screen_password_warning,
          gravity: Toast.center,
          duration: Toast.lengthLong);
      return;
    }

    var loginResponse = await AuthRepository()
        .getLoginResponse(_login_by == 'email' ? email : _phone, password);
    FirebaseProvider().sendCodeToPhone(_login_by == 'email' ? email : _phone);
    if (loginResponse.result == false) {
      Random random = new Random();
      int randomNumber = random.nextInt(999000) + 1000;
      var name = "user" + " " + "guest"; //_nameController.text.toString();
      var email = randomNumber.toString() +
          "@mlayapp.com"; //_emailController.text.toString();
      var password = "123456789mlayapponline";
      var password_confirm = "123456789mlayapponline";
      if (name == "") {
        ToastComponent.showDialog(
            AppLocalizations.of(context).registration_screen_name_warning,
            gravity: Toast.center,
            duration: Toast.lengthLong);
        return;
      } else if (_login_by == 'phone' && _phone == "") {
        ToastComponent.showDialog(
            AppLocalizations.of(context).registration_screen_phone_warning,
            gravity: Toast.center,
            duration: Toast.lengthLong);
        return;
      }

      var signupResponse = await AuthRepository().getSignupResponse(
          name,
          _login_by == 'email' ? email : _phone,
          password,
          password_confirm,
          _login_by);
      FirebaseProvider().sendCodeToPhone(_login_by == 'email' ? email : _phone);

      if (signupResponse.result == false) {
        ToastComponent.showDialog(signupResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
      } else {
        // ToastComponent.showDialog(signupResponse.message,
        //     gravity: Toast.center, duration: Toast.lengthLong);
        if ((mail_verification_status.$ && _login_by == "email") ||
            _login_by == "phone") {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Otp(
              verify_by: _login_by,
              user_id: signupResponse.user_id,
              email: email,
              phone: _phone,
              password: password,
            );
          }));
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return Login();
          }));
        }
      }
      // ToastComponent.showDialog(loginResponse.message,
      //     gravity: Toast.center, duration: Toast.lengthLong);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Otp(
          verify_by: _login_by,
          user_id: loginResponse.user.id,
          fromLogIn: true,
          email: email,
          phone: _phone,
          password: password,
        );
      }));
    }
  }

  onPressedFacebookLogin() async {
    final facebookLogin =
        await FacebookAuth.instance.login(loginBehavior: LoginBehavior.webOnly);

    if (facebookLogin.status == LoginStatus.success) {
      // get the user data
      // by default we get the userId, email,name and picture
      final userData = await FacebookAuth.instance.getUserData();
      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "facebook",
          userData['name'].toString(),
          userData['email'].toString(),
          userData['id'].toString(),
          access_token: facebookLogin.accessToken.token);
      print("..........................${loginResponse.toString()}");
      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
      } else {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);

        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
        FacebookAuth.instance.logOut();
      }
      // final userData = await FacebookAuth.instance.getUserData(fields: "email,birthday,friends,gender,link");

    } else {
      print("....Facebook auth Failed.........");
      print(facebookLogin.status);
      print(facebookLogin.message);
    }
  }

  onPressedGoogleLogin() async {
    try {
      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();

      print(googleUser.toString());

      GoogleSignInAuthentication googleSignInAuthentication =
          await googleUser.authentication;
      String accessToken = googleSignInAuthentication.accessToken;

      print("accessToken $accessToken");
      print("displayName ${googleUser.displayName}");
      print("email ${googleUser.email}");
      print("googleUser.id ${googleUser.id}");

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "google", googleUser.displayName, googleUser.email, googleUser.id,
          access_token: accessToken);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
      } else {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
      GoogleSignIn().disconnect();
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }
  }

  onPressedTwitterLogin() async {
    try {
      final twitterLogin = new TwitterLogin(
          apiKey: SocialConfig().twitter_consumer_key,
          apiSecretKey: SocialConfig().twitter_consumer_secret,
          redirectURI: 'mlayecommerceflutterapp://');
      // Trigger the sign-in flow

      final authResult = await twitterLogin.login();

      print("authResult");

      // print(json.encode(authResult));

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "twitter",
          authResult.user.name,
          authResult.user.email,
          authResult.user.id.toString(),
          access_token: authResult.authToken,
          secret_token: authResult.authTokenSecret);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
      } else {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
    } on Exception catch (e) {
      print("error is ....... $e");
      // TODO
    }
  }

  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      var loginResponse = await AuthRepository().getSocialLoginResponse(
          "apple",
          appleCredential.givenName,
          appleCredential.email,
          appleCredential.userIdentifier,
          access_token: appleCredential.identityToken);

      if (loginResponse.result == false) {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
      } else {
        ToastComponent.showDialog(loginResponse.message,
            gravity: Toast.center, duration: Toast.lengthLong);
        AuthHelper().setUserData(loginResponse);
        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return Main();
        }));
      }
    } on Exception catch (e) {
      print(e);
      // TODO
    }

    // Create an `OAuthCredential` from the credential returned by Apple.
    // final oauthCredential = OAuthProvider("apple.com").credential(
    //   idToken: appleCredential.identityToken,
    //   rawNonce: rawNonce,
    // );
    //print(oauthCredential.accessToken);

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    //return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.1),
      // appBar: AppBar(title: Text("akjfhljkdfhhjadh")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: width,
              height: height * 0.4,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/Logo_and_Shape.png",
                    width: width,
                    height: height * 0.45,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: height * 0.095,
                    left: app_language_rtl.$ ? width * 0.85 : width * 0.03,
                    child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 35,
                        )),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context).log_in,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context).log_in_txt,
                style: TextStyle(
                  fontSize: 17,
                  color: MyTheme.grey_color,
                ),
              ),
            ),
            SizedBox(height: 20),
            // Padding(
            //   padding: const EdgeInsetsDirectional.only(start: 20, bottom: 5),
            //   child: Text(
            //     AppLocalizations.of(context).phone_n,
            //     style: TextStyle(
            //         color: Colors.black,
            //         fontWeight: FontWeight.w600,
            //         fontSize: 15),
            //   ),
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(bottom: 8.0),
            //   child: Row(
            //     crossAxisAlignment: CrossAxisAlignment.center,
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Container(
            //         height: 55,
            //         child: CustomInternationalPhoneNumberInput(
            //           onInputChanged: (PhoneNumber number) {
            //             print(number.phoneNumber);
            //             setState(() {
            //               _phone = number.phoneNumber;
            //             });
            //           },
            //           onInputValidated: (bool value) {
            //             print(value);
            //           },
            //           selectorConfig: SelectorConfig(
            //             selectorType: PhoneInputSelectorType.DIALOG,
            //           ),
            //           ignoreBlank: false,
            //           autoValidateMode: AutovalidateMode.disabled,
            //           selectorTextStyle: TextStyle(color: MyTheme.font_grey),
            //           textStyle: TextStyle(color: MyTheme.font_grey),
            //           initialValue: phoneCode,
            //           textFieldController: _phoneNumberController,
            //           formatInput: true,
            //           keyboardType: TextInputType.numberWithOptions(
            //               signed: true, decimal: true),
            //           inputDecoration:
            //               InputDecorations.buildInputDecoration_phone(
            //                   hint_text: "01XXX XXX XXX"),
            //           onSaved: (PhoneNumber number) {
            //             print('On Saved: $number');
            //           },
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            //remove later

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 4.0, right: 10, left: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _login_by == "email"
                              ? AppLocalizations.of(context).login_screen_email
                              : AppLocalizations.of(context).phone_n,
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  if (_login_by == "email")
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, right: 5, left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 55,
                            child: TextField(
                              controller: _emailController,
                              autofocus: false,
                              decoration:
                                  InputDecorations.buildInputDecoration_1(
                                      hint_text: "johndoe@example.com"),
                            ),
                          ),
                          otp_addon_installed.$
                              ? GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _login_by = "phone";
                                    });
                                  },
                                  child: Text(
                                    AppLocalizations.of(context).phone_n,
                                    style: TextStyle(
                                        color: MyTheme.accent_color,
                                        fontStyle: FontStyle.italic,
                                        decoration: TextDecoration.underline),
                                  ),
                                )
                              : Container()
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8.0, right: 5, left: 5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 55,
                            child: CustomInternationalPhoneNumberInput(
                              onInputChanged: (PhoneNumber number) {
                                print(number.phoneNumber);
                                setState(() {
                                  _phone = number.phoneNumber;
                                });
                              },
                              onInputValidated: (bool value) {
                                print(value);
                              },
                              selectorConfig: SelectorConfig(
                                selectorType: PhoneInputSelectorType.DIALOG,
                              ),
                              ignoreBlank: false,
                              autoValidateMode: AutovalidateMode.disabled,
                              selectorTextStyle:
                                  TextStyle(color: MyTheme.font_grey),
                              textStyle: TextStyle(color: MyTheme.font_grey),
                              initialValue: phoneCode,
                              textFieldController: _phoneNumberController,
                              formatInput: true,
                              keyboardType: TextInputType.numberWithOptions(
                                  signed: true, decimal: true),
                              inputDecoration:
                                  InputDecorations.buildInputDecoration_phone(
                                      hint_text: "01XXX XXX XXX"),
                              onSaved: (PhoneNumber number) {
                                print('On Saved: $number');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: width * 0.9,
                  height: 55.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10)),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      onPressedLogin();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          MyTheme.accent_color),
                      shadowColor: MaterialStateProperty.all<Color>(
                          MyTheme.accent_color_shadow),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context).log_in,
                          style: TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(
              height: 30,
            ),
            /* Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context).dont_have_account,
                  style: TextStyle(color: MyTheme.font_grey, fontSize: 12),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Registration();
                    }));
                  },
                  child: Text(
                    AppLocalizations.of(context).login_screen_sign_up,
                    style: TextStyle(
                        color: MyTheme.accent_color,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ), */
          ],
        ),
      ),
    );
  }
}
