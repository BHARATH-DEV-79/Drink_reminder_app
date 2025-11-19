import 'package:flutter/material.dart';

class DropIcon extends StatefulWidget {
  const DropIcon({super.key});

  @override
  State<DropIcon> createState() => _DropIconState();
}

class _DropIconState extends State<DropIcon> {
  @override
  Widget build(BuildContext context) {
    return  Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.water_drop_outlined,
                    size: 120,
                    color: Colors.blue.shade400,
                  ),
                );

  }
}