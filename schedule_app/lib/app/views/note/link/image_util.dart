import 'dart:io';


import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tiny_logger/tiny_logger.dart';

import '../shortcut_event.dart';

Future<String?> saveImageToLocalStorage(String localImagePath) async {
  final path = await getApplicationSupportDirectory();
  final imagePath = p.join(
    path.path,
    'images',
  );
  try {
    // create the directory if not exists
    final directory = Directory(imagePath);
    if (!directory.existsSync()) {
      await directory.create(recursive: true);
    }
    final copyToPath = p.join(
      imagePath,
      '${uuid()}${p.extension(localImagePath)}',
    );
    await File(localImagePath).copy(
      copyToPath,
    );
    return copyToPath;
  } catch (e) {
    log.error('cannot save image file${e.toString()}');
    return null;
  }
}
