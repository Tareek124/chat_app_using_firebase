import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final firebase = FirebaseFirestore.instance;
final user = FirebaseAuth.instance;

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  OutlineInputBorder textBorders(Color color, double radius) {
    return OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
        borderSide: BorderSide(color: color));
  }

  late User signedInUser;

  TextEditingController messageController = TextEditingController();

  senData(String? message) async {
    await firebase.collection('messages').add({
      "sender": user.currentUser!.email,
      "text": message,
      "time": FieldValue.serverTimestamp(),
    });
  }

  getMessages() async {
    await for (var snapshot in firebase.collection("messages").snapshots()) {
      for (var message in snapshot.docs) {}
    }
    ;
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF9F6EE),
      appBar: AppBar(
        actions: [
          TextButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "login screen");
              },
              child:
                  const Text("Sign Out", style: TextStyle(color: Colors.white)))
        ],
        title: const Text("Chat App"),
        backgroundColor: Colors.purple[900],
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        // crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MessageStreamBuilder(),
          Container(
            child: SafeArea(
                child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: "Message",
                      prefixIcon: Icon(
                        Icons.chat,
                        color: Colors.purple[900],
                      ),
                      hoverColor: Colors.red,
                      border: textBorders(Colors.black, 40),
                      hintText: "Message",
                    ),
                  ),
                ),
                SizedBox(
                  width: 30,
                  child: Expanded(
                    child: IconButton(
                        onPressed: () async {
                          senData(messageController.text);
                          setState(() {
                            messageController.text = "";
                          });
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.purple[900],
                        )),
                  ),
                )
              ],
            )),
            // decoration: const BoxDecoration(color: Colors.white),
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 5,
            ),
          )
        ],
      ),
    );
  }
}

class MessageLine extends StatelessWidget {
  MessageLine({Key? key, this.text, this.sender, required this.isMe})
      : super(key: key);

  final String? sender, text;
  bool? isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            "$sender",
            style:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.5)),
          ),
          Material(
            elevation: 5,
            borderRadius: isMe!
                ? const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : const BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            color: isMe! ? Colors.purple[900] : Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$text',
                style: TextStyle(
                    fontSize: 15,
                    color:
                        isMe! ? Colors.white : Colors.black.withOpacity(0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageStreamBuilder extends StatelessWidget {
  const MessageStreamBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firebase.collection("messages").orderBy("time").snapshots(),
        builder: (context, snapshot) {
          List<MessageLine> messageWidgets = [];
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final messages = snapshot.data!.docs.reversed;

          for (var message in messages) {
            final messageText = message.get("text");
            final messageSender = message.get("sender");
            final currentUser = user.currentUser!.email;

            final messageWidget = MessageLine(
                text: messageText,
                sender: messageSender,
                isMe: currentUser == messageSender ? true : false);
            messageWidgets.add(messageWidget);
          }

          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              children: messageWidgets,
            ),
          );
        });
  }
}
