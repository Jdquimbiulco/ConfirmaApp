import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/evento.dart';
import '../viewmodels/login_viewmodel.dart';
import 'map_picker_screen.dart';

class CrearEventoScreen extends StatefulWidget {
  final VoidCallback? onEventoCreado;
  final Evento? eventoAEditar;
  
  const CrearEventoScreen({super.key, this.onEventoCreado, this.eventoAEditar});

  @override
  State<CrearEventoScreen> createState() => _CrearEventoScreenState();
}

class _CrearEventoScreenState extends State<CrearEventoScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _horaController = TextEditingController();
  final _lugarController = TextEditingController();
  final _cuposController = TextEditingController(text: '100');
  final _radioController = TextEditingController(text: '100'); 
  
  DateTime _fechaSeleccionada = DateTime.now();
  LatLng? _coordenadasSeleccionadas;
  NivelControl _nivelControl = NivelControl.estricto;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventoAEditar != null) {
      final e = widget.eventoAEditar!;
      _nombreController.text = e.nombre;
      _descripcionController.text = e.descripcion;
      _horaController.text = e.hora;
      _lugarController.text = e.lugar;
      _cuposController.text = e.cupos.toString();
      _radioController.text = e.radioToleranciaMetros.toString();
      _fechaSeleccionada = e.fecha;
      _coordenadasSeleccionadas = LatLng(e.latitud, e.longitud);
      _nivelControl = e.nivelControl;
    }
  }

  void _seleccionarEnMapa() async {
    LatLng posicionInicial;
    if (_coordenadasSeleccionadas != null) {
      posicionInicial = _coordenadasSeleccionadas!;
    } else {
      try {
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw Exception();
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
          if (permission == LocationPermission.denied) throw Exception();
        }
        Position position = await Geolocator.getCurrentPosition();
        posicionInicial = LatLng(position.latitude, position.longitude);
      } catch (e) {
        posicionInicial = const LatLng(-0.180653, -78.467834); // Quito fallback
      }
    }

    if (!mounted) return;
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MapPickerScreen(initialPosition: posicionInicial)),
    );

    if (result != null) {
      setState(() {
        _coordenadasSeleccionadas = result;
      });
    }
  }

  void _guardarEvento() async {
    setState(() { _isLoading = true; });
    try {
      if (_coordenadasSeleccionadas == null) {
        throw Exception('Debes seleccionar la ubicación en el mapa.');
      }

      final user = context.read<LoginViewModel>().currentUser!;
      final evento = Evento(
        id: widget.eventoAEditar?.id ?? const Uuid().v4(),
        organizadorId: widget.eventoAEditar?.organizadorId ?? user.id,
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim(),
        hora: _horaController.text.trim(),
        lugar: _lugarController.text.trim(),
        cupos: int.tryParse(_cuposController.text) ?? 100,
        latitud: _coordenadasSeleccionadas!.latitude,
        longitud: _coordenadasSeleccionadas!.longitude,
        radioToleranciaMetros: double.tryParse(_radioController.text) ?? 100.0,
        fecha: _fechaSeleccionada,
        nivelControl: _nivelControl,
      );

      final repo = context.read<EventRepository>();
      
      if (widget.eventoAEditar == null) {
        await repo.crearEvento(evento);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento creado con éxito'), backgroundColor: Colors.green));
      } else {
        await repo.editarEvento(evento);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Evento actualizado con éxito'), backgroundColor: Colors.blue));
      }
      
      if (widget.onEventoCreado != null) {
        // Limpiar si es creación nueva
        if (widget.eventoAEditar == null) {
          _nombreController.clear();
          _descripcionController.clear();
          _horaController.clear();
          _lugarController.clear();
        }
        widget.onEventoCreado!();
      } else {
        // Si no hay callback, probablemente abrió como pantalla de edición individual
        if (mounted) Navigator.pop(context, true);
      }

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.eventoAEditar == null ? 'Nuevo Evento' : 'Editar Evento')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(controller: _nombreController, decoration: const InputDecoration(labelText: 'Nombre del Evento', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _descripcionController, maxLines: 2, decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _horaController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Hora de Inicio',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null && mounted) {
                        _horaController.text = time.format(context);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: _cuposController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cupos Totales', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _lugarController, decoration: const InputDecoration(labelText: 'Lugar (Ej. Auditorio B)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            TextField(controller: _radioController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Radio GPS Tolerancia (metros)', border: OutlineInputBorder())),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              leading: const Icon(Icons.map, color: Colors.blue),
              title: Text(_coordenadasSeleccionadas == null ? 'Seleccionar Ubicación GPS en el Mapa' : 'Ubicación seleccionada'),
              subtitle: _coordenadasSeleccionadas != null ? Text('${_coordenadasSeleccionadas!.latitude.toStringAsFixed(4)}, ${_coordenadasSeleccionadas!.longitude.toStringAsFixed(4)}') : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: _seleccionarEnMapa,
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              title: Text('Fecha: ${_fechaSeleccionada.toString().substring(0, 10)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(context: context, initialDate: _fechaSeleccionada, firstDate: DateTime.now(), lastDate: DateTime(2030));
                if (date != null) setState(() { _fechaSeleccionada = date; });
              },
            ),
            const SizedBox(height: 24),
            const Text('Modo de Control:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            SegmentedButton<NivelControl>(
              segments: const [
                ButtonSegment(value: NivelControl.estricto, label: Text('Estricto\n(Organizador escanea)'), icon: Icon(Icons.security)),
                ButtonSegment(value: NivelControl.relajado, label: Text('Auto-Servicio\n(Asistente escanea)'), icon: Icon(Icons.qr_code)),
              ],
              selected: {_nivelControl},
              onSelectionChanged: (Set<NivelControl> newSelection) {
                setState(() { _nivelControl = newSelection.first; });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _guardarEvento,
                icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.save),
                label: Text(widget.eventoAEditar == null ? 'Guardar Evento' : 'Actualizar Evento'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
