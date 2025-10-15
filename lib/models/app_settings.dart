import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 3)
class AppSettings extends HiveObject {
  @HiveField(0)
  bool enableCommuteTracking;

  AppSettings({this.enableCommuteTracking = false});
}
