import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final invoices = appProvider.invoices;

    final outstandingBalance = invoices.where((i) => !i.isPaid).fold<double>(
      0,
          (sum, invoice) => sum + invoice.amount,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0A0906),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF5EFE2)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payments',
          style: TextStyle(
            fontFamily: 'Oswald',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFFF5EFE2),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Outstanding balance card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A160F),
                border: Border.all(
                  color: const Color(0xFFD4AF37),
                  width: 0.16,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Outstanding Balance',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFA89C85),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${outstandingBalance.toStringAsFixed(2)} EGP',
                        style: const TextStyle(
                          fontFamily: 'Oswald',
                          fontSize: 26,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF5EFE2),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: const Color(0xFF5FB87A),
                      border: Border.all(
                        color: const Color(0xFF5FB87A),
                        width: 0.3,
                      ),
                    ),
                    child: const Text(
                      'Fully Paid',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 9.5,
                        letterSpacing: 0.5,
                        color: Color(0xFF5FB87A),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Invoices',
              style: TextStyle(
                fontFamily: 'Oswald',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF5EFE2),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF1A160F),
                border: Border.all(
                  color: const Color(0xFFF5EFE2),
                  width: 0.07,
                ),
              ),
              child: Column(
                children: invoices.map((invoice) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      border: invoice.id == invoices.last.id
                          ? null
                          : const Border(
                        bottom: BorderSide(
                          color: Color(0xFFF5EFE2),
                          width: 0.07,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                invoice.description,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFF5EFE2),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${invoice.invoiceNumber} · ${DateFormat('dd MMM yyyy').format(invoice.date)}',
                                style: const TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 10,
                                  color: Color(0xFF6E6452),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${invoice.amount.toStringAsFixed(0)} EGP',
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 14,
                            color: Color(0xFFF2CF6C),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 14),

            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF5EFE2),
                side: const BorderSide(color: Color(0xFFD4AF37), width: 0.16),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: const Color(0xFF221C13),
              ),
              child: const Text(
                'DOWNLOAD ALL RECEIPTS',
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}