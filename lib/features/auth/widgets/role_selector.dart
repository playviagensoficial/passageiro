import 'package:flutter/material.dart';

class RoleSelector extends StatelessWidget {
  final String selectedRole;
  final Function(String) onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de conta',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _RoleOption(
                title: 'Passageiro',
                subtitle: 'Solicitar viagens',
                icon: Icons.person,
                isSelected: selectedRole == 'passenger',
                onTap: () => onRoleChanged('passenger'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _RoleOption(
                title: 'Motorista',
                subtitle: 'Dirigir e ganhar',
                icon: Icons.drive_eta,
                isSelected: selectedRole == 'driver',
                onTap: () => onRoleChanged('driver'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleOption({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00CC00).withOpacity(0.1) : Colors.grey[900],
          border: Border.all(
            color: isSelected ? const Color(0xFF00CC00) : Colors.grey[600]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF00CC00) : Colors.grey[700],
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.black : Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00CC00) : Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}