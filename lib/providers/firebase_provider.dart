import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:get/get.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:mlay_dmp_teams/helpers/shared_value_helper.dart';

class FirebaseProvider {
  fba.FirebaseAuth _auth = fba.FirebaseAuth.instance;

  Future<FirebaseProvider> init() async {
    return this;
  }

  Future<bool> verifyPhone(String smsCode) async {
    print(verificationId.$);
    try {
      final fba.AuthCredential credential = fba.PhoneAuthProvider.credential(
          verificationId: verificationId.$, smsCode: smsCode);
      await fba.FirebaseAuth.instance.signInWithCredential(credential);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> sendCodeToPhone(String PhoneNumber) async {
    print("herererer");
    final fba.PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {};
    final fba.PhoneCodeSent smsCodeSent =
        (String verId, [int forceCodeResent]) {
      print(forceCodeResent);
      verificationId.$ = verId;
    };
    print(smsCodeSent);
    final fba.PhoneVerificationCompleted _verifiedSuccess =
        (fba.AuthCredential auth) async {};
    final fba.PhoneVerificationFailed _verifyFailed =
        (fba.FirebaseAuthException e) {
      throw Exception(e.message);
    };
    await _auth.verifyPhoneNumber(
      phoneNumber: PhoneNumber,
      timeout: const Duration(seconds: 30),
      verificationCompleted: _verifiedSuccess,
      verificationFailed: _verifyFailed,
      codeSent: smsCodeSent,
      codeAutoRetrievalTimeout: autoRetrieve,
    );
  }
}
