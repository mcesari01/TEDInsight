import 'package:flutter/material.dart';
import 'talk_repository.dart';
import 'models/talk.dart';
import 'thematic_path_screen.dart';
import 'favorites_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TED Insight',
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _selectedIndex = 0;
  List<Talk> _favoriteTalks = [];
  late List<Widget> _pages;

  void _toggleFavorite(Talk talk) {
    setState(() {
      if (_favoriteTalks.any((t) => t.title == talk.title)) {
        _favoriteTalks.removeWhere((t) => t.title == talk.title);
      } else {
        _favoriteTalks.add(talk);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _pages = [
      ExploreScreen(
        onToggleFavorite: _toggleFavorite,
        favorites: _favoriteTalks,
      ),
      ThematicPathScreen(
        onToggleFavorite: _toggleFavorite,
        favorites: _favoriteTalks,
      ),
      FavoritesScreen(favorites: _favoriteTalks),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepOrange,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Esplora',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Percorsi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Preferiti',
          ),
        ],
      ),
    );
  }
}

class ExploreScreen extends StatefulWidget {
  final Function(Talk) onToggleFavorite;
  final List<Talk> favorites;

  const ExploreScreen({
    super.key,
    required this.onToggleFavorite,
    required this.favorites,
  });

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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

  void _resetSearch() {
    setState(() {
      init = true;
      page = 1;
      _controller.clear();
      _allTalks.clear();
      hasMore = true;
      isLoading = false;
    });
  }

  bool _isFavorite(Talk talk) {
    return widget.favorites.any((t) => t.title == talk.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: !init
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: _resetSearch,
              )
            : null,
        title: const Text(
          'TED Insight',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: init
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Esplora per argomento (es. innovation)',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.deepOrange, width: 2),
                      ),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _controller.text.trim().isEmpty ? null : _getTalksByTag,
                      icon: const Icon(Icons.search),
                      label: const Text('Cerca Talk'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_popularTags.isNotEmpty) ...[
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tag più popolari:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: _popularTags.map((tag) {
                        return ActionChip(
                          label: Text(tag, style: TextStyle(color: Colors.black)),
                          backgroundColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.deepOrange.shade300
                              : Colors.deepOrange.shade100,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Filtra per: $tag')),
                            );
                            _controller.text = tag;
                            _getTalksByTag();
                          },
                        );
                      }).toList(),
                    )
                  ] else
                    const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text('Nessun tag disponibile.'),
                    ),
                ],
              )
            : isLoading && _allTalks.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _allTalks.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Nessun talk trovato."),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Torna indietro"),
                            onPressed: _resetSearch,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              "#${_controller.text}",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _allTalks.length,
                              itemBuilder: (context, index) {
                                final talk = _allTalks[index];
                                final isFav = _isFavorite(talk);
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                                  child: ListTile(
                                    subtitle: Text(talk.mainSpeaker),
                                    title: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          talk.title,
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          children: talk.keyPhrases.map((k) {
                                            return Chip(
                                              label: Text(k, style: const TextStyle(fontSize: 12)),
                                              backgroundColor: Theme.of(context).brightness == Brightness.dark
                                              ? Colors.deepOrange.shade300
                                              : Colors.deepOrange.shade100,
                                            );
                                          }).toList(),
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                      widget.onToggleFavorite(talk);
                                      setState(() {}); 
                                    },
                                      icon: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        transitionBuilder: (child, animation) =>
                                            ScaleTransition(scale: animation, child: child),
                                        child: Icon(
                                          isFav ? Icons.favorite : Icons.favorite_border,
                                          key: ValueKey<bool>(isFav),
                                          color: isFav ? Colors.red : null,
                                        ),
                                      ),
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
    );
  }
}