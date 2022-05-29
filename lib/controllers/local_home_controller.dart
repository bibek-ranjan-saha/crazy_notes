import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthController {
  final _localAuth = LocalAuthentication();
  // RxBool hasFingerPrintLock = false.obs;
  // RxBool hasFaceLock = false.obs;
  // RxBool isUserAuthenticated = false.obs;

  _getAllBiometrics() async {
    return  await _localAuth.canCheckBiometrics;
    // if (hasLocalAuth) {
    //   List<BiometricType> availableBiometrics =
    //       await _localAuth.getAvailableBiometrics();
    //   hasFaceLock.value = availableBiometrics.contains(BiometricType.face);
    //   hasFingerPrintLock.value =
    //       availableBiometrics.contains(BiometricType.fingerprint);
    // } else {
    //   Get.snackbar(
    //       "sorry", "biometrics are either not available or not enabled",
    //       snackPosition: SnackPosition.BOTTOM);
    // }
  }

  Future<bool> authenticateUser() async {
    final isAvailable = await _getAllBiometrics();
    if(!isAvailable) return false;

    try{
      return await _localAuth.authenticate(
          localizedReason: "scan fingerprint to go to crazy-notes app",
          stickyAuth: true,
          useErrorDialogs: true,);
    }
    on PlatformException catch (e) {
      if (Platform.isIOS) {
        exit(0);
      } else {
        SystemNavigator.pop();
      }
      return false;
    }
  }
}
