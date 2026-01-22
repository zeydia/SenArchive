
class ApiService {
  static const String baseUrl = 'http://10.0.2.2/api';


  static String addDocumentUrl() => '$baseUrl/document_add.php';

  static String listDocumentsUrl(String userId) => '$baseUrl/document_list.php?userId=$userId';

  static String deleteDocumentUrl() => '$baseUrl/document_delete.php';

  static String getDocumentDetailsUrl(String docId) => '$baseUrl/document_details.php?id=$docId';
}