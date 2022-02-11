import 'package:cached_network_image/cached_network_image.dart';
import 'package:crazy_notes/controllers/google_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Hero(
              tag: "image",
              child: ClipOval(
                child: CachedNetworkImage(
                  height: 150,
                  width: 150,
                  fit: BoxFit.cover,
                  imageUrl: "${auth.currentUser!.photoURL}",
                  progressIndicatorBuilder: (context, url, downloadProgress) =>
                      CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Text(
              "${auth.currentUser!.displayName}",
              style: const TextStyle(
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.bold,
                  fontSize: 22),
            ),
            ElevatedButton.icon(
              onPressed: () {
                signOut(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text(
                "log out",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(250, 56),
                  primary: Colors.redAccent.shade100),
            )
          ],
        ),
      ),
    );
  }
}
