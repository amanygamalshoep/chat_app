import 'package:chat_app/constants.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  ChatPage({Key? key}) : super(key: key);
  static String id = 'chatPage';
  CollectionReference messages =
      FirebaseFirestore.instance.collection(KMessagesCollection);
  TextEditingController controller = TextEditingController();
  final ScrollController _Controller = ScrollController();

  @override
  Widget build(BuildContext context) {
    var email = ModalRoute.of(context)!.settings.arguments;
    return StreamBuilder<QuerySnapshot>(
        stream: messages.orderBy(KCreatedAt, descending: true).snapshots(),
        builder: (context, Snapshot) {
          if (Snapshot.hasData) {
            List<Message> messageList = [];
            for (int i = 0; i < Snapshot.data!.docs.length; i++) {
              messageList.add(Message.fromJson(Snapshot.data!.docs[i]));
            }
            return Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: kPrimaryColor,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/scholar.png',
                        height: 50,
                      ),
                      Text('Chat')
                    ],
                  ),
                  //centerTitle: true,
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          reverse: true,
                          controller: _Controller,
                          itemCount: messageList.length,
                          itemBuilder: (Context, index) {
                            return messageList[index].id == email
                                ? ChatBubble(
                                    message: messageList[index],
                                  )
                                : ChatBubbleFromFriend(
                                    message: messageList[index]);
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: controller,
                        onSubmitted: (data) {
                          messages.add({
                            KMessage: data,
                            KCreatedAt: DateTime.now(),
                            'id': email
                          });
                          controller.clear();
                          if (_Controller.hasClients) {
                            _Controller.animateTo(0,
                                duration: Duration(seconds: 1),
                                curve: Curves.easeIn);
                          }
                        },
                        decoration: InputDecoration(
                            hintText: 'Send Message',
                            suffixIcon: const Icon(
                              Icons.send,
                              color: kPrimaryColor,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: kPrimaryColor))),
                      ),
                    )
                  ],
                ));
          } else {
            return Text('Loading...');
          }
        });
  }
}
