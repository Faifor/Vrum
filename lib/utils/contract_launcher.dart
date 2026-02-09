import 'dart:io';
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

Future<String?> openContractBytes({
  required Uint8List bytes,
  required String fileName,
}) async {
  try {
    final directory = await getTemporaryDirectory();
    final normalizedName = fileName.trim().isEmpty ? 'contract.docx' : fileName;
    final file = File('${directory.path}/$normalizedName');
    await file.writeAsBytes(bytes, flush: true);

    final result = await OpenFilex.open(file.path);
    if (result.type == ResultType.done) {
      return null;
    }
    return result.message.isEmpty
        ? 'Не удалось открыть файл договора'
        : result.message;
  } catch (_) {
    return 'Не удалось открыть файл договора';
  }
}
