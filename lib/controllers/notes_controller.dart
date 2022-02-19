import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'google_auth.dart';

class NotesController extends GetxController {

  CollectionReference reference = fireStoreInstance
      .collection("users")
      .doc(auth.currentUser?.uid)
      .collection("notes");

  @override
  void onInit() {
    reference.get();
    super.onInit();
  }
}
