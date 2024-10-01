import 'package:asthmaapp/main.dart';

class StorageService {
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      userData.forEach((key, value) async {
        await storage.write(key: key, value: value.toString());
      });
    } catch (e) {
      logger.d('Error saving user data: $e');
    }
  }

  Future<void> write(String key, String value) async {
    await storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await storage.delete(key: key);
  }

  Future<void> clearUserData() async {
    try {
      await storage.deleteAll();
    } catch (e) {
      logger.d('Error clearing user data: $e');
    }
  }
}

final storageService = StorageService();
