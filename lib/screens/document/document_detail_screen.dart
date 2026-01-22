import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/document_mysql_stream_provider.dart';
import '../../repositories/document_repository.dart';
import '../../models/document_model.dart';

class DocumentDetailScreen extends ConsumerWidget {
  final String documentId;

  const DocumentDetailScreen({super.key, required this.documentId});

  Future<void> _openFile(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le document ?'),
        content: const Text('Cette action est irréversible.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              await ref.read(documentRepositoryProvider).deleteDocument(id);
              if (context.mounted) {
                context.pop(); // Ferme le dialog
                context.pop(); // Retourne à la liste
              }
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(documentsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du document', style: GoogleFonts.lexend()),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: () => _confirmDelete(context, ref, documentId),
          ),
        ],
      ),
      body: documentsAsync.when(
        data: (docs) {
          final doc = docs.firstWhere(
                (d) => d.id == documentId,
            orElse: () => throw Exception('Document non trouvé'),
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPreview(doc),
                const SizedBox(height: 25),
                Text(
                  doc.title,
                  style: GoogleFonts.lexend(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Chip(
                  label: Text(doc.category),
                  backgroundColor: Colors.indigo.shade50,
                  labelStyle: const TextStyle(color: Colors.indigo),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                _buildInfoRow(Icons.description_outlined, 'Description', doc.description.isEmpty ? 'Aucune description' : doc.description),
                const SizedBox(height: 15),
                _buildInfoRow(Icons.calendar_today_outlined, 'Archivé le', doc.createdAt?.toLocal().toString().split('.')[0] ?? 'Date inconnue'),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: () => _openFile(doc.fileUrl),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Ouvrir le document'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildPreview(DocumentModel doc) {
    final isImage = doc.fileUrl.contains(RegExp(r'(jpg|jpeg|png)'));

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
      ),
      child: isImage
          ? ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Image.network(doc.fileUrl, fit: BoxFit.cover),
      )
          : const Icon(Icons.insert_drive_file_outlined, size: 80, color: Colors.grey),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.indigo, size: 20),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey)),
              Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}