import 'package:chatapp/chatpage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chatpage.dart';

Future<void> main() async {
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyAuthPage(),
    );
  }
}

class MyAuthPage extends StatefulWidget {
  @override
  _MyAuthPageState createState() => _MyAuthPageState();
}

class _MyAuthPageState extends State<MyAuthPage> {
  String newUserEmail = "";
  String newUserPassword = "";
  String loginUserEmail = "";
  String loginUserPassword = "";
  String infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: "Emailアドレス"),
                onChanged: (String value) {
                  setState(() {
                    loginUserEmail = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    loginUserPassword = value;
                  });
                },
              ),
              SizedBox(height: 8),
              Container(
                width: 150,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.createUserWithEmailAndPassword(
                        email: newUserEmail,
                        password: newUserPassword,
                      );

                      final User user = result.user!;
                      setState(() {
                        infoText = "登録完了: ${user.email}";
                      });
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) {
                            return ChatPage(result.user!);
                          },
                        ),
                      );
                    } catch (e) {
                      setState(() {
                        infoText = "登録失敗: ${e.toString()}";
                      });
                    }
                  },
                  child: Text("ユーザー登録"),
                ),
              ),
              SizedBox(height: 8),
              Container(
                width: 150,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final result = await auth.signInWithEmailAndPassword(
                          email: loginUserEmail, password: loginUserPassword);
                      final User user = result.user!;
                      setState(() {
                        infoText = "ログイン成功:${user.email}";
                      });
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) {
                          return ChatPage(result.user!);
                        }),
                      );
                    } catch (e) {
                      setState(() {
                        infoText = "ログイン失敗:${e.toString()}";
                      });
                    }
                  },
                  child: Text("ログイン"),
                ),
              ),
              SizedBox(height: 8),
              Text(infoText),
//              MyFirestorePage(),
            ],
          ),
        ),
      ),
    );
  }
}

class MyFirestorePage extends StatefulWidget {
  @override
  _MyFirestorePageState createState() => _MyFirestorePageState();
}

class _MyFirestorePageState extends State<MyFirestorePage> {
  List<DocumentSnapshot> documentList = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc('id_abc')
                .set({'name': '村山', 'age': 30});
          },
          child: Text('コレクション＋ドキュメント作成'),
        ),
        ElevatedButton(
          child: Text('サブコレクション＋ドキュメント作成'),
          onPressed: () async {
            // サブコレクション内にドキュメント作成
            await FirebaseFirestore.instance
                .collection('users') // コレクションID
                .doc('id_abc') // ドキュメントID << usersコレクション内のドキュメント
                .collection('orders') // サブコレクションID
                .doc('id_123') // ドキュメントID << サブコレクション内のドキュメント
                .set({'price': 500, 'date': '3/30'}); //
          },
        ),
        ElevatedButton(
          onPressed: () async {
            final snapshot =
                await FirebaseFirestore.instance.collection('users').get();
            setState(() {
              documentList = snapshot.docs;
            });
          },
          child: Text('ドキュメント一覧取得'),
        ),
        Column(
          children: documentList.map((document) {
            return ListTile(
              title: Text('${document['name']}'),
              subtitle: Text('${document['age']}歳'),
            );
          }).toList(),
        ),
      ],
    );
  }
}
