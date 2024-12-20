import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart' as fluent_system;
import '../models/marker_model.dart';
import '../services/firebase_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final MapController _mapController = MapController();
  List<MarkerModel> markers = [];
  bool isLoading = true;
  LatLng _center = LatLng(49.58951146789152, 34.55103417186048);
  double _zoom = 12.0;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    final loadedMarkers = await _firebaseService.getMarkers();
    setState(() {
      markers = loadedMarkers;
      isLoading = false;
    });
  }

  void _addMarker(MarkerModel marker) async {
    await _firebaseService.addMarker(marker);
    final loadedMarkers = await _firebaseService.getMarkers();
    setState(() {
      markers = loadedMarkers;
    });
  }

  void _updateMarker(MarkerModel marker) async {
    await _firebaseService.updateMarker(marker);
    final loadedMarkers = await _firebaseService.getMarkers();
    setState(() {
      markers = loadedMarkers;
    });
  }

  void _deleteMarker(String id) async {
    await _firebaseService.deleteMarker(id);
    final loadedMarkers = await _firebaseService.getMarkers();
    setState(() {
      markers = loadedMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: const Text('Мапа')),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: isLoading
          ? const Center(child: ProgressRing())
          : FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _center,
                zoom: _zoom,
                onPositionChanged: (position, hasGesture) {
                  if (hasGesture) {
                    setState(() {
                      _center = position.center!;
                      _zoom = position.zoom!;
                    });
                  }
                },
                onLongPress: (tapPosition, point) {
                  _showEditDialog(null, point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: markers.map((marker) {
                    return Marker(
                      width: 80.0,
                      height: 80.0,
                      point: LatLng(marker.latitude, marker.longitude),
                      builder: (ctx) => GestureDetector(
                        onTap: () => _showMarkerDetails(marker),
                        child: Icon(
                            marker.unit == 'gas' 
                            ? fluent_system.FluentIcons.gas_pump_20_filled
                            : marker.unit == 'hotel'
                              ? fluent_system.FluentIcons.bed_20_filled
                              : fluent_system.FluentIcons.toolbox_20_filled,
                            color: marker.unit == 'gas' 
                              ? Colors.green 
                              : marker.unit == 'hotel' 
                                ? Colors.blue 
                                : Colors.red,
                          size: 30,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),),),
    );
  }

  void _showMarkerDetails(MarkerModel marker) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: Text(marker.title),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Опис: ${marker.description}'),
            Text('Широта: ${marker.latitude}'),
            Text('Довгота: ${marker.longitude}'),
          ],
        ),
        actions: [
          Button(
            child: const Text('Редагувати'),
            onPressed: () {
              Navigator.pop(context);
              _showEditDialog(marker, null);
            },
          ),
          Button(
            child: const Text('Видалити'),
            onPressed: () {
              _deleteMarker(marker.id);
              Navigator.pop(context);
            },
          ),
          Button(
            child: const Text('Закрити'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(MarkerModel? marker, LatLng? position) async {
    final titleController = TextEditingController(text: marker?.title ?? '');
    final descController = TextEditingController(text: marker?.description ?? '');
    final latController = TextEditingController(text: position?.latitude.toString() ?? marker?.latitude.toString() ?? '');
    final longController = TextEditingController(text: position?.longitude.toString() ?? marker?.longitude.toString() ?? '');
    String selectedUnit = marker?.unit ?? 'gas';

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => ContentDialog(
          title: Text(marker == null ? 'Додати маркер' : 'Змінити маркер'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InfoLabel(
                label: 'Назва',
                child: TextBox(
                  controller: titleController,
                  placeholder: 'Введіть назву',
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Опис',
                child: TextBox(
                  controller: descController,
                  placeholder: 'Введіть опис',
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Широта',
                child: TextBox(
                  controller: latController,
                  placeholder: 'Введіть широту',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Довгота',
                child: TextBox(
                  controller: longController,
                  placeholder: 'Введіть довготу',
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(height: 8),
              InfoLabel(
                label: 'Тип',
                child: ComboBox<String>(
                  value: selectedUnit,
                  items: const [
                    ComboBoxItem(value: 'gas', child: Text('АЗС')),
                    ComboBoxItem(value: 'hotel', child: Text('Готель')),
                    ComboBoxItem(value: 'service', child: Text('СТО')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          actions: [
            Button(
              child: const Text('Скасувати'),
              onPressed: () => Navigator.pop(context),
            ),
            Button(
              child: const Text('Зберегти'),
              onPressed: () {
                final newMarker = MarkerModel(
                  id: marker?.id ?? DateTime.now().toString(),
                  title: titleController.text,
                  description: descController.text,
                  latitude: double.parse(latController.text),
                  longitude: double.parse(longController.text),
                  unit: selectedUnit,
                );
                if (marker == null) {
                  _addMarker(newMarker);
                } else {
                  _updateMarker(newMarker);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}