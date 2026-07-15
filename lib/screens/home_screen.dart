import 'package:flutter/material.dart';
import '../models/hike.dart';
import '../database/database_helper.dart';
import 'add_hike_screen.dart';

/// HomeScreen - man hinh chinh hien danh sach hike da luu
/// Tuong tu MainActivity ben Android native.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Hike> _hikes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHikes();
  }

  /// Load tat ca hike tu database
  Future<void> _loadHikes() async {
    setState(() => _isLoading = true);
    final hikes = await DatabaseHelper.instance.getAllHikes();
    setState(() {
      _hikes = hikes;
      _isLoading = false;
    });
  }

  /// Mo man Add Hike, sau khi quay lai thi reload list
  Future<void> _openAddHike() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddHikeScreen()),
    );
    // Sau khi quay lai tu AddHikeScreen -> reload list
    _loadHikes();
  }

  /// Xoa 1 hike (co confirmation)
  Future<void> _deleteHike(Hike hike) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Hike'),
        content: Text('Delete "${hike.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteHike(hike.id!);
      _loadHikes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hike deleted')),
        );
      }
    }
  }

  /// Reset database - xoa het
  Future<void> _resetDatabase() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Database'),
        content: const Text('Delete ALL hikes? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DatabaseHelper.instance.deleteAllHikes();
      _loadHikes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M-Hike'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // Menu reset database
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'reset') _resetDatabase();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'reset',
                child: Text('Reset Database'),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hikes.isEmpty
          ? const Center(
        child: Text(
          'No hikes yet.\nTap + to add your first hike!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: _hikes.length,
        itemBuilder: (context, index) {
          final hike = _hikes[index];
          return Card(
            margin: const EdgeInsets.symmetric(
                horizontal: 8, vertical: 4),
            child: ListTile(
              title: Text(
                hike.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location: ${hike.location}'),
                  Text('Date: ${hike.date}'),
                  Text('${hike.difficulty}  •  ${hike.length} km'),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteHike(hike),
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddHike,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        child: const Icon(Icons.add),
      ),
    );
  }
}