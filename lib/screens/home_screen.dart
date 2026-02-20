import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final user = authService.getCurrentUser();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dream Destination'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade700,
              Colors.blue.shade500,
              Colors.blue.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Welcome Section
                const Text(
                  'Welcome!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You have successfully logged in',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),

                // User Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        user?.email ?? 'User',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'User ID: ${user?.uid.substring(0, 8) ?? 'N/A'}...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Management Buttons
                _buildManagementButton(
                  context,
                  icon: Icons.people,
                  label: 'Employee Management',
                  color: Colors.blue.shade700,
                  onTap: () => Navigator.pushNamed(context, '/employees'),
                ),
                const SizedBox(height: 16),

                _buildManagementButton(
                  context,
                  icon: Icons.train,
                  label: 'Train Management',
                  color: Colors.green.shade700,
                  onTap: () => Navigator.pushNamed(context, '/trains'),
                ),
                const SizedBox(height: 16),

                _buildManagementButton(
                  context,
                  icon: Icons.schedule,
                  label: 'Schedule Management',
                  color: Colors.orange.shade700,
                  onTap: () => Navigator.pushNamed(context, '/schedules'),
                ),
                const SizedBox(height: 16),

                _buildManagementButton(
                  context,
                  icon: Icons.assignment,
                  label: 'Attendance Reports',
                  color: Colors.purple.shade700,
                  onTap: () => Navigator.pushNamed(context, '/attendance'),
                ),
                const SizedBox(height: 16),

                _buildManagementButton(
                  context,
                  icon: Icons.analytics,
                  label: 'PSI Reports',
                  color: Colors.teal.shade700,
                  onTap: () => Navigator.pushNamed(context, '/psi'),
                ),
                const SizedBox(height: 16),

                _buildManagementButton(
                  context,
                  icon: Icons.credit_card,
                  label: 'Trip Card',
                  color: Colors.indigo.shade700,
                  onTap: () => Navigator.pushNamed(context, '/tripcard'),
                ),
                const SizedBox(height: 16),

                _buildManagementButton(
                  context,
                  icon: Icons.people_alt,
                  label: 'EHK Staff',
                  color: Colors.deepOrange.shade700,
                  onTap: () => Navigator.pushNamed(context, '/ehkstaff'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildManagementButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
