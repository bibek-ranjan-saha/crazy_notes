import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crazy_notes/pages/add_note.dart';
import 'package:crazy_notes/views/paper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewNote extends StatefulWidget {
  const ViewNote(
      {Key? key,
      required this.title,
      required this.desc,
      required this.time,
      required this.ref})
      : super(key: key);

  final String title;
  final String desc;
  final String time;
  final DocumentReference ref;

  @override
  _ViewNoteState createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
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
                    Row(children: [
                      ElevatedButton(
                        onPressed: () {
                          Share.share("${widget.title} \n${widget.desc}");
                        },
                        child: const Icon(Icons.share_sharp),
                        style: ElevatedButton.styleFrom(
                            enableFeedback: true,
                            primary: Colors.lightGreenAccent),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context)
                                .pushReplacement(
                              MaterialPageRoute(
                                builder: (context) => AddNote(
                                  title: widget.title,
                                  desc: widget.desc,
                                  ref: widget.ref,
                                ),
                              ),
                            )
                                .then((value) {
                              if (mounted) {
                                setState(() {});
                              }
                            });
                          },
                          child: const Icon(Icons.edit_outlined),
                          style: ElevatedButton.styleFrom(
                              enableFeedback: true,
                              primary: Colors.lightBlueAccent),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: delete,
                        child: const Icon(Icons.delete_outlined),
                        style: ElevatedButton.styleFrom(
                            enableFeedback: true, primary: Colors.redAccent),
                      ),
                    ])
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Hero(
                        tag: widget.time,
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                            inherit: false,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Text(
                        widget.time,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Expanded(
                        flex: 1,
                        child: CustomPaint(
                          painter: Paper(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 44.0, top: 24),
                            child: SelectableLinkify(
                              scrollPhysics: const BouncingScrollPhysics(),
                              onOpen: (link) async {
                                // if (await canLaunch(link.url)) {
                                if (link.url.contains("mailto:")) {
                                  String mail = link.url +
                                      "?subject=${widget.title}&body=${widget.desc}\n\n\n\n\tShared via : Notes App (created by bibek ranjan saha)";
                                  await launch(mail);
                                } else {
                                  await launch(link.url);
                                }
                                // } else {
                                //   throw 'Could not launch $link';
                                // }
                              },
                              options: const LinkifyOptions(humanize: false),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                color: Colors.black87,
                              ),
                              text: widget.desc,
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
        ),
      ),
    );
  }

  Future<void> delete() async {
    await widget.ref.delete().then((value) {
      Navigator.of(context).pop();
    });
  }
}
