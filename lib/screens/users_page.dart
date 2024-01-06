// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nnb_fr_translator2/models/db_model.dart';
import 'package:nnb_fr_translator2/utilities/texts.dart';
import 'package:nnb_fr_translator2/utilities/ui.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final ratingController = TextEditingController();
  final searchController = TextEditingController();

  void _deleteUser(String documentId) async {
    DbModel.instance.delete(collectionName: "users", documentId: documentId);
  }

  @override
  Widget build(BuildContext context) {
    // final Size screenSize = MediaQuery.of(context).size;
    // final double screenHeight = screenSize.height;
    // final double screenWidth = screenSize.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
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
                future: DbModel.instance.getAllDataNotWhere(
                  collectionName: 'users',
                  field: "email",
                  value: TextConstants.adminEmail,
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
                    var displayName = document['name']?.toString() ?? '';
                    var email = document['email']?.toString() ?? '';
                    var phoneNumber = document['phoneNumber']?.toString() ?? '';
                    var searchQuery = searchController.text.toLowerCase();
                    return displayName.toLowerCase().contains(searchQuery) ||
                        phoneNumber.toLowerCase().contains(searchQuery) ||
                        email.toLowerCase().contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocuments.length,
                    itemBuilder: (context, index) {
                      var documentSnapshot = filteredDocuments[index];
                      var documentReference = DbModel.instance.getData(
                        collectionName: "users",
                        id: documentSnapshot.id,
                      );
                      var document = documentSnapshot.data();
                      var phoneNumber = document['phoneNumber'];
                      var displayName = document['name'];
                      var email = document['email'];
                      var ratingPermission = document["ratingPermission"];

                      return ListTile(
                        title: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 9,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.draw),
                                      Text(
                                        displayName,
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.email),
                                      Text(
                                        email,
                                        softWrap: true,
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone),
                                      Text(
                                        phoneNumber,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: IconButton(
                                onPressed: () {
                                  documentReference.update(<String, dynamic>{
                                    "ratingPermission":
                                        ratingPermission ? false : true,
                                  });
                                  setState(() {});
                                },
                                icon: Icon(
                                  ratingPermission ? Icons.check_box : Icons.check_box_outline_blank,
                                  color: ratingPermission
                                      ? ColorConstants.tealColor
                                      : ColorConstants.redColor,
                                ),
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
