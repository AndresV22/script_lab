import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' as http;

/// En web se usa fetch para poder consumir respuestas en streaming.
http.Client createHttpClient() => FetchClient(mode: RequestMode.cors);
