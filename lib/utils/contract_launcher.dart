import 'package:url_launcher/url_launcher.dart';

const String _defaultApiBase = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://89.108.113.13',
);

Future<String?> openContractUrl(String? rawUrl) async {
  final uri = _parseContractUri(rawUrl);
  if (uri == null) {
    return 'Некорректная ссылка на договор';
  }

  try {
    var launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (!launched) {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (!launched) {
      return 'Не удалось открыть ссылку договора';
    }
    return null;
  } catch (_) {
    return 'Не удалось открыть ссылку договора';
  }
}

Uri? _parseContractUri(String? rawUrl) {
  final normalized = rawUrl?.trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  final direct = Uri.tryParse(normalized);
  if (direct != null && direct.hasScheme) {
    return direct;
  }

  final base = Uri.tryParse(_defaultApiBase);
  if (base == null) {
    return direct;
  }

  return base.resolveUri(direct ?? Uri(path: normalized));
}