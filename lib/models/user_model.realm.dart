// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// ignore_for_file: type=lint
class UserModel extends _UserModel
    with RealmEntity, RealmObjectBase, RealmObject {
  UserModel(
    String id,
    String accessToken,
    String refreshToken,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'accessToken', accessToken);
    RealmObjectBase.set(this, 'refreshToken', refreshToken);
  }

  UserModel._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

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
      'id': id.toEJson(),
      'accessToken': accessToken.toEJson(),
      'refreshToken': refreshToken.toEJson(),
    };
  }

  static EJsonValue _toEJson(UserModel value) => value.toEJson();
  static UserModel _fromEJson(EJsonValue ejson) {
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'accessToken': EJsonValue accessToken,
        'refreshToken': EJsonValue refreshToken,
      } =>
        UserModel(
          fromEJson(id),
          fromEJson(accessToken),
          fromEJson(refreshToken),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserModel._);
    register(_toEJson, _fromEJson);
    return SchemaObject(ObjectType.realmObject, UserModel, 'UserModel', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('accessToken', RealmPropertyType.string),
      SchemaProperty('refreshToken', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
