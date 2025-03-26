// https://youtube.com/playlist?list=RDDHsYF8ihEKI&playnext=1&si=6CuDwJ0ZhZGULGXv
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
class YtUtils{
  static Future<List<String>> getVideoIdsFromPlaylist(String playlistUrl) async {
    final response = await http.get(Uri.parse(playlistUrl));

    if (response.statusCode == 200) {
      final document = parse(response.body);
      final List<String> videoIds = [];
      print("document:${response.body}");

      // Extract video IDs from YouTube's HTML structure
      document
          .querySelectorAll('a[href*="watch?v="]')
          .forEach((element) {
        final href = element.attributes['href'];
        if (href != null && href.contains('watch?v=')) {
          final videoId = Uri.parse('https://youtube.com$href').queryParameters['v'];
          if (videoId != null && !videoIds.contains(videoId)) {
            videoIds.add(videoId);
          }
        }
      });

      return videoIds;
    } else {
      throw Exception('Failed to load playlist page');
    }
  }
}



void main() async {
  String playlistUrl = 'https://youtube.com/playlist?list=RDDHsYF8ihEKI&playnext=1&si=6CuDwJ0ZhZGULGXv';
  try {
    List<String> videoIds = await YtUtils.getVideoIdsFromPlaylist(playlistUrl);
    print("Extracted Video IDs: $videoIds");
  } catch (e) {
    print("Error: $e");
  }
}