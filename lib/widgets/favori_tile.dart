import 'package:flutter/material.dart';
import 'package:meteomada/models/favori.dart';
import 'package:meteomada/models/ville.dart';
import 'package:meteomada/models/prevision.dart';

class FavoriTile extends StatelessWidget {
  final Favori favori;
  final Ville ville;
  final Prevision? prevision;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const FavoriTile({
    super.key,
    required this.favori,
    required this.ville,
    this.prevision,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final surnom = favori.surnom;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: ville.estCotiere ? Colors.blue[100] : Colors.green[100],
          child: Icon(
            ville.estCotiere ? Icons.waves : Icons.location_city,
            color: ville.estCotiere ? Colors.blue : Colors.green,
          ),
        ),
        title: Text(
          surnom ?? ville.nom,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          ville.region,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (prevision != null)
              Text(
                '${prevision!.temperature.toStringAsFixed(1)}°C',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                onPressed: onDelete,
              ),
          ],
        ),
      ),
    );
  }
}
