import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const _storage = FlutterSecureStorage();
  
  // 存储加密数据
  static Future<void> storeEncryptedData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }
  
  // 读取加密数据
  static Future<String?> getEncryptedData(String key) async {
    return await _storage.read(key: key);
  }
  
  // 删除加密数据
  static Future<void> deleteEncryptedData(String key) async {
    await _storage.delete(key: key);
  }
  
  // 检查是否已开启生物识别
  static Future<bool> isBiometricEnabled() async {
    final enabled = await _storage.read(key: 'biometric_enabled');
    return enabled == 'true';
  }
  
  // 开启/关闭生物识别
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: 'biometric_enabled', value: enabled.toString());
  }
  
  // 验证生物识别（Windows平台暂不支持）
  static Future<bool> authenticateWithBiometrics() async {
    // Windows平台暂不支持生物识别
    return true;
  }
}