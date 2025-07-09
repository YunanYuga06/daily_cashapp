// daily_cashapp/FrontEnd/lib/pages/halaman_crud/pilih_item_page.dart

import 'package:flutter/material.dart';
import 'package:daily_cashapp/config/app_theme.dart';

class PilihItemPage extends StatelessWidget {
  final String title;
  final List<String> items;

  const PilihItemPage({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih $title'),
        backgroundColor: AppTheme.surface,
        elevation: 1,
      ),
      body: ListView.separated(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            title: Text(item),
            onTap: () {
              // Kirim item yang dipilih kembali ke halaman sebelumnya
              Navigator.pop(context, item);
            },
          );
        },
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}