import 'package:xml/xml.dart' as xml;

import '../../extensions/helpers_extension.dart';
import '../../retry.dart';
import '../youtube_http_client.dart';

///
class ClosedCaptionClient {
  final xml.XmlDocument root;

  ///
  late final Iterable<ClosedCaption> closedCaptions =
      root.findAllElements('p').map((e) => ClosedCaption._(e));

  ///
  ClosedCaptionClient(this.root);

  ///
  // ignore: deprecated_member_use
  ClosedCaptionClient.parse(String raw) : root = xml.XmlDocument.parse(raw);

  ///
  static Future<ClosedCaptionClient> get(
    YoutubeHttpClient httpClient,
    Uri url,
  ) {
    final formatUrl = url.replaceQueryParameters({'fmt': 'srv3'});
    // Caption URLs from Android API require Android user-agent headers.
    return retry(httpClient, () async {
      final raw = await httpClient.getString(
        formatUrl,
        headers: {
          'user-agent':
              'com.google.android.youtube/20.10.38 (Linux; U; Android 11) gzip',
        },
      );
      return ClosedCaptionClient.parse(raw);
    });
  }
}

///
class ClosedCaption {
  final xml.XmlElement root;

  ///
  String get text => root.innerText;

  ///
  late final Duration offset =
      Duration(milliseconds: int.parse(root.getAttribute('t') ?? '0'));

  ///
  late final Duration duration =
      Duration(milliseconds: int.parse(root.getAttribute('d') ?? '0'));

  ///
  late final Duration end = offset + duration;

  ///
  late final List<ClosedCaptionPart> parts =
      root.findAllElements('s').map((e) => ClosedCaptionPart._(e)).toList();

  ClosedCaption._(this.root);
}

///
class ClosedCaptionPart {
  final xml.XmlElement root;

  ///
  String get text => root.innerText;

  ///
  late final Duration offset =
      Duration(milliseconds: int.parse(root.getAttribute('t') ?? '0'));

  ClosedCaptionPart._(this.root);
}
