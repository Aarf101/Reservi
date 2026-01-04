import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatefulWidget {
  final String centerId;
  final String centerName;
  const ChatScreen({Key? key, required this.centerId, required this.centerName}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _scrollController = ScrollController();

  Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream() {
    return FirebaseFirestore.instance
        .collection('centers')
        .doc(widget.centerId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Vous devez être connecté pour envoyer un message')));
      return;
    }
    final payload = {
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'senderId': user.uid,
      'displayName': user.displayName ?? user.email ?? 'Utilisateur',
    };
    try {
      await FirebaseFirestore.instance.collection('centers').doc(widget.centerId).collection('messages').add(payload);
      _controller.clear();
      _scrollController.animateTo(0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Impossible d\'envoyer le message')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat — ${widget.centerName}'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[900],
        elevation: 1,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _messagesStream(),
              builder: (context, snap) {
                if (!snap.hasData) return Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return Center(child: Text('Aucun message pour le moment'));
                return ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final d = docs[index].data();
                    final isMe = d['senderId'] == FirebaseAuth.instance.currentUser?.uid;
                    return Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[600] : Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!isMe)
                                Text(d['displayName'] ?? 'Centre', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800], fontSize: 12)),
                              SizedBox(height: 4),
                              Text(d['text'] ?? '', style: TextStyle(color: isMe ? Colors.white : Colors.grey[900])),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      minLines: 1,
                      maxLines: 4,
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Icon(Icons.send, size: 18),
                    style: ElevatedButton.styleFrom(padding: EdgeInsets.all(12), shape: CircleBorder()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
