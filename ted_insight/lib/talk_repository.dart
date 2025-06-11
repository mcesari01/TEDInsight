import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/talk.dart';

Future<List<Talk>> initEmptyList() async {
  Iterable list = json.decode("[]");
  return list.map((model) => Talk.fromJSON(model)).toList();
}

Future<List<Talk>> getTalksByTag(String tag, int page) async {
  var url = Uri.parse('https://q7m2ipxw7h.execute-api.us-east-1.amazonaws.com/default/Get_Talks_By_ID');

  final http.Response response = await http.post(url,
    headers: <String, String>{
      'Content-Type': 'application/json',
    },
    body: jsonEncode(<String, Object>{
      'tag': tag,
      'page': page,
      'doc_per_page': 6
    }),
  );

  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final List<dynamic> jsonList = json.decode(body);
    return jsonList.map((json) => Talk.fromJSON(json)).toList();
  } else {
    throw Exception('Failed to load talks');
  }
}

Future<List<String>> getPopularTags() async {
  const String url = 'https://r7d06nbt1d.execute-api.us-east-1.amazonaws.com/default/Get_Popular_Tags'; 

  final http.Response response = await http.get(Uri.parse(url));
  if (response.statusCode == 200) {
    final List<dynamic> jsonList = json.decode(response.body);
    return jsonList.map((tagObj) => tagObj['tag'].toString()).toList();
  } else {
    throw Exception('Failed to load popular tags');
  }
}


Future<List<Talk>> getThematicPath(String tag, int maxDuration) async {
  const String url = 'https://pj8d9g5fij.execute-api.us-east-1.amazonaws.com/default/Get_Thematic_Path'; 

  final http.Response response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'tag': tag,
      'max_duration': maxDuration,
    }),
  );

  if (response.statusCode == 200) {
    final body = utf8.decode(response.bodyBytes);
    final List<dynamic> jsonList = json.decode(body);
    return jsonList.map((json) => Talk.fromJSON(json)).toList();
  } else {
    throw Exception('Failed to load thematic path');
  }
}