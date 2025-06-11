import 'package:flutter/material.dart';
import 'talk_repository.dart';
import 'models/talk.dart';

class ThematicPathScreen extends StatefulWidget {
  final Function(Talk) onToggleFavorite;
  final List<Talk> favorites;

  const ThematicPathScreen({
    super.key,
    required this.onToggleFavorite,
    required this.favorites,
  });

  @override
  State<ThematicPathScreen> createState() => _ThematicPathScreenState();
}

class _ThematicPathScreenState extends State<ThematicPathScreen> {
  bool _isFavorite(Talk talk) {
    return widget.favorites.any((t) => t.title == talk.title);
  }
  final TextEditingController _controller = TextEditingController();
  int _maxDuration = 250;
  bool isLoading = false;
  List<Talk> _pathTalks = [];

  void _loadThematicPath() async {
    final tag = _controller.text.trim();
    if (tag.isEmpty) return;

    setState(() {
      isLoading = true;
      _pathTalks.clear();
    });

    try {
      final talks = await getThematicPath(tag, _maxDuration);
      setState(() {
        _pathTalks = talks;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Errore nel caricamento del percorso')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Percorso Tematico')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Inserisci un argomento (tag)',
                prefixIcon: Icon(Icons.tag),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text('Tempo massimo: $_maxDuration minuti'),
            Slider(
              value: _maxDuration.toDouble(),
              min: 60,
              max: 600,
              divisions: 54,
              label: '$_maxDuration min',
              onChanged: (val) {
                setState(() {
                  _maxDuration = (val / 10).round() * 10;
                });
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loadThematicPath,
                child: const Text('Genera percorso'),
              ),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_pathTalks.isEmpty)
              const Text('Nessun talk trovato per questo percorso.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _pathTalks.length,
                  itemBuilder: (context, index) {
                    final talk = _pathTalks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(talk.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${talk.duration} minuti - ${talk.mainSpeaker}'),
                            Wrap(
                              spacing: 6,
                              children: talk.keyPhrases
                                  .map((k) => Chip(
                                        label: Text(k, style: const TextStyle(fontSize: 12)),
                                      ))
                                  .toList(),
                            )
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
                              _isFavorite(talk) ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey<bool>(_isFavorite(talk)),
                              color: _isFavorite(talk) ? Colors.red : null,
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
          ],
        ),
      ),
    );
  }
}