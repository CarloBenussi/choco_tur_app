import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteCache {
  static const _toursTableName = "tours";
  static const _tourStopsTableName = "tourStops";
  static const _chocolatesTableName = "chocolates";
  static const _tourStopsRelationsTableName = "tourStopsRelations";
  static const _tourStopChocolatesRelationsTableName =
      "tourStopChocolatesRelations";

  static const String _toursTableSchema =
      "id INTEGER PRIMARY KEY, name TEXT, costEuro REAL, lengthKm REAL, avgDurationHour TEXT, description TEXT, mainImageUrl TEXT";
  static const String _tourStopsTableSchema =
      "id INTEGER PRIMARY KEY, name TEXT, description TEXT, latitude REAL, longitude REAL, mainImageUrl TEXT";
  static const String _chocolatesTableSchema =
      "id INTEGER PRIMARY KEY, name TEXT, description TEXT, mainImageUrl TEXT";
  static const String _tourStopsRelationsSchema =
      "id INTEGER PRIMARY KEY, tourId INTEGER, stopId INTEGER, stopPosition INTEGER";
  static const String _stopChocolatesRelationsSchema =
      "id INTEGER PRIMARY KEY, stopId INTEGER, chocolateId INTEGER";

  static Future<Database>? _db;
  static SqliteCache? _cache;

  static void init() async {
    _db = openDatabase(
      join(
        await getDatabasesPath(),
        'choco_tur_cache.db',
      ),
      onCreate: (db, version) {
        db.execute(
          'CREATE TABLE $_toursTableName($_toursTableSchema)',
        );
        db.execute(
          'CREATE TABLE $_tourStopsTableName($_tourStopsTableSchema)',
        );
        db.execute(
          'CREATE TABLE $_chocolatesTableName($_chocolatesTableSchema)',
        );
        db.execute(
          'CREATE TABLE $_tourStopsRelationsTableName($_tourStopsRelationsSchema)',
        );
        db.execute(
          'CREATE TABLE $_tourStopChocolatesRelationsTableName($_stopChocolatesRelationsSchema)',
        );

        // TODO: Insert mock data.
      },
      version: 1,
    );
  }

  static Future<SqliteCache> getInstance() async {
    return (_cache != null) ? _cache! : SqliteCache();
  }

  Future<List<ChocoTurTour>> getAllTours() async {
    var database = await _db!;

    List<Map<String, dynamic>> tourMaps = await database.query(
      _toursTableName,
      columns: [
        'id',
        'name',
        'costEuro',
        'lengthKm',
        'avgDurationHour',
        'description',
        'mainImageUrl'
      ],
    );

    List<ChocoTurTour> tours = [];
    for (var i = 0; i < tourMaps.length; ++i) {
      tours.add(ChocoTurTour.fromMap(tourMaps[i]));
    }

    return tours;
  }
}
