import 'dart:convert';

import 'package:cyrel/api/auth.dart';
import 'package:cyrel/api/errors.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/api/token.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';

class Api {
  String baseUrl = "http://localhost:8080";

  bool _connected = false;

  final Client _httpClient = Client();

  late final Auth _auth;

  String get token => _auth.getToken()!;

  late final GroupResource group;
  late final GroupsResource groups;
  late final UserResource user;
  late final SecurityResource security;
  late final HomeworkResource homework;
  late final HomeworksResource homeworks;
  final Map<String, dynamic> _data = {};

  Api() {
    group = GroupResource(this, _httpClient, "$baseUrl/group");
    groups = GroupsResource(this, _httpClient, "$baseUrl/groups");
    user = UserResource(this, _httpClient, "$baseUrl/user");
    security = SecurityResource(this, _httpClient, "$baseUrl/security");
    _auth = Auth(security, _httpClient);
    homework = HomeworkResource(this, _httpClient, "$baseUrl/homework");
    homeworks = HomeworksResource(this, _httpClient, "$baseUrl/homeworks");
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
        .login(username, password);
  }

  bool isConnected() => _connected;

  static Api instance = Api();

  void handleError(Response response) {
    if (kDebugMode) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        print(
            "\x1B[32mSUCCESS\x1B[0m for ${response.request?.url} = {${response.statusCode} ; ${response.reasonPhrase}}");
      } else {
        print(
            "\x1B[31mERROR\x1B[0m for ${response.request?.url} = {${response.statusCode} ; ${response.reasonPhrase}}");
      }
    }
    switch (response.statusCode) {
      case 402: {
        throw UserNotRegistered();
      }
      case 400: {
        switch (response.body) {
          case "Homework is badly formatted": {
            throw HomeworkMalformed();
          }
          case "Unknown person type": {
            throw UnknownPersonType();
          }
          case "User is already registered": {
            throw AlreadyRegistered();
          }
          default: {
            throw Error();
          }
        }
      }
      case 403: {
        switch (response.body) {
          case "Unauthorized group target": {
            throw UnauthorizedGroupTarget();
          }
          default: {
            throw UserNotAllowed();
          }
        }
      }
      case 500: {
        throw Error();
      }
    }
  }

  addData(String key, dynamic data) {
    _data[key] = data;
  }

  K getData<K>(String key) {
    return _data[key] as K;
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

  Future<GroupEntity> getById(int id) async {
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return GroupEntity.fromJson(json);
  }

  Future<List<GroupEntity>> getChildren(int id) async {
    return getList<GroupEntity>(
        "$base/$id/children", (element) => GroupEntity.fromJson(element));
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

  Future<List<GroupEntity>> get() async {
    return getList<GroupEntity>(
        base, (element) => GroupEntity.fromJson(element));
  }

  Future<List<String>> getIds() async {
    return getList<String>("$base/ids", (element) => element);
  }

  Future<List<GroupEntity>> getParents() async {
    return getList<GroupEntity>(
        "$base/parents", (element) => GroupEntity.fromJson(element));
  }
}

class UserResource extends BaseResource {
  UserResource(super.api, super.httpClient, super.base);

  Future<List<UserEntity>> getAll() async {
    return getList<UserEntity>(base, (element) => UserEntity.fromJson(element));
  }

  Future<UserEntity> getById(String id) async {
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return UserEntity.fromJson(json);
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

class SecurityResource extends BaseResource {
  SecurityResource(super.api, super.httpClient, super.base);

  Future<Token> getToken(String username, String password) async {
    failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}));
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return Token.fromJson(json);
  }

  Future<Token> refreshToken(String refreshToken) async {
    failIfDisconnected();
    Response response = await _httpClient.put(Uri.parse(base),
        headers: {"Content-Type": "text/plain"},
        body: refreshToken);
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return Token.fromJson(json);
  }
}

class HomeworkResource extends BaseResource {
  HomeworkResource(super.api, super.httpClient, super.base);

  Future<HomeworkEntity> getById(String id) async {
    failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"), headers: {
      "Authorization": "Bearer ${_api.token}",
      "Content-Type": "application/json"
    });
    _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return HomeworkEntity.fromJson(json);
  }

  createHomework(HomeworkEntity homework) async {
    failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(homework));
    _api.handleError(response);
  }

  update(HomeworkEntity homework) async {
    // FIXME Don't pass all homework entity but only what changed
    failIfDisconnected();
    Response response = await _httpClient.put(Uri.parse("$base/${homework.id}"),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(homework));
    _api.handleError(response);
  }

  delete(HomeworkEntity homework) async {
    failIfDisconnected();
    Response response = await _httpClient
        .delete(Uri.parse("$base/${homework.id}"), headers: {
      "Authorization": "Bearer ${_api.token}",
      "Content-Type": "application/json"
    });
    _api.handleError(response);
  }
}

class HomeworksResource extends BaseResource {
  HomeworksResource(super.api, super.httpClient, super.base);

  Future<List<HomeworkEntity>> getAll() async {
    return getList<HomeworkEntity>(
        base, (element) => HomeworkEntity.fromJson(element));
  }
}
