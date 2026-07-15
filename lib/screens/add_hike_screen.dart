import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';

/// AddHikeScreen - man hinh nhap chi tiet 1 hike moi
/// Tuong tu AddHikeActivity ben Java, nhung UI + logic trong 1 file.
///
/// StatefulWidget vi form co state thay doi (chon date, chon difficulty...)
class AddHikeScreen extends StatefulWidget {
  const AddHikeScreen({super.key});

  @override
  State<AddHikeScreen> createState() => _AddHikeScreenState();
}

class _AddHikeScreenState extends State<AddHikeScreen> {
  // ==================== FORM KEY + CONTROLLERS ====================

  // Key de validate form
  final _formKey = GlobalKey<FormState>();

  // Controllers - giu du lieu tu cac TextField (giong EditText.getText() ben Android)
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _lengthController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weatherController = TextEditingController();
  final _elevationController = TextEditingController();

  // ==================== STATE VARIABLES ====================

  DateTime? _selectedDate;              // Date user chon
  bool? _parking;                       // true=Yes, false=No, null=chua chon
  String _difficulty = 'Easy';          // Difficulty mac dinh
  final _dateFormat = DateFormat('yyyy-MM-dd');


  // ==================== DISPOSE ====================

  /// Giai phong bo nho khi widget bi huy
  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _lengthController.dispose();
    _descriptionController.dispose();
    _weatherController.dispose();
    _elevationController.dispose();
    super.dispose();
  }


  // ==================== DATE PICKER ====================

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {   // setState = trigger rebuild UI voi data moi
        _selectedDate = picked;
      });
    }
  }


  // ==================== VALIDATE + CONFIRM ====================

  void _validateAndConfirm() {
    // Validate form (chay tat ca validator cua cac TextFormField)
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fix the errors above');
      return;
    }

    // Check date
    if (_selectedDate == null) {
      _showSnackBar('Please select a date');
      return;
    }

    // Check parking
    if (_parking == null) {
      _showSnackBar('Please select parking availability');
      return;
    }

    // Tat ca OK -> hien confirmation dialog
    _showConfirmationDialog();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }


  // ==================== CONFIRMATION DIALOG ====================

  void _showConfirmationDialog() {
    final name = _nameController.text.trim();
    final location = _locationController.text.trim();
    final length = double.parse(_lengthController.text.trim());
    final description = _descriptionController.text.trim();
    final weather = _weatherController.text.trim();
    final elevationStr = _elevationController.text.trim();
    final elevation = elevationStr.isEmpty ? null : int.tryParse(elevationStr);
    final dateStr = _dateFormat.format(_selectedDate!);

    // Build message
    final message = StringBuffer();
    message.writeln('Name: $name');
    message.writeln('Location: $location');
    message.writeln('Date: $dateStr');
    message.writeln('Parking: ${_parking! ? "Yes" : "No"}');
    message.writeln('Length: $length km');
    message.writeln('Difficulty: $_difficulty');
    if (description.isNotEmpty) message.writeln('Description: $description');
    if (weather.isNotEmpty) message.writeln('Weather: $weather');
    if (elevation != null) message.writeln('Elevation: $elevation m');

    // Tao Hike object
    final hike = Hike(
      name: name,
      location: location,
      date: dateStr,
      parking: _parking!,
      length: length,
      difficulty: _difficulty,
      description: description.isEmpty ? null : description,
      weather: weather.isEmpty ? null : weather,
      elevationGain: elevation,
    );

    // Hien AlertDialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Hike Details'),
        content: SingleChildScrollView(child: Text(message.toString())),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);           // dong dialog
              _saveHike(hike);                  // luu hike
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  // ==================== SAVE HIKE (tam thoi in log) ====================

  Future<void> _saveHike(Hike hike) async {
    try {
      // Luu vao SQLite that
      final id = await DatabaseHelper.instance.insertHike(hike);
      _showSnackBar('Hike saved successfully! ID: $id');
      _clearForm();
    } catch (e) {
      _showSnackBar('Failed to save hike: $e');
    }
  }

  void _clearForm() {
    _nameController.clear();
    _locationController.clear();
    _lengthController.clear();
    _descriptionController.clear();
    _weatherController.clear();
    _elevationController.clear();
    setState(() {
      _selectedDate = null;
      _parking = null;
      _difficulty = 'Easy';
    });
  }


  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Hike'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(              // = ScrollView ben Android
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== NAME (Required) ==========
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Hike Name *',
                  hintText: 'e.g. Snowdon',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ========== LOCATION (Required) ==========
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  hintText: 'e.g. Wales, UK',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ========== DATE (Required) ==========
              const Text('Date *', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : _dateFormat.format(_selectedDate!),
                ),
              ),
              const SizedBox(height: 16),

              // ========== PARKING (Required) ==========
              const Text('Parking Available? *', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('Yes'),
                      value: true,
                      groupValue: _parking,
                      onChanged: (value) => setState(() => _parking = value),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<bool>(
                      title: const Text('No'),
                      value: false,
                      groupValue: _parking,
                      onChanged: (value) => setState(() => _parking = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ========== LENGTH (Required) ==========
              TextFormField(
                controller: _lengthController,
                decoration: const InputDecoration(
                  labelText: 'Length (km) *',
                  hintText: 'e.g. 15.5',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Length is required';
                  }
                  final parsed = double.tryParse(value.trim());
                  if (parsed == null) return 'Invalid number';
                  if (parsed <= 0) return 'Length must be > 0';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ========== DIFFICULTY (Required) - Dropdown ==========
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: const InputDecoration(
                  labelText: 'Difficulty Level *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                  DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'Hard', child: Text('Hard')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _difficulty = value);
                },
              ),
              const SizedBox(height: 16),

              // ========== DESCRIPTION (Optional) ==========
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Optional description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // ========== EXTRA FIELDS ==========
              const Divider(),
              const Center(
                child: Text('── Additional Fields ──',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),

              // Weather
              TextFormField(
                controller: _weatherController,
                decoration: const InputDecoration(
                  labelText: 'Weather Forecast',
                  hintText: 'e.g. Sunny, 20 C',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Elevation Gain
              TextFormField(
                controller: _elevationController,
                decoration: const InputDecoration(
                  labelText: 'Elevation Gain (meters)',
                  hintText: 'e.g. 1085',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // ========== BUTTONS ==========
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _validateAndConfirm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}