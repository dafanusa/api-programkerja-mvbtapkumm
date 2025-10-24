import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf/shelf_io.dart';
import '../program_data.dart'; // ubah jadi relatif ke folder root proyek kamu

// Fungsi menentukan status dari rentang tanggal
String getStatusFromDate(String dateRange) {
  final now = DateTime.now();
  try {
    final parts = dateRange.split(' s.d. ');
    final startDate = DateTime.parse(parts.first.trim());
    final endDate =
        (parts.length > 1) ? DateTime.parse(parts.last.trim()) : startDate;

    if (now.isBefore(startDate)) return "Akan Datang";
    if (now.isAfter(endDate)) return "Selesai";
    return "Sedang Berlangsung";
  } catch (_) {
    return "Tidak Diketahui";
  }
}

// Handler endpoint /programs
Response _programHandler(Request request) {
  final enriched = programList.map((p) {
    final status = getStatusFromDate(p['date']);
    return {
      ...p,
      'status': status,
      'is_active': status == "Sedang Berlangsung",
    };
  }).toList();

  return Response.ok(
    jsonEncode(enriched),
    headers: {
      'content-type': 'application/json',
      'Access-Control-Allow-Origin': '*',
    },
  );
}

// Router utama
final _router = Router()..get('/programs', _programHandler);

// 🧩 Handler global untuk Vercel
final handler = Pipeline()
    .addMiddleware(corsHeaders())
    .addMiddleware(logRequests())
    .addHandler(_router);

// Fungsi main untuk run lokal
Future<void> main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final server = await serve(handler, InternetAddress.anyIPv4, port);
  print('✅ Server API berjalan di port ${server.port}');
}
