import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import '../program_data.dart';

// Fungsi untuk menentukan status berdasarkan tanggal
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

// Handler utama untuk /programs
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
    headers: {'content-type': 'application/json', 'Access-Control-Allow-Origin': '*'},
  );
}

// Router
final _router = Router()
  ..get('/', (Request req) => Response.ok('✅ API Program Kerja aktif! Coba /programs'))
  ..get('/programs', _programHandler);

// Pipeline Vercel handler (tidak pakai main)
final handler = Pipeline()
    .addMiddleware(corsHeaders())
    .addMiddleware(logRequests())
    .addHandler(_router);
