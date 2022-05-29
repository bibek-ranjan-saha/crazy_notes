import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crazy_notes/controllers/google_auth.dart';
import 'package:crazy_notes/menus/menu_item.dart';
import 'package:crazy_notes/menus/menu_items.dart';
import 'package:crazy_notes/pages/add_note.dart';
import 'package:crazy_notes/pages/profile.dart';
import 'package:crazy_notes/pages/setting.dart';
import 'package:crazy_notes/pages/view_note.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../helpers/utils.dart';
import '../views/triangle.dart';
import 'dart:developer';


class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late SharedPreferences prefs;
  bool enableAuth = false;
  late TextEditingController _searchController;
  CollectionReference reference = fireStoreInstance
      .collection("users")
      .doc(auth.currentUser?.uid)
      .collection("notes");

  String email = "";
  String name = "";
  String photoURL = "";

  getProfileData() async {
    var profile = await users.doc(auth.currentUser?.uid).get();
    setState(() {
      email = profile["email"];
      name = profile["name"];
      photoURL = profile["photoURL"];
    });
  }

  @override
  void initState() {
    super.initState();
    getProfileData();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        //centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => const Profile()))
                .then((value) {
              setState(() {});
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Hero(
              tag: "image",
              child: ClipOval(
                child: CachedNetworkImage(
                  placeholder: (context, data) => const Icon(Icons.people),
                  imageUrl:
                      //"${auth.currentUser!.photoURL}",
                      photoURL,
                  errorWidget: (context, url, error) => const Icon(
                    Icons.image_not_supported_outlined,
                  ),
                  height: 150,
                  width: 150,
                ),
              ),
            ),
          ),
        ),
        actions: [
          PopupMenuButton<MenuItem>(
              onSelected: (item) {
                switch (item.text) {
                  case "Settings":
                    Navigator.of(context)
                        .push(CupertinoPageRoute(
                            builder: (context) => const AppSettings()))
                        .then((value) {
                      setState(() {});
                    });
                    break;
                  case "Share":
                    Share.share(
                        "I loved this app called *notes app* made by my good friend *Bibek Ranjan Saha* try it and share your feedback\n\nLink to download : https://drive.google.com/file/d/1BbN0LTgGBzVB4TQSFqyfsRrqIvByFk6c/view?usp=sharing");
                    break;
                  case "Log out":
                    signOut(context);
                    break;
                  default:
                    if (kDebugMode) {
                      print("something wrong got turned on");
                    }
                    break;
                }
              },
              itemBuilder: (context) => [
                    ...MenuItems.item.map(buildItem).toList(),
                  ])
        ],
        title: AnimSearchBar(
          textController: _searchController,
          width: size.width - 100,
          rtl: true,
          color: Colors.blueGrey.shade100,
          helpText: "Search notes..",
          style: const TextStyle(color: Colors.black,fontSize: 20),
          onSuffixTap: () {
            setState(() {
              _searchController.clear();
            });
          },
          autoFocus: true,
          suffixIcon: const Icon(Icons.delete),
        ),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: reference.get(),
        builder: (context, snapshot) {
          log(snapshot.data.toString());
          if (snapshot.hasData) {
            log("got it "+snapshot.data!.docs.toString());
            if (snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(22.0),
                  child: Text(
                    "You have no notes to show create new from the + button below",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () {
                return reference.get();
              },
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    String title = snapshot.data!.docs[index]["title"];
                    String message = snapshot.data!.docs[index]["description"];
                    DateTime date =
                        snapshot.data!.docs[index]["created"].toDate();
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(
                                builder: (context) => ViewNote(
                                      title: title,
                                      desc: message,
                                      time: DateFormat.yMMMd()
                                          .add_jm()
                                          .format(date),
                                      ref: snapshot.data!.docs[index].reference,
                                    )))
                            .then((value) {
                          setState(() {});
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 2),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                elevation: 6,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16,
                                      //top: title.length <= 15 ? 16 : 32,
                                      top: 32,
                                      right: 16,
                                      bottom: 16),
                                  child: Hero(
                                    tag: snapshot.data!.docs[index]["created"],
                                    child: Material(
                                      color: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      child: Text(
                                        title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(
                                    height: 8.0,
                                    width: 5.0,
                                    child: CustomPaint(
                                      painter: TrianglePainter(),
                                    ),
                                  ),
                                  Container(
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.only(
                                            topRight: Radius.circular(6.0),
                                            bottomLeft: Radius.circular(6.0),
                                            bottomRight: Radius.circular(6.0))),
                                    height: 30.0,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: Text(
                                          DateFormat.yMMMd()
                                              .add_jm()
                                              .format(date),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            );
          } else if (snapshot.hasError) {
            return const Center(
                child: Text(
              "something went wrong 😥",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        heroTag: "add_note",
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (context) => const AddNote(desc: '', title: '')))
              .then((value) {
            setState(() {});
          });
        },
        child: const Icon(Icons.add_outlined),
      ),
    );
  }
}
