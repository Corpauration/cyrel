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
    await _auth.login("michel@cy-tech.fr", "michel");
    token = _auth.getToken()!;
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

  bool isConnected() => _connected;

  static Api instance = Api();

  void handleError(Response response) {}
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
      String path, T Function(int, List<dynamic>) jsonParser) async {
    await failIfDisconnected();

    Response response = await _httpClient.get(Uri.parse(path),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<T> list =
        List.generate(json.length, (index) => jsonParser(index, json));
    return list;
  }
}

class GroupResource extends BaseResource {
  GroupResource(super.api, super.httpClient, super.base);

  Future<Group> getById(int id) async {
    if (!_api.isConnected() && !await _api.connect()) throw NotConnectedError();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return Group.fromJson(json);
  }

  Future<List<Group>> getChildren(int id) async {
    return getList<Group>(
        "$base/$id/children", (index, json) => Group.fromJson(json[index]));
  }

  Future<bool> join(int id) async {
    if (!_api.isConnected() && !await _api.connect()) throw NotConnectedError();
    Response response = await _httpClient.get(Uri.parse("$base/$id/join"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    return response.body == "true";
  }
}

class GroupsResource extends BaseResource {
  GroupsResource(super.api, super.httpClient, super.base);

  Future<List<Group>> get() async {
    if (!_api.isConnected() && !await _api.connect()) throw NotConnectedError();
    Response response = await _httpClient.get(Uri.parse(base),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<Group> groups =
        List.generate(json.length, (index) => Group.fromJson(json[index]));
    return groups;
  }

  Future<List<String>> getIds() async {
    if (!_api.isConnected() && !await _api.connect()) throw NotConnectedError();
    Response response = await _httpClient.get(Uri.parse("$base/ids"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<String> ids = List.generate(json.length, (index) => json[index]);
    return ids;
  }

  Future<List<Group>> getParents() async {
    if (!_api.isConnected() && !await _api.connect()) throw NotConnectedError();
    Response response = await _httpClient.get(Uri.parse("$base/parents"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<Group> groups =
        List.generate(json.length, (index) => Group.fromJson(json[index]));
    return groups;
  }
}

class UserResource extends BaseResource {
  UserResource(super.api, super.httpClient, super.base);

  Future<List<User>> getAll() async {
    if (!_api.isConnected() && !await _api.connect()) throw NotConnectedError();
    Response response = await _httpClient.get(Uri.parse(base),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<User> users =
        List.generate(json.length, (index) => User.fromJson(json[index]));
    return users;
  }
}
