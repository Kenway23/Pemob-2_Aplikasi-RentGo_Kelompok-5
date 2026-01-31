import 'package:flutter/material.dart';
import 'package:gorent/penyewa/riwayat_transaksi.dart';

class DetailRental extends StatelessWidget {
  const DetailRental({super.key});

  static const Color primaryBlue = Color(0xFF2F5586);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  children: [
                    _carInfo(),
                    const SizedBox(height: 16),
                    _features(),
                    const SizedBox(height: 16),
                    _renterInfo(),
                    const Spacer(),
                    _actionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Text(
              'Back',
              style: TextStyle(color: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Car Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Image.network(
          'https://via.placeholder.com/300x160',
          height: 140,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) =>
              const Icon(Icons.directions_car, size: 100, color: Colors.white),
        ),
      ],
    );
  }

  // ================= CAR INFO =================
  Widget _carInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Tesla Model S',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Sedang menunggu persetujuan',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Row(
          children: const [
            Text('5.0', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(width: 4),
            Icon(Icons.star, color: Colors.orange, size: 18),
            SizedBox(width: 4),
            Text('(100+ Reviews)', style: TextStyle(fontSize: 11)),
          ],
        ),
      ],
    );
  }

  // ================= FEATURES =================
  Widget _features() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Car features',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.1,
          children: const [
            _FeatureItem('Capacity', '5 Seats', Icons.event_seat),
            _FeatureItem('Engine Out', '670 HP', Icons.speed),
            _FeatureItem('Max Speed', '250km/h', Icons.trending_up),
            _FeatureItem('Autopilot', 'Advance', Icons.auto_awesome),
            _FeatureItem('Charge', '405 Miles', Icons.battery_charging_full),
            _FeatureItem('Time', '1 Day', Icons.access_time),
          ],
        ),
      ],
    );
  }

  // ================= RENTER =================
  Widget _renterInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Penyewa',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('IDR XXXXX / 3 Day',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.red, size: 18),
              Text('Chicago, USA', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  // ================= BUTTON =================
  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {},
            child: const Text('Tolak'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {},
            child: const Text('Setujui'),
          ),
        ),
      ],
    );
  }
}

// ================= FEATURE ITEM =================
class _FeatureItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _FeatureItem(this.title, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: DetailRental.primaryBlue),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
