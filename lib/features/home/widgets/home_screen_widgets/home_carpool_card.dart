import 'package:flutter/material.dart';

class HomeCarpoolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final bool isEditing;
  final ValueChanged<String>? onTitleChanged;
  final ValueChanged<String>? onSubtitleChanged;

  const HomeCarpoolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
    this.isEditing = false,
    this.onTitleChanged,
    this.onSubtitleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isEditing ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isEditing
                      ? TextField(
                          controller: TextEditingController(text: title),
                          onChanged: onTitleChanged,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                          decoration: const InputDecoration(
                              border: InputBorder.none, isDense: true),
                        )
                      : Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  const SizedBox(height: 2),
                  isEditing
                      ? TextField(
                          controller: TextEditingController(text: subtitle),
                          onChanged: onSubtitleChanged,
                          style: const TextStyle(fontSize: 10),
                          decoration: const InputDecoration(
                              border: InputBorder.none, isDense: true),
                        )
                      : Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 10,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
