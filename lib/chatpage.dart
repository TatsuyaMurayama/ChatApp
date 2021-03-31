import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'addpostpage.dart';
import 'main.dart';

class ChatPage extends StatelessWidget {
  ChatPage(this.user);
  final User user;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('チャット'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return MyAuthPage();
                }),
              );
            },
          ),
          IconButton(
            onPressed: () async {
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) {
                  return MyAuthPage();
                }),
              );
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddPostPage(user);
            }),
          );
        },
      ),
      body: Column(
        children: [
          Center(
            child: Text('ログイン情報:${user.email}'),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('date')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final List<DocumentSnapshot> documents = snapshot.data!.docs;
                  return ListView(
                    children: documents.map((doc) {
                      return Card(
                        child: ListTile(
                          title: Text(doc['text']),
                          subtitle: Text(doc['email'] + '\n' + doc['date']),
                          trailing: doc['email'] == user.email
                              ? IconButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('posts')
                                        .doc(doc.id)
                                        .delete();
                                  },
                                  icon: Icon(Icons.delete),
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                } else {
                  // データが読込中の場合
                  return Center(
                    child: Text('読込中...'),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
