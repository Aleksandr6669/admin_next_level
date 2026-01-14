import 'package:flutter/material.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey[900],
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.white70),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: const TextStyle(color: Colors.white70, fontSize: 14.0),
                      ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
