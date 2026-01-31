import 'package:flutter/material.dart';

class RiwayatTransaksiPenyewa extends StatelessWidget {
  const RiwayatTransaksiPenyewa({super.key});

  final Color primaryBlue = const Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: Stack(
        children: [
          Positioned(
            top: 60,
            right: -30,
            child: Opacity(
              opacity: 0.2,
              child: const Icon(
                Icons.star_outline,
                size: 200,
                color: Colors.white,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                'Back',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const Text(
            'Riwayat Transaksi',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Kontainer Gambar (Ukuran responsif menggunakan Flexible/SizedBox)
            Container(
              width: 80, // Sedikit diperkecil agar aman di layar sempit
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE7F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://via.placeholder.com/80x70',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.directions_car),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Detail Transaksi
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vespa Primavera 150',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF103667),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      Icon(
                        Icons.calendar_month,
                        size: 14,
                        color: Color(0xFF2F5586),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '23 Januari 2026',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Text(
                        'Status : ',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const Icon(Icons.circle, size: 8, color: Colors.red),
                      const SizedBox(width: 4),
                      const Expanded(
                        child: Text(
                          'Selesai Disewa',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
