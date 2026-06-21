import 'package:flutter/material.dart';
import '../screens/dashboard_organizador.dart';
import '../screens/crear_evento_screen.dart';
import '../screens/perfil_screen.dart';

class MainLayoutOrganizador extends StatefulWidget {
  const MainLayoutOrganizador({super.key});

  @override
  State<MainLayoutOrganizador> createState() => _MainLayoutOrganizadorState();
}

class _MainLayoutOrganizadorState extends State<MainLayoutOrganizador> {
  int _currentIndex = 0;

  // Key global para forzar recarga de eventos si es necesario
  final GlobalKey<DashboardOrganizadorState> _dashboardKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          DashboardOrganizador(key: _dashboardKey),
          CrearEventoScreen(
            onEventoCreado: () {
              setState(() {
                _currentIndex = 0; // Regresar a la lista de eventos
              });
              _dashboardKey.currentState?.reloadEventos();
            },
          ),
          const PerfilScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.event), label: 'Eventos'),
          NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Crear Evento'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
      ),
    );
  }
}
