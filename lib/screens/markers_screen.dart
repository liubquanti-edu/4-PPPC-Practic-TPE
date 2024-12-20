import 'package:fluent_ui/fluent_ui.dart';
import 'package:latlong2/latlong.dart';
import '../models/marker_model.dart';
import '../services/firebase_service.dart';

class MarkersScreen extends StatefulWidget {
  const MarkersScreen({super.key});

  @override
  State<MarkersScreen> createState() => _MarkersScreenState();
}

class _MarkersScreenState extends State<MarkersScreen> {
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

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Менеджер маркерів'),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: const Text('Додати маркер'),
              onPressed: () => _showEditDialog(null, null),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(child: ProgressRing())
            : _buildMarkerList(),
      ),
    );
  }

  Widget _buildMarkerList() {
    return ListView.builder(
      itemCount: markers.length,
      itemBuilder: (context, index) {
        final marker = markers[index];
        return Card(
          child: ListTile(
            leading: Icon(
              marker.unit == 'gas'
                  ? FluentIcons.car
                  : marker.unit == 'hotel'
                      ? FluentIcons.hotel
                      : FluentIcons.repair,
            ),
            title: Text(marker.title),
            subtitle: Text(marker.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Button(
                  child: const Icon(FluentIcons.edit),
                  onPressed: () => _showEditDialog(marker, null),
                ),
                const SizedBox(width: 8),
                Button(
                  child: const Icon(FluentIcons.delete),
                  onPressed: () => _deleteMarker(marker.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showEditDialog(MarkerModel? marker, LatLng? position) async {
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

  Future<void> _addMarker(MarkerModel marker) async {
    await _firebaseService.addMarker(marker);
    _loadMarkers();
  }

  Future<void> _updateMarker(MarkerModel marker) async {
    await _firebaseService.updateMarker(marker);
    _loadMarkers();
  }

  Future<void> _deleteMarker(String id) async {
    await _firebaseService.deleteMarker(id);
    _loadMarkers();
  }
}