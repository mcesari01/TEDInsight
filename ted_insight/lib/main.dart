import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'talk_repository.dart';
import 'models/talk.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyTEDx',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title = 'TED Insight'});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  final List<Talk> _allTalks = [];
  List<String> _popularTags = [];
  int page = 1;
  bool init = true;
  bool hasMore = true;
  bool isLoading = false;
  bool _isLoadingTags = true;

  @override
  void initState() {
    super.initState();
    _getPopularTags();
  }

  Future<void> _getPopularTags() async {
    try {
      final tags = await getPopularTags();
      setState(() {
        _popularTags = tags;
        _isLoadingTags = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingTags = false;
      });
    }
  }

  void _getTalksByTag() async {
    final String tag = _controller.text.trim();
    if (tag.isEmpty) return;

    setState(() {
      init = false;
      isLoading = true;
      _allTalks.clear();
      page = 1;
      hasMore = true;
    });

    final newTalks = await getTalksByTag(tag, page);

    setState(() {
      _allTalks.addAll(newTalks);
      hasMore = newTalks.isNotEmpty;
      isLoading = false;
    });
  }

  void _loadMoreTalks() async {
    final String tag = _controller.text.trim();
    if (tag.isEmpty || !hasMore || isLoading) return;

    setState(() {
      isLoading = true;
      page += 1;
    });

    final newTalks = await getTalksByTag(tag, page);

    setState(() {
      _allTalks.addAll(newTalks);
      hasMore = newTalks.isNotEmpty;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TED Insight')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: init
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter your favorite talk',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _controller.text.trim().isEmpty ? null : _getTalksByTag,
                    child: const Text('Search by tag'),
                  ),
                  const SizedBox(height: 24),
                  if (_isLoadingTags)
                    const CircularProgressIndicator()
                  else if (_popularTags.isNotEmpty)
                      Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _popularTags.map((tag) {
                        return ActionChip(
                          label: Text(tag),
                          onPressed: () {
                            _controller.text = tag;
                            _getTalksByTag();
                          },
                        );
                      }).toList(),
                    )
                  else
                  const SizedBox(), 
                ],
              )
            : isLoading && _allTalks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _allTalks.isEmpty
                    ? const Center(child: Text("No talks found for this tag."))
                    : Column(
                        children: [
                          Text(
                            "#${_controller.text}",
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _allTalks.length,
                              itemBuilder: (context, index) {
                                final talk = _allTalks[index];
                                final isEven = index % 2 == 0;

                                return Container(
                                  color: isEven ? Colors.white : Colors.red.shade50,
                                  child: ListTile(
                                    subtitle: Text(talk.mainSpeaker),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(talk.title),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          children: talk.keyPhrases.map((k) {
                                            return Chip(
                                              label: Text(k, style: const TextStyle(fontSize: 12)),
                                              backgroundColor: Colors.red.shade100,
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text(talk.details)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (isLoading)
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: (!init && hasMore && !isLoading)
          ? FloatingActionButton(
              child: const Icon(Icons.arrow_drop_down),
              onPressed: _loadMoreTalks,
            )
          : null,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                setState(() {
                  init = true;
                  page = 1;
                  _controller.clear();
                  _allTalks.clear();
                  hasMore = true;
                  isLoading = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}