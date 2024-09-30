class ApiConstants {
  // static const String baseURL =
  //     'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1';
  static const String baseURL = 'http://80.177.32.233:4200/api/v1';

  static const String refreshtoken = '/auth/refreshtoken';
  static const String signin = '/auth/signin';
  static const String signup = '/auth/signup';
  static String getSignoutUrl(String userId) {
    return '/auth/signout/$userId';
  }

  static String getHomepageDataUrl(String userId) {
    return '/user/homepagedata/$userId';
  }

  static String getUserByIdUrl(String userId) {
    return '/user/$userId';
  }

  static String addPeakflowUrl(String userId) {
    return '/user/$userId/peakflow';
  }

  static String getAllPeakflowUrl(String userId) {
    return '/user/$userId/peakflow';
  }

  static String addSteroidDoseUrl(String userId) {
    return '/user/$userId/steroiddose';
  }

  static String uploadSteroidCardUrl(String userId) {
    return '/user/$userId/steroiddose/uploadsteroidcard';
  }

  static String getAllSteroidDoseUrl(String userId) {
    return '/user/$userId/steroiddose';
  }

  static String addAsthamControlTestUrl(String userId) {
    return '/user/$userId/asthamcontroltest';
  }

  static String getAllAsthamControlTestUrl(String userId) {
    return '/user/$userId/asthamcontroltest';
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
