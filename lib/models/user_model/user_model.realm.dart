// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
// Add practionerContact field, getter, and setter
class UserModel extends _UserModel
    with RealmEntity, RealmObjectBase, RealmObject {
  UserModel(
      String userId,
      String educationalPlan,
      String accessToken,
      String refreshToken,
      String practionerContact, // Add the practionerContact parameter to the constructor
      ) {
    RealmObjectBase.set(this, 'userId', userId);
    RealmObjectBase.set(this, 'educationalPlan', educationalPlan);
    RealmObjectBase.set(this, 'accessToken', accessToken);
    RealmObjectBase.set(this, 'refreshToken', refreshToken);
    RealmObjectBase.set(this, 'practionerContact', practionerContact);  // Set the practionerContact value
  }

  UserModel._();

  @override
  String get userId => RealmObjectBase.get<String>(this, 'userId') as String;
  @override
  set userId(String value) => RealmObjectBase.set(this, 'userId', value);

  @override
  String get educationalPlan =>
      RealmObjectBase.get<String>(this, 'educationalPlan') as String;
  @override
  set educationalPlan(String value) =>
      RealmObjectBase.set(this, 'educationalPlan', value);

  @override
  String get accessToken =>
      RealmObjectBase.get<String>(this, 'accessToken') as String;
  @override
  set accessToken(String value) =>
      RealmObjectBase.set(this, 'accessToken', value);

  @override
  String get refreshToken =>
      RealmObjectBase.get<String>(this, 'refreshToken') as String;
  @override
  set refreshToken(String value) =>
      RealmObjectBase.set(this, 'refreshToken', value);


  // Add getter and setter for practionerContact (nullable String?)
  String? get practionerContact => RealmObjectBase.get<String>(this, 'practionerContact') as String?;
  set practionerContact(String? value) => RealmObjectBase.set(this, 'practionerContact', value);

  @override
  Stream<RealmObjectChanges<UserModel>> get changes =>
      RealmObjectBase.getChanges<UserModel>(this);

  @override
  Stream<RealmObjectChanges<UserModel>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<UserModel>(this, keyPaths);

  @override
  UserModel freeze() => RealmObjectBase.freezeObject<UserModel>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'userId': userId.toEJson(),
      'educationalPlan': educationalPlan.toEJson(),
      'accessToken': accessToken.toEJson(),
      'refreshToken': refreshToken.toEJson(),
      'practionerContact': practionerContact.toEJson(), // Add practionerContact to the EJson
    };
  }

  static EJsonValue _toEJson(UserModel value) => value.toEJson();
  static UserModel _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
      'userId': EJsonValue userId,
      'educationalPlan': EJsonValue educationalPlan,
      'accessToken': EJsonValue accessToken,
      'refreshToken': EJsonValue refreshToken,
      'practionerContact': EJsonValue practionerContact, // Handle practionerContact here
      } =>
          UserModel(
            fromEJson(userId),
            fromEJson(educationalPlan),
            fromEJson(accessToken),
            fromEJson(refreshToken),
            fromEJson(practionerContact), // Add practionerContact in _fromEJson
          ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserModel._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, UserModel, 'UserModel', [
      SchemaProperty('userId', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('educationalPlan', RealmPropertyType.string),
      SchemaProperty('accessToken', RealmPropertyType.string),
      SchemaProperty('refreshToken', RealmPropertyType.string),
      SchemaProperty('practionerContact', RealmPropertyType.string), // Add schema definition for practionerContact
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
