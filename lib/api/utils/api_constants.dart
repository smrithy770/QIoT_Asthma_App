class ApiConstants {
  // static const String baseURL =
  //     'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1';
  static const String baseURL = 'http://80.177.32.233:4200/api/v1';

  static const String refreshtoken = '/auth/refreshtoken';
  static const String signin = '/auth/signin';
  static const String signup = '/auth/signup';
  static String getSignoutUrl(String id) {
    return '/auth/signout/$id';
  }

  static String getHomepageDataUrl(String id) {
    return '/user/homepagedata/$id';
  }

  static String getUserByIdUrl(String id) {
    return '/user/$id';
  }

  static String uploadSteroidCardUrl(String userId) {
    return '/user/uploadsteroidcard/$userId';
  }

//Start of Note API
  static String getAllNotesUrl(String userId) {
    return '/user/$userId/notes';
  }

  static String getNotesByIdUrl(String userId, String noteId) {
    return '/user/$userId/notes/$noteId';
  }

  static String editNoteByIdUrl(String userId, String noteId) {
    return '/user/$userId/notes/$noteId';
  }

  static String deleteNoteByIdUrl(String userId, String noteId) {
    return '/user/$userId/notes/$noteId';
  }
  //End of Note API
}
