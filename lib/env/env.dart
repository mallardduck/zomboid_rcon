import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'DB_SECRET')
  static const dbSecret = _Env.dbSecret;
}