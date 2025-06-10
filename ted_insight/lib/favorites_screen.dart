import 'package:flutter/material.dart';
import 'models/talk.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Talk> favorites;

  const FavoritesScreen({super.key, required this.favorites});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferiti'),
        centerTitle: true,
      ),
      body: favorites.isEmpty
          ? const Center(child: Text('Nessun talk salvato.'))
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final talk = favorites[index];
                return ListTile(
                  title: Text(talk.title),
                  subtitle: Text(talk.mainSpeaker),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(talk.details)),
                    );
                  },
                );
              },
            ),
    );
  }
}