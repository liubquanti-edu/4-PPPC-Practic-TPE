import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/marker_model.dart';
import '../services/firebase_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<MarkerModel> markers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMarkers();
  }

  Future<void> _loadMarkers() async {
    setState(() => isLoading = true);
    final loadedMarkers = await _firebaseService.getMarkers();
    setState(() {
      markers = loadedMarkers;
      isLoading = false;
    });
  }

  void _addMarker(MarkerModel marker) async {
    await _firebaseService.addMarker(marker);
    _loadMarkers();
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(title: const Text('Map')),
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: isLoading
          ? const Center(child: ProgressRing())
          : FlutterMap(
              options: MapOptions(
                center: LatLng(50.4501, 30.5234), // Center on Kyiv, Ukraine
                zoom: 10.0,
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
                      builder: (ctx) => Icon(
                        FluentIcons.location,
                        color: marker.unit == 'gas' 
                          ? const Color.fromARGB(255, 0, 255, 0) // Green for gas stations
                          : marker.unit == 'hotel' 
                            ? const Color.fromARGB(255, 0, 0, 255) // Blue for hotels
                            : const Color.fromARGB(255, 255, 255, 0), // Yellow for service
                        size: 40,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),),),
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

  Future<void> _updateMarker(MarkerModel marker) async {
    await _firebaseService.updateMarker(marker);
    _loadMarkers();
  }
}