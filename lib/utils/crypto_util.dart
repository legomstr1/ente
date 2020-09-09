import 'dart:typed_data';

import 'dart:io' as io;
import 'package:aes_crypt/aes_crypt.dart';
import 'package:computer/computer.dart';
import 'package:encrypt/encrypt.dart';
import 'dart:convert';

import 'package:photos/core/configuration.dart';
import 'package:steel_crypt/steel_crypt.dart' as steel;
import 'package:uuid/uuid.dart';

class CryptoUtil {
  static Uint8List getSecureRandomBytes({int length = 32}) {
    return SecureRandom(length).bytes;
  }

  static Uint8List scrypt(Uint8List plainText, Uint8List salt) {
    return steel.PassCrypt.scrypt()
        .hashBytes(salt: salt, input: plainText, len: 32);
  }

  static Uint8List aesEncrypt(
      Uint8List plainText, Uint8List key, Uint8List iv) {
    final encrypter = AES(Key(key), mode: AESMode.cbc);
    return encrypter
        .encrypt(
          plainText,
          iv: IV(iv),
        )
        .bytes;
  }

  static Uint8List aesDecrypt(
      Uint8List cipherText, Uint8List key, Uint8List iv) {
    final encrypter = AES(Key(key), mode: AESMode.cbc);
    return encrypter.decrypt(
      Encrypted(cipherText),
      iv: IV(iv),
    );
  }

  static Future<String> encryptFileToFile(
      String sourcePath, String destinationPath, Uint8List key) async {
    final args = Map<String, dynamic>();
    args["key"] = key;
    args["source"] = sourcePath;
    args["destination"] = destinationPath;
    return Computer().compute(runEncryptFileToFile, param: args);
  }

  static Future<String> encryptDataToFile(
      Uint8List source, String destinationPath, Uint8List key) async {
    final args = Map<String, dynamic>();
    args["key"] = key;
    args["source"] = source;
    args["destination"] = destinationPath;
    return Computer().compute(runEncryptDataToFile, param: args);
  }

  static Future<String> encryptDataToData(
      Uint8List source, Uint8List key) async {
    final destinationPath =
        Configuration.instance.getTempDirectory() + Uuid().v4();
    return encryptDataToFile(source, destinationPath, key).then((value) {
      final file = io.File(destinationPath);
      final data = file.readAsBytesSync();
      file.deleteSync();
      return base64.encode(data);
    });
  }

  static Future<void> decryptFileToFile(
      String sourcePath, String destinationPath, Uint8List key) async {
    final args = Map<String, dynamic>();
    args["key"] = key;
    args["source"] = sourcePath;
    args["destination"] = destinationPath;
    return Computer().compute(runDecryptFileToFile, param: args);
  }

  static Future<Uint8List> decryptFileToData(String sourcePath, Uint8List key) {
    final args = Map<String, dynamic>();
    args["key"] = key;
    args["source"] = sourcePath;
    return Computer().compute(runDecryptFileToData, param: args);
  }

  static Future<Uint8List> decryptDataToData(Uint8List source, Uint8List key) {
    final sourcePath = Configuration.instance.getTempDirectory() + Uuid().v4();
    final file = io.File(sourcePath);
    file.writeAsBytesSync(source);
    return decryptFileToData(sourcePath, key).then((value) {
      file.deleteSync();
      return value;
    });
  }
}

Future<String> runEncryptFileToFile(Map<String, dynamic> args) {
  final encrypter = getEncrypter(base64.encode(args["key"] as Uint8List));
  return encrypter.encryptFile(args["source"], args["destination"]);
}

Future<String> runEncryptDataToFile(Map<String, dynamic> args) {
  final encrypter = getEncrypter(base64.encode(args["key"] as Uint8List));
  return encrypter.encryptDataToFile(args["source"], args["destination"]);
}

Future<String> runDecryptFileToFile(Map<String, dynamic> args) async {
  final encrypter = getEncrypter(base64.encode(args["key"] as Uint8List));
  return encrypter.decryptFile(args["source"], args["destination"]);
}

Future<Uint8List> runDecryptFileToData(Map<String, dynamic> args) async {
  final encrypter = getEncrypter(base64.encode(args["key"] as Uint8List));
  return encrypter.decryptDataFromFile(args["source"]);
}

AesCrypt getEncrypter(String key) {
  final encrypter = AesCrypt(key);
  encrypter.aesSetMode(AesMode.cbc);
  encrypter.setOverwriteMode(AesCryptOwMode.on);
  return encrypter;
}
