import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

PreferredSizeWidget buildTransaksiAppBar({
  required DateTime currentMonth,
  required VoidCallback onNextMonth,
  required VoidCallback onPreviousMonth,
  required TabController tabController,
}) {
  final monthLabel = DateFormat.yMMMM('id').format(currentMonth);

  return AppBar(
    backgroundColor: Colors.orange,
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_left),
              onPressed: onPreviousMonth,
            ),
            Text(
              monthLabel,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_double_arrow_right),
              onPressed: onNextMonth,
            ),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.search),
            SizedBox(width: 12),
            Icon(Icons.filter_list),
          ],
        ),
      ],
    ),
    bottom: TabBar(
      controller: tabController,
      indicatorColor: Colors.white,
      tabs: const [
        Tab(text: 'Harian'),
        Tab(text: 'Bulanan'),
        Tab(text: 'Anggaran'),
        Tab(text: 'Dashboard'),
      ],
    ),
  );
}
