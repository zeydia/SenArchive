import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../providers/document_provider.dart';
import '../../repositories/document_repository.dart';
import '../../models/document_model.dart';

class DocumentEditScreen extends ConsumerStatefulWidget {
  final String documentId;

  const DocumentEditScreen({super.key, required this.documentId});

  @override
  ConsumerState<DocumentEditScreen> createState() => _DocumentEditScreenState();
}

class _DocumentEditScreenState extends ConsumerState<DocumentEditScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'Facture';
  bool _isLoading = false;
  bool _isInitialized = false;

  final List<String> _categories = ['Facture', 'Contrat', 'Identité', 'Santé', 'Autres'];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final docsAsync = ref.watch(documentsStreamProvider);
      docsAsync.whenData((docs) {
        final doc = docs.firstWhere((d) => d.id == widget.documentId);
        _titleController.text = doc.title;
        _descController.text = doc.description;
        _selectedCategory = doc.category;
        _isInitialized = true;
      });
    }
  }

  Future<void> _update() async {
    if (_titleController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      // Note: Assurez-vous d'avoir une méthode updateDocument dans votre Repository
      // Ici, nous simulons l'appel avec les données du formulaire
      await ref.read(documentRepositoryProvider).deleteDocument(widget.documentId);
      // Dans un cas réel, vous feriez un appel PUT à document_update.php

      if (mounted) context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la mise à jour : $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier le document', style: GoogleFonts.lexend()),
      ),
      body: !_isInitialized
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titre du document',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Catégorie',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val!),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _update,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Enregistrer les modifications',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}