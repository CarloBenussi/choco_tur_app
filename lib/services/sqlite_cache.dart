import 'package:choco_tur/models/choco_tur_tour.dart';
import 'package:choco_tur/utils/logger.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqliteCache {
  static const _toursTableName = "tours";
  static const _stopsTableName = "stops";
  static const _tastingsTableName = "tastings";

  static const String _toursTableSchema =
      "id TEXT PRIMARY KEY, title TEXT, costEuros REAL, lengthKm REAL, avgDuration TEXT, descriptions TEXT, stopIds TEXT, stopInfos TEXT, tastingInfos TEXT, imageId TEXT";
  static const String _stopsTableSchema =
      "id TEXT PRIMARY KEY, titles TEXT, descriptions TEXT, latitude REAL, longitude REAL, imageId TEXT, audioId TEXT";
  static const String _tastingsTableSchema =
      "id INTEGER PRIMARY KEY, titles TEXT, descriptions TEXT, mainImageUrl TEXT";

  static Future<Database>? _db;
  static SqliteCache? _cache;

  static Future<void> init() async {
    String path = join(
      await getDatabasesPath(),
      'choco_tur_cache.db',
    );

    // MOCK DATA (not supported on web).
    bool exists = await databaseExists(path);
    // if (!exists && !kIsWeb) {
    //   // Copy from asset.
    //   ByteData data = await rootBundle.load(url.join("assets/mock_db", "tour_saturday.db"));
    //   List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    //   // Write and flush the bytes written.
    //   await File(path).writeAsBytes(bytes, flush: true);

    //   exists = true;
    // }

    _db = openDatabase(
      path,
      onCreate: (db, version) async {
        if (!exists) {
          db.execute(
            'CREATE TABLE $_toursTableName($_toursTableSchema)',
          );
          db.execute(
            'CREATE TABLE $_stopsTableName($_stopsTableSchema)',
          );
          db.execute(
            'CREATE TABLE $_tastingsTableName($_tastingsTableSchema)',
          );
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        LoggerInstance.logger.w("Implement DB upgrade");
      },
      version: 1,
    );
  }

  static Future<SqliteCache> getInstance() async {
    return (_cache != null) ? _cache! : SqliteCache();
  }

  Future<List<ChocoTurTour>?> getTours() async {
    final database = await _db!;

    List<Map<String, dynamic>> tourMaps = await database.query(
      _toursTableName,
      columns: [
        'id',
        'title',
        'costEuros',
        'lengthKm',
        'avgDuration',
        'descriptions',
        'stopIds',
        'stopInfos',
        'tastingInfos',
        'imageId',
      ],
    );

    List<ChocoTurTour> tours = [];
    for (var tourMap in tourMaps) {
      tours.add(ChocoTurTour.fromCacheMap(tourMap));
    }

    return tours;
  }

  Future<void> saveTours(List<ChocoTurTour> tours) async {
    final database = await _db!;

    for (var tour in tours) {
      Map<String, dynamic> tourInfoMap = tour.toCacheMap();
      if (await database.update(_toursTableName, tourInfoMap) > 0) {
        LoggerInstance.logger.d('Tour ${tourInfoMap["id"]} was updated.');
      } else {
        LoggerInstance.logger.d('Tour ${tourInfoMap["id"]} did not exist yet on cache, inserting it.');
        await database.insert(_toursTableName, tourInfoMap);
      }
    }
  }

  Future<ChocoTurTour?> getTourFromId(String tourId) async {
    final database = await _db!;

    List<Map<String, dynamic>> tourMaps = await database.query(
      _toursTableName,
      columns: [
        'id',
        'title',
        'costEuros',
        'lengthKm',
        'avgDuration',
        'descriptions',
        'stopIds',
        'stopInfos',
        'tastingInfos',
        'imageId',
      ],
      where: "id = ?",
      whereArgs: [tourId],
    );

    if (tourMaps.isEmpty) {
      LoggerInstance.logger.e('Got no data for tour $tourId');
      return null;
    }

    if (tourMaps.length > 1) {
      LoggerInstance.logger.e('Got multiple tours with id $tourId');
      return null;
    }

    return ChocoTurTour.fromCacheMap(tourMaps[0]);
  }

  Future<List<ChocoTurStop>?> getTourStops(String tourId) async {
    final database = await _db!;

    ChocoTurTour? tour = await getTourFromId(tourId);
    if (tour == null) {
      LoggerInstance.logger.e('Got no data for tour $tourId');
      return null;
    }

    List<ChocoTurStop> stops = [];
    for (var stopId in tour.stopIds) {
      List<Map<String, dynamic>> stopMaps = await database.query(
        _stopsTableName,
        columns: [
          'id',
          'titles',
          'descriptions',
          'latitude',
          'longitude',
          'imageId',
          'audioId',
        ],
        where: "id = ?",
        whereArgs: [stopId],
      );

      if (stopMaps.isEmpty) {
        LoggerInstance.logger.i('No stop found on cache for tour with ID $stopId');
        return null;
      } else if (stopMaps.length > 1) {
        throw Exception('Multiple stops found on cache with ID $stopId');
      } else {
        stops.add(ChocoTurStop.fromCacheMap(stopMaps[0]));
      }
    }

    return stops;
  }

  Future<void> saveTourStops(List<ChocoTurStop> tourStops) async {
    final database = await _db!;

    for (var tourStop in tourStops) {
      Map<String, dynamic> tourStopMap = tourStop.toCacheMap();
      if (await database.update(_stopsTableName, tourStopMap, where: "id = ?", whereArgs: [tourStopMap["id"]]) > 0) {
        LoggerInstance.logger.d('Stop ${tourStopMap["id"]} was updated.');
      } else {
        LoggerInstance.logger.d('Stop ${tourStopMap["id"]} did not exist yet on cache, inserting it.');
        await database.insert(_stopsTableName, tourStopMap);
      }
    }
  }
}
