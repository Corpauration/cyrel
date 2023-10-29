import 'package:cyrel/utils/platform.dart';
import 'package:cyrel/utils/version.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class CyrelHttpClient extends BaseClient {
  final Client _httpClient;
  String _agent = Platform.name;
  late final Future<void> init;

  CyrelHttpClient(this._httpClient) {
    init = Version.instance.init.then((_) {
      _agent = "${Platform.name} ${Version.instance.toString()}";
    });
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) {
    if (!kIsWeb) {
      request.headers["User-Agent"] = _agent;
    }
    return _httpClient.send(request);
  }
}
