class Talk {
  final String title;
  final String details;
  final String mainSpeaker;
  final String url;
  final String slug;
  final List<String> keyPhrases;
  final String duration;

  Talk.fromJSON(Map<String, dynamic> jsonMap)
    : title = jsonMap['title'],
      details = jsonMap['description'] ?? "",
      mainSpeaker = jsonMap['speakers'] ?? "",
      url = jsonMap['url'] ?? "",
      slug = jsonMap['slug'] ?? "",
      duration = jsonMap['duration']?.toString() ?? "",
      keyPhrases = (jsonMap['keyPhrases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
}
