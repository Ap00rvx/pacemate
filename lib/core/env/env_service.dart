import 'package:flutter_dotenv/flutter_dotenv.dart';
class EnvService{ 
  static Future<void> init() async {
    await dotenv.load(fileName: ".env").then((_)=>{
      print("Env Loaded")
    });
  }
  String get androidClientId => dotenv.env['ANDROID_CLIENT_ID'] ?? "";
  String get webClientId => dotenv.env['WEB_CLIENT_ID'] ?? "";
  String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? "";
  String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? "";
}