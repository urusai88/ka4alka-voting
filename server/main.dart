import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:hive/hive.dart';
import 'package:image/image.dart' as image;

final mimes = const {
  'js': ['text', 'javascript'],
  'png': ['image', 'png'],
  'css': ['text', 'css'],
  'woff2': ['font', 'woff2'],
  'ttf': ['font', 'ttf']
};

void main() async {
  final root = Directory('./');
  final storageDirectory = Directory('${root.path}/storage');

  if (!storageDirectory.existsSync()) {
    storageDirectory.createSync(recursive: true);
  }

  Hive.init('${root.path}/hive');

  final box = await Hive.openBox('images');

  try {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 4044);

    print('Сервер запущен на адресе 127.0.0.1:${server.port}');

    Process.run('start', ['http://127.0.0.1:${server.port}'], runInShell: true);

    await for (HttpRequest req in server) {
      if (req.uri.path.endsWith('.exe')) {
        req.response.close();
      }

      if (req.method.toUpperCase() == 'GET') {
        if (req.uri.toString() == '/') {
          req.response.headers.contentType = ContentType.html;

          try {
            await req.response
                .addStream(File('${root.path}/index.html').openRead());
          } catch (e) {
            print(e);
          }
        }

        final requestedFile = req.uri.toString().substring(1);
        final file = File('${root.path}/$requestedFile');

        if (file.existsSync()) {
          for (final mapEntry in mimes.entries) {
            if (requestedFile.endsWith('.${mapEntry.key}')) {
              req.response.headers.contentType =
                  ContentType(mapEntry.value[0], mapEntry.value[1]);
            }
          }

          await req.response.addStream(file.openRead());
        }
      }

      if (req.method.toUpperCase() == 'POST') {
        if (req.uri.toString() == '/image') {
          var contents = await utf8.decoder.bind(req).join();
          var extension = 'jpg';

          if (contents.startsWith('data:')) {
            extension = contents.substring(
                contents.indexOf('/') + 1, contents.indexOf(';'));
            contents = contents.substring(contents.indexOf(',') + 1);
          }

          final bytes = base64Decode(contents);
          final img = image.decodeImage(bytes);
          final resized = image.copyResize(img, width: 512);

          final randomInt = Random().nextInt(pow(2, 32));

          final fileName = '$randomInt.$extension';

          File('${storageDirectory.path}/$fileName')
              .writeAsBytesSync(image.encodeNamedImage(resized, '.$extension'));

          req.response.write(fileName);
        }
      }

      await req.response.close();
    }
  } catch (e) {
    print(e);
    exit(-1);
  }
}
