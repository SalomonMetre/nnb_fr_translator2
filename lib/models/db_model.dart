import 'package:cloud_firestore/cloud_firestore.dart';

class DbModel {
  final firestoreInstance = FirebaseFirestore.instance;
  static final instance = DbModel._();
  DbModel._();
  factory DbModel() => instance;

  CollectionReference<Map<String, dynamic>> getCollection(
      {required String collectionName}) {
    return firestoreInstance.collection(collectionName);
  }

  Future<void> save(
      {required String collectionName,
      required Map<String, dynamic> data}) async {
    final collectionReference = getCollection(collectionName: collectionName);
    if (collectionName == "users") {
      await collectionReference.doc(data["email"]).set(data);
    } else {
      await collectionReference.add(data);
    }
  }

  Future<void> delete(
      {required String collectionName, required String documentId}) async {
    final collectionReference = getCollection(collectionName: collectionName);
    collectionReference.doc(documentId).delete();
  }

  DocumentReference<Map<String, dynamic>> getData(
      {required String collectionName, required String id}) {
    final collectionReference = getCollection(collectionName: collectionName);
    return collectionReference.doc(id);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllDataWhere(
      {required String collectionName,
      required String field,
      required String value}) async {
    return getCollection(collectionName: collectionName)
        .where(field, isEqualTo: value)
        .get();
  }

Future<double> getAverage(String collectionName, String fieldName) async {
  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  QuerySnapshot snapshot = await collection.get();
  if (snapshot.docs.isNotEmpty) {
    double sum = snapshot.docs.fold(0, (total, doc) => total + ((doc.data() as Map)[fieldName] as num? ?? 0));
    double average = sum / snapshot.docs.length;
    return average;
  } else {
    throw Exception('No documents found in the collection');
  }
}

  Future<QuerySnapshot<Map<String, dynamic>>> getAllDataNotWhere(
      {required String collectionName,
      required String field,
      required String value}) async {
    return getCollection(collectionName: collectionName)
        .where(field, isNotEqualTo: value)
        .get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getAllData(
      {required String collectionName}) async {
    return getCollection(collectionName: collectionName).get();
  }
}
