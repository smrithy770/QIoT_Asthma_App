import 'package:realm/realm.dart';

// Define the UserModel class extending RealmObject
part 'user_model.realm.dart';

@RealmModel()
class _UserModel {
  @PrimaryKey()
  late String userId;
  late String educationalPlan;
  late String accessToken;
  late String refreshToken;
  String? practionerContact;
}
