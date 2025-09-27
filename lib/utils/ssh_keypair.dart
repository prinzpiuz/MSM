import 'dart:convert';
import 'dart:io' show File;
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:path_provider/path_provider.dart'
    show getExternalStorageDirectory;
import 'package:pointycastle/export.dart';

class SSHKeyPair {
  final String privateKeyPem;
  final String publicKeyOpenSSH;
  SSHKeyPair(this.privateKeyPem, this.publicKeyOpenSSH);
}

String encodeRSAPublicKeyToOpenSSH(RSAPublicKey publicKey,
    {String comment = "flutter@msm"}) {
  final algorithm = utf8.encode("ssh-rsa");
  final eBytes = _encodeBigInt(publicKey.exponent!);
  final nBytes = _encodeBigInt(publicKey.modulus!);

  final buffer = BytesBuilder();
  buffer.add(_encodeLength(algorithm.length));
  buffer.add(algorithm);

  buffer.add(_encodeLength(eBytes.length));
  buffer.add(eBytes);

  buffer.add(_encodeLength(nBytes.length));
  buffer.add(nBytes);

  final base64Key = base64.encode(buffer.toBytes());
  return "ssh-rsa $base64Key $comment";
}

/// Encode a BigInt to unsigned big-endian bytes
Uint8List _encodeBigInt(BigInt number) {
  final hex = number.toRadixString(16);
  final evenHex = hex.length % 2 == 0 ? hex : "0$hex";
  final bytes = Uint8List.fromList(List<int>.generate(evenHex.length ~/ 2,
      (i) => int.parse(evenHex.substring(i * 2, i * 2 + 2), radix: 16)));
  if (bytes.isNotEmpty && bytes[0] & 0x80 != 0) {
    // add leading 0x00 for sign bit
    return Uint8List.fromList([0, ...bytes]);
  }
  return bytes;
}

/// Encode length as 4-byte big-endian
Uint8List _encodeLength(int length) {
  final b = ByteData(4)..setUint32(0, length);
  return b.buffer.asUint8List();
}

SSHKeyPair generateRSAKeyPair({int bitLength = 2048}) {
  final keyGen = RSAKeyGenerator()
    ..init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      SecureRandom('Fortuna')
        ..seed(KeyParameter(Uint8List.fromList(
            List.generate(32, (_) => DateTime.now().millisecond)))),
    ));

  final pair = keyGen.generateKeyPair();
  final private = pair.privateKey as RSAPrivateKey;
  final public = pair.publicKey as RSAPublicKey;
  final privatePem = CryptoUtils.encodeRSAPrivateKeyToPemPkcs1(private);
  final publicOpenSSH =
      encodeRSAPublicKeyToOpenSSH(public, comment: 'com.prinzpiuz.msm');

  return SSHKeyPair(privatePem, publicOpenSSH);
}

Future<String> savePrivateKeyLocally(String privateKeyPem) async {
  final dir = await getExternalStorageDirectory();
  final file = File('${dir?.path}/id_rsa.key');
  await file.writeAsString(privateKeyPem, flush: true);
  return file.path;
}
