import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:intl/intl.dart';
import 'package:pocusme/column_builder.dart';
import 'package:pocusme/data/userdata.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final CollectionReference _Notes =
      FirebaseFirestore.instance.collection('notes');

  Query _Noteslist = FirebaseFirestore.instance
      .collection('notes')
      .where('user', isEqualTo: UserData().getUserId());

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _TitleController = TextEditingController();
  final HtmlEditorController _ContentController = HtmlEditorController();

  Future<void> _create() async {
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          maxLength: 45,
                          validator: (value) {
                            if (_TitleController.text.trim().isEmpty) {
                              return 'Please enter a Note Title';
                            }
                            return null;
                          },
                          controller: _TitleController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.notes), //icon of text field
                            iconColor: Color.fromRGBO(40, 182, 126, 1),
                            labelText: 'Note Title',
                            labelStyle:
                                TextStyle(color: Color.fromRGBO(28, 76, 78, 1)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(40, 182, 126, 1)),
                            ),
                          ),
                        ),
                        HtmlEditor(
                          controller: _ContentController, //required
                          htmlEditorOptions: HtmlEditorOptions(
                            hint: "Your note here...",
                          ),
                          otherOptions: OtherOptions(
                            height: 400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(28, 76, 78, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: const Text('Add'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              var now = new DateTime.now();
                              var formatter = new DateFormat('yyyy-MM-dd');
                              String formattedDate = formatter.format(now);
                              final String Notes = _TitleController.text;
                              final String Content =
                                  await _ContentController.getText();
                              await _Notes.add({
                                'user': UserData().getUserId(),
                                'title': Notes,
                                'content': Content,
                                'date': formattedDate,
                              });
                              _TitleController.clear();
                              _ContentController.clear();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ]),
                )),
          );
        });
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    var initialText = '';
    if (documentSnapshot != null) {
      _TitleController.text = documentSnapshot['title'];
      initialText = documentSnapshot['content'].toString();
      _ContentController.setText(documentSnapshot['content'].toString());
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(
                    top: 20,
                    left: 20,
                    right: 20,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          maxLength: 45,
                          validator: (value) {
                            if (_TitleController.text.trim().isEmpty) {
                              return 'Please enter a Note Title';
                            }
                            return null;
                          },
                          controller: _TitleController,
                          decoration: const InputDecoration(
                            icon: Icon(Icons.notes), //icon of text field
                            iconColor: Color.fromRGBO(40, 182, 126, 1),
                            labelText: 'Notes',
                            labelStyle:
                                TextStyle(color: Color.fromRGBO(28, 76, 78, 1)),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(40, 182, 126, 1)),
                            ),
                          ),
                        ),
                        HtmlEditor(
                          controller: _ContentController, //required
                          htmlEditorOptions: HtmlEditorOptions(
                            hint: "Your note here...",
                            initialText: initialText,
                          ),
                          otherOptions: OtherOptions(
                            height: 400,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(28, 76, 78, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32.0),
                            ),
                          ),
                          child: const Text('Update'),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final String Notes = _TitleController.text;
                              final String Content =
                                  await _ContentController.getText();
                              await _Notes.doc(documentSnapshot!.id)
                                  .update({'title': Notes, 'content': Content});
                              _TitleController.clear();
                              _ContentController.clear();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ]),
                )),
          );
        });
  }

  Future<void> _delete(String NotesId) async {
    await _Notes.doc(NotesId).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notes Deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color.fromRGBO(40, 182, 126, 1),
          onPressed: () {
            _TitleController.clear();
            _ContentController.clear();
            _create();
          },
          child: const Icon(Icons.add),
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20, width: MediaQuery.of(context).size.width),
                Container(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                      "My Notes",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 30,
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: StreamBuilder(
                      stream: _Noteslist.snapshots(),
                      builder: (context,
                          AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                        if (streamSnapshot.hasData) {
                          return ColumnBuilder(
                              itemCount: streamSnapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                final DocumentSnapshot documentSnapshot =
                                    streamSnapshot.data!.docs[index];
                                return Card(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                      side: BorderSide(
                                          color: Colors.grey[300]!, width: 1)),
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                      title: Text(documentSnapshot.get('title'),
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(28, 76, 78, 1),
                                              fontWeight: FontWeight.w600)),
                                      subtitle: Text(
                                          documentSnapshot.get('date'),
                                          style: TextStyle(
                                              color:
                                                  Color.fromRGBO(28, 76, 78, 1),
                                              fontWeight: FontWeight.w400)),
                                      trailing: SizedBox(
                                        width: 100,
                                        child: Row(
                                          children: [
                                            IconButton(
                                                onPressed: () {
                                                  _update(documentSnapshot);
                                                },
                                                icon: const Icon(Icons.edit)),
                                            IconButton(
                                                onPressed: () {
                                                  _delete(documentSnapshot.id);
                                                },
                                                icon: const Icon(Icons.delete)),
                                          ],
                                        ),
                                      )),
                                );
                              });
                        }
                        return Center(child: CircularProgressIndicator());
                      }),
                )
              ]),
        ));
  }
}
