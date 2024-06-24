class ApiConstants {
  static const String baseURL =
      'https://qiot-beta-f5013130cafe.herokuapp.com/api/v1';

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

  static const String getAllAsthmaMessages = '/user/asthmamessages';
}
