import 'package:flutter/material.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf6f6f8),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDFFvQQ22BKpqt_ehNksh5sfskzTDrPjqbB5FAOS284BPrDgycw6PeD-uuLuRlsy_rcsT62eQqsZREqtSHLOtouURTqnnVjOSpbnkE6_TaaYjcHupBL9-M7CgqTo7r94veV3AhaIt5_UMeR-rr-tF1V55cdACziSGixxXC6cbosJhgI1QF8gdfdwxYIo6VvMW1gOzKQTH-VN0xIg7D2BybHTlmbz7UCw_IPbEsI6xBVL-nelPfbjDNpgPLp6uKLMElQuTx3Y99p2GI',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Gokul Kumar',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Class 8-A',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 32),

            _buildInfoTile(Icons.email, 'Email', 'gokul@example.com'),
            _buildInfoTile(Icons.phone, 'Phone', '+91 98765 43210'),
            _buildInfoTile(Icons.calendar_today, 'DOB', '15 Aug 2010'),
            _buildInfoTile(
              Icons.location_on,
              'Address',
              '123, Gandhi Nagar, Jaipur',
            ),
            _buildInfoTile(Icons.family_restroom, 'Guardian', 'Rajesh Kumar'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
