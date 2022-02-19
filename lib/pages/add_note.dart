import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crazy_notes/controllers/google_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class AddNote extends StatefulWidget {
  const AddNote({Key? key, required this.title, required this.desc, this.ref})
      : super(key: key);

  final DocumentReference? ref;
  final String title;
  final String desc;

  @override
  _AddNoteState createState() => _AddNoteState();
}

class _AddNoteState extends State<AddNote> {
  String title = "";
  String desc = "";

  @override
  void initState() {
    title = widget.title;
    desc = widget.desc;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    if (kDebugMode) {
      print(desc.length);
    }

    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(Icons.arrow_back_ios_rounded),
                    style: ElevatedButton.styleFrom(
                        enableFeedback: true, primary: Colors.blueGrey),
                  ),
                  ElevatedButton(
                    onPressed: add,
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 4.0, vertical: 12),
                      child: Text("Save"),
                    ),
                    style: ElevatedButton.styleFrom(
                        enableFeedback: true, primary: Colors.blueGrey),
                  )
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Form(
                  child: Column(
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration.collapsed(hintText: "title"),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                    onChanged: (_val) {
                      title = _val;
                    },
                    initialValue: title,
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        initialValue: desc,
                        decoration: const InputDecoration.collapsed(
                            hintText: "add note description"),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                        onChanged: (_val) {
                          setState(() {
                            desc = _val;
                          });
                        },
                      ),
                    ),
                  )
                ],
              )),
            ],
          ),
        ),
      ),
    ));
  }

  void add() {
    if (title.isNotEmpty && desc.isNotEmpty) {
      var data = {
        "title": title,
        "description": desc,
        "created": DateTime.now()
      };
      if (widget.ref != null) {
        widget.ref!.update(data).whenComplete(() {
          Navigator.of(context).pop();
        });
      } else {
        CollectionReference reference = fireStoreInstance
            .collection("users")
            .doc(auth.currentUser?.uid)
            .collection("notes");

        reference.add(data).whenComplete(() {
          Navigator.of(context).pop();
        });
      }
    } else {
      if (title.isEmpty && desc.isEmpty) {
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                  title: const Text(
                      "It is mandatory to write then only you can save"),
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("ok"),
                    )
                  ]);
            });
      } else if (desc.isEmpty) {
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                  title:
                      const Text("Write some notes to save along with title"),
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("ok"),
                    )
                  ]);
            });
      } else {
        showDialog(
            context: context,
            builder: (builder) {
              return AlertDialog(
                  title: const Text("please write a title to continue"),
                  actions: [
                    OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text("ok"),
                    )
                  ]);
            });
      }
    }
  }
}
