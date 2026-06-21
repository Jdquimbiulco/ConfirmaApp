import 'package:flutter/material.dart';
import '../screens/explorar_eventos_screen.dart';
import '../screens/historial_eventos_screen.dart';
import '../screens/scanner_participante_screen.dart';
import '../screens/perfil_screen.dart';

class MainLayoutParticipante extends StatefulWidget {
  const MainLayoutParticipante({super.key});

  @override
  State<MainLayoutParticipante> createState() => _MainLayoutParticipanteState();
}

class _MainLayoutParticipanteState extends State<MainLayoutParticipante> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ExplorarEventosScreen(),
    ScannerParticipanteScreen(),
    PerfilScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explorar'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'Mi QR / Asistencia'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
