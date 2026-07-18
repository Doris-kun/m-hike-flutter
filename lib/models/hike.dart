/// Class Hike - dai dien cho 1 chuyen hike
/// Tuong tu class Hike.java ben Android native
class Hike {
  int? id;
  String name;
  String location;
  String date;
  bool parking;
  double length;
  String difficulty;
  String? description;
  String? weather;
  int? elevationGain;

  Hike({
    this.id,
    required this.name,
    required this.location,
    required this.date,
    required this.parking,
    required this.length,
    required this.difficulty,
    this.description,
    this.weather,
    this.elevationGain,
  });

  /// Chuyen Hike thanh Map de luu vao SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'date': date,
      'parking': parking ? 1 : 0,
      'length': length,
      'difficulty': difficulty,
      'description': description,
      'weather': weather,
      'elevation_gain': elevationGain,
    };
  }

  /// Tao Hike tu Map khi doc du lieu tu SQLite
  factory Hike.fromMap(Map<String, dynamic> map) {
    return Hike(
      id: map['id'] as int?,
      name: map['name'] as String,
      location: map['location'] as String,
      date: map['date'] as String,
      parking: (map['parking'] as int) == 1,
      length: (map['length'] as num).toDouble(),
      difficulty: map['difficulty'] as String,
      description: map['description'] as String?,
      weather: map['weather'] as String?,
      elevationGain: map['elevation_gain'] as int?,
    );
  }

  @override
  String toString() {
    return 'Hike{id: $id, name: $name, location: $location, date: $date}';
  }
}