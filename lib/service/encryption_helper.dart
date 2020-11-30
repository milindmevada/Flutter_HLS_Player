import 'dart:convert';
import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EncryptionHelper {
  static const _secureRandom = "81426304854657283932562739334523";

  Future<void> encryptFile() async {
    final File inFile = await getOriginalFile();
    final File outFile = await getEncryptedFile();

    bool outFileExists = await outFile.exists();

    if (!outFileExists) {
      await outFile.create();
    }

    final videoFileContents = inFile.readAsStringSync(encoding: latin1);

    final key = Key.fromUtf8(_secureRandom);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(videoFileContents, iv: iv);
    await outFile.writeAsBytes(encrypted.bytes);
  }

  Future<void> decryptFile() async {
    final File inFile = await getEncryptedFile();
    final File outFile = await getOriginalFile();

    bool outFileExists = await outFile.exists();

    if (!outFileExists) {
      await outFile.create();
    }

    final videoFileContents = inFile.readAsBytesSync();

    final key = Key.fromUtf8(_secureRandom);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encryptedFile = Encrypted(videoFileContents);
    final decrypted = encrypter.decrypt(encryptedFile, iv: iv);

    final decryptedBytes = latin1.encode(decrypted);
    await outFile.writeAsBytes(decryptedBytes);
  }

  Future<File> getOriginalFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.joinAll([directory.path, "final.mp4"]));
  }

  Future<File> getEncryptedFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(p.joinAll([directory.path, "finalenc.aes"]));
  }
}
