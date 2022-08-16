import 'dart:convert';

import 'package:cyrel/api/auth.dart';
import 'package:cyrel/api/group.dart';
import 'package:cyrel/api/user.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Api {
  String baseUrl = "http://localhost:8080";

  bool _connected = false;

  final Client _httpClient = Client();

  late final Auth _auth;
  late String token;

  late final GroupResource group;
  late final GroupsResource groups;
  late final UserResource user;

  Api() {
    _auth = Auth(_httpClient);
    group = GroupResource(this, _httpClient, "$baseUrl/group");
    groups = GroupsResource(this, _httpClient, "$baseUrl/groups");
    user = UserResource(this, _httpClient, "$baseUrl/user");
  }

  Future<bool> connect() async {
    if (_connected) return true;
    try {
      Response response = await _httpClient.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        _connected = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Connection with the backend failed miserably...");
        print(e);
      }
    }
    return _connected;
  }

  login(String username, String password) async {
    return _auth
        .login(username, password)
        .then((_) => token = _auth.getToken()!);
  }

  bool isConnected() => _connected;

  static Api instance = Api();

  void handleError(Response response) {
    if (kDebugMode) {
      print(
          "ERROR for ${response.request?.url} = {${response.statusCode} ; ${response.reasonPhrase}}");
    }
  }
}

class NotConnectedError extends Error {
  @override
  String toString() => "The frontend is not connected to the backend";
}

class BaseResource {
  late final Client _httpClient;
  String base = "";
  late final Api _api;

  BaseResource(this._api, this._httpClient, this.base);

  failIfDisconnected() async {
    if (!_api.isConnected() && !await _api.connect()) throw NotConnectedError();
  }

  Future<String> ping() async {
    Response response = await _httpClient.get(Uri.parse("$base/ping"));
    _api.handleError(response);
    return response.body;
  }

  Future<List<T>> getList<T>(
      String path, T Function(dynamic) jsonParser) async {
    await failIfDisconnected();

    Response response = await _httpClient.get(Uri.parse(path),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<T> list =
        List.generate(json.length, (index) => jsonParser(json[index]));
    return list;
  }
}

class GroupResource extends BaseResource {
  GroupResource(super.api, super.httpClient, super.base);

  Future<Group> getById(int id) async {
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return Group.fromJson(json);
  }

  Future<List<Group>> getChildren(int id) async {
    return getList<Group>(
        "$base/$id/children", (element) => Group.fromJson(element));
  }

  Future<bool> join(int id) async {
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id/join"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    return response.body == "true";
  }
}

class GroupsResource extends BaseResource {
  GroupsResource(super.api, super.httpClient, super.base);

  Future<List<Group>> get() async {
    return getList<Group>(base, (element) => Group.fromJson(element));
  }

  Future<List<String>> getIds() async {
    return getList<String>("$base/ids", (element) => element);
  }

  Future<List<Group>> getParents() async {
    return getList<Group>(
        "$base/parents", (element) => Group.fromJson(element));
  }
}

class UserResource extends BaseResource {
  UserResource(super.api, super.httpClient, super.base);

  Future<List<User>> getAll() async {
    return getList<User>(base, (element) => User.fromJson(element));
  }

  Future<User> getById(String id) async {
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return User.fromJson(json);
  }

  Future<bool> isRegistered() async {
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/isRegistered"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    return response.body == "true";
  }

  register(DateTime? birthday) async {
    await failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"birthday": birthday}));
    _api.handleError(response);
  }
}
