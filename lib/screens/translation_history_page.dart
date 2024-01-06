// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nnb_fr_translator2/models/db_model.dart';
import 'package:nnb_fr_translator2/utilities/functions.dart';
import 'package:nnb_fr_translator2/utilities/globals.dart';
import 'package:nnb_fr_translator2/utilities/ui.dart';

class TranslationHistoryPage extends StatefulWidget {
  const TranslationHistoryPage({Key? key}) : super(key: key);

  @override
  _TranslationHistoryPageState createState() => _TranslationHistoryPageState();
}

class _TranslationHistoryPageState extends State<TranslationHistoryPage> {
  final ratingController = TextEditingController();
  final searchController = TextEditingController();

  Future<void> _rateTranslation(DocumentReference documentReference) async {
    var userData, ratingPermission;
    final userDocumentReference = DbModel.instance
        .getData(collectionName: "users", id: Globals.currentEmail!);
    var userDataSnapshot = await userDocumentReference.get().asStream().first;
    userData = userDataSnapshot.data() as Map<String, dynamic>;
    setState(() {
      ratingPermission = userData["ratingPermission"];
    });
    if (ratingPermission) {
      final rating = double.tryParse(ratingController.text);
      await DbModel.instance.save(
        collectionName: "ratings",
        data: <String, dynamic>{
          "email": Globals.currentEmail,
          "rating": rating,
        },
      );
      showScaffoldMessage(
        context,
        message: "Thanks for rating our model!",
        color: ColorConstants.tealColor,
      );
      documentReference.update(<String, dynamic>{"isRated": true});
      setState(() {});
    } else {
      showScaffoldMessage(context,
          message:
              "You cannot rate this translation. The admin will allow you to rate the translation.", color: ColorConstants.orangeColor);
    }
  }

  void _deleteTranslation(String documentId) async {
    DbModel.instance
        .delete(collectionName: "translations", documentId: documentId);
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double screenHeight = screenSize.height;
    final double screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation History'),
        centerTitle: true,
        foregroundColor: ColorConstants.greyColor,
        backgroundColor: ColorConstants.whiteColor2,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: ColorConstants.tealColor,
                  ),
                ),
                iconColor: ColorConstants.tealColor,
                labelText: 'Search',
                labelStyle: const TextStyle(color: ColorConstants.tealColor),
                hintText: 'Enter text to search...',
                hintStyle: const TextStyle(color: ColorConstants.greyColor),
                prefixIcon: const Icon(
                  Icons.search,
                  color: ColorConstants.tealColor,
                ),
                suffixIcon: IconButton(
                  color: ColorConstants.tealColor,
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              color: ColorConstants.tealColor,
              onRefresh: () async {
                setState(() {});
              },
              child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                future: DbModel.instance.getAllDataWhere(
                  collectionName: 'translations',
                  field: 'email',
                  value: Globals.currentEmail!,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: ColorConstants.tealColor,
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  var documents = snapshot.data?.docs ?? [];
                  var filteredDocuments = documents.where((document) {
                    var sourceText = document['sourceText']?.toString() ?? '';
                    var translatedText =
                        document['translatedText']?.toString() ?? '';
                    var searchQuery = searchController.text.toLowerCase();
                    return sourceText.toLowerCase().contains(searchQuery) ||
                        translatedText.toLowerCase().contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      var documentSnapshot = filteredDocuments[index];
                      var documentReference = DbModel.instance.getData(
                        collectionName: "translations",
                        id: documentSnapshot.id,
                      );
                      var document = documentSnapshot.data();
                      var sourceText = document['sourceText'];
                      var translatedText = document['translatedText'];

                      return ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: Text(
                                sourceText,
                                style: const TextStyle(
                                  color: ColorConstants.greyColor,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Icon(
                                Icons.arrow_right_alt_rounded,
                                color: ColorConstants.redColor,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                translatedText,
                                style: const TextStyle(
                                  color: ColorConstants.tealColor,
                                ),
                              ),
                            ),
                            Expanded(
                              child: IconButton(
                                onPressed: document["isRated"]
                                    ? null
                                    : () {
                                        showDialog(
                                          barrierColor:
                                              ColorConstants.greyColor,
                                          context: context,
                                          builder: (context) {
                                            return Center(
                                              child: Card(
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          screenHeight * 0.1),
                                                  width: screenWidth * 0.7,
                                                  height: screenHeight * 0.3,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      TextField(
                                                        maxLength: 1,
                                                        controller:
                                                            ratingController,
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              InputBorder.none,
                                                          labelText: "Rating",
                                                          counterText:
                                                              "Score is out of 5",
                                                          counterStyle:
                                                              TextStyle(
                                                            color:
                                                                ColorConstants
                                                                    .greyColor,
                                                          ),
                                                          hintText:
                                                              "Rate the translation",
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              MaterialStateProperty.all(
                                                                  ColorConstants
                                                                      .tealColor),
                                                          foregroundColor:
                                                              MaterialStateProperty.all(
                                                                  ColorConstants
                                                                      .whiteColor2),
                                                        ),
                                                        onPressed: () async {
                                                          Navigator.pop(
                                                              context);
                                                          await _rateTranslation(
                                                              documentReference);
                                                        },
                                                        child:
                                                            const Text("Rate"),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                icon: const Icon(Icons.rate_review_rounded),
                                color: ColorConstants.redColor,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _deleteTranslation(documentReference.id);
                                setState(() {});
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: ColorConstants.redColor,
                              ),
                            ),
                          ],
                        ),
                        subtitle: const Divider(),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
