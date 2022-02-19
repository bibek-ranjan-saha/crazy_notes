import 'package:get/get.dart';

import 'google_auth.dart';

class ProfileController extends GetxController {
  late RxString email;
  late RxString name;
  late RxString photoURL;
  late RxString provider;

  @override
  void onInit() {
    getProfileData();
    super.onInit();
  }

  getProfileData() async {
    var profile = await users.doc(auth.currentUser?.uid).get();
    email = profile["email"];
    name = profile["name"];
    photoURL = profile["photoURL"];
    provider = profile["provider"];
  }
}
