import 'dart:convert';

import 'package:cyrel/api/auth.dart';
import 'package:cyrel/api/auth_web.dart';
import 'package:cyrel/api/base_entity.dart';
import 'package:cyrel/api/course_entity.dart';
import 'package:cyrel/api/errors.dart';
import 'package:cyrel/api/group_entity.dart';
import 'package:cyrel/api/homework_entity.dart';
import 'package:cyrel/api/preference_entity.dart';
import 'package:cyrel/api/room_entity.dart';
import 'package:cyrel/api/token.dart';
import 'package:cyrel/api/user_entity.dart';
import 'package:cyrel/cache/cache.dart';
import 'package:cyrel/cache/fs/fs.dart';
import 'package:cyrel/cache/fs/fs_io.dart';
import 'package:cyrel/cache/fs/fs_ram.dart';
import 'package:cyrel/cache/fs/fs_web.dart';
import 'package:cyrel/constants.dart';
import 'package:cyrel/ui/rooms.dart';
import 'package:cyrel/ui/theme.dart';
import 'package:cyrel/utils/date.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:http/http.dart';

class Api {
  String baseUrl = apiUrl;

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
  late final ScheduleResource schedule;
  late final ThemeResource theme;
  late final ThemesResource themes;
  late final PreferenceResource preference;
  late final RoomResource room;
  late final RoomsResource rooms;
  final Map<String, dynamic> _data = {};
  Function(bool)? onConnectionChanged;
  Function()? onAuthExpired;

  late final Future<void> _initFuture;

  final CacheManager _cache = CacheManager("api_cache");

  Api() {
    group = GroupResource(this, _httpClient, "$baseUrl/group");
    groups = GroupsResource(this, _httpClient, "$baseUrl/groups");
    user = UserResource(this, _httpClient, "$baseUrl/user");
    security = SecurityResource(this, _httpClient, "$baseUrl/security");
    _auth = Auth(security, _httpClient);
    homework = HomeworkResource(this, _httpClient, "$baseUrl/homework");
    homeworks = HomeworksResource(this, _httpClient, "$baseUrl/homeworks");
    schedule = ScheduleResource(this, _httpClient, "$baseUrl/schedule");
    theme = ThemeResource(this, _httpClient, "$baseUrl/theme");
    themes = ThemesResource(this, _httpClient, "$baseUrl/themes");
    preference = PreferenceResource(this, _httpClient, "$baseUrl/preference");
    room = RoomResource(this, _httpClient, "$baseUrl/room");
    rooms = RoomsResource(this, _httpClient, "$baseUrl/rooms");

    _initFuture =
        _cache.mount(RamFileSystem(), FileSystemPriority.both).then((_) {
      if (kIsWeb) {
        return _cache.syncThenMount(WebFileSystem(), FileSystemPriority.both);
      } else {
        return _cache.syncThenMount(IOFileSystem(), FileSystemPriority.write);
      }
    });
  }

  Future<void> awaitInitFutures() async {
    await _auth.initFuture;
    await _initFuture;
  }

  Future<bool> connect() async {
    if (_connected) return true;
    try {
      Response response =
          await _httpClient.get(Uri.parse("$baseUrl/user/ping"));
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

  login(BuildContext context) async {
    return _auth.login(context);
  }

  _resumeLogin() async {
    return await _auth.resumeLogin();
  }

  Future<bool> isTokenCached() async {
    await _resumeLogin();
    return await _auth.isTokenCached();
  }

  bool isConnected() => _connected;

  static Api instance = Api();

  Future<void> handleError(Response response) async {
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
      case 402:
        {
          throw UserNotRegistered();
        }
      case 400:
        {
          switch (response.body) {
            case "Homework is badly formatted":
              {
                throw HomeworkMalformed();
              }
            case "Unknown person type":
              {
                throw UnknownPersonType();
              }
            case "User is already registered":
              {
                throw AlreadyRegistered();
              }
            default:
              {
                throw Error();
              }
          }
        }
      case 403:
        {
          switch (response.body) {
            case "Unauthorized group target":
              {
                throw UnauthorizedGroupTarget();
              }
            case "Student id not authorized":
              {
                throw UnknownStudentId();
              }
            default:
              {
                throw UserNotAllowed();
              }
          }
        }
      case 500:
        {
          throw Error();
        }
      case 401:
        {
          await clearApiCache()
              .then((_) => clearAuthCache())
              .then((_) => onAuthExpired != null ? onAuthExpired!() : null);
        }
    }
  }

  bool isOffline = false;

  _checkIfOnline() async {
    try {
      await Api.instance.user.ping();
      if (isOffline) {
        isOffline = false;
        if (onConnectionChanged != null) {
          onConnectionChanged!(!isOffline);
        }
      }
    } catch (e) {
      if (!isOffline) {
        isOffline = true;
        if (onConnectionChanged != null) {
          onConnectionChanged!(!isOffline);
        }
      }
    }
    await Future.delayed(const Duration(minutes: 1))
        .then((value) => _checkIfOnline());
    // _checkIfOnline();
  }

  startLoop() {
    _checkIfOnline();
  }

  addData(String key, dynamic data) {
    _data[key] = data;
  }

  K getData<K>(String key) {
    return _data[key] as K;
  }

  Future<bool> isCached(String name) async {
    return !await _cache.isExpired(name) || isOffline;
  }

  Future<K?> getCached<K extends BaseEntity>(String name) async {
    return await _cache.get<K>(name, evenIfExpired: isOffline);
  }

  Future<void> removeCached(String name) async {
    await _cache.invalidate(name);
  }

  Future<void> cache<K extends BaseEntity>(String name, K data,
      {Duration? duration}) async {
    await _cache.save<K>(name, data,
        expireAt: duration != null ? DateTime.now().add(duration) : null);
  }

  Future<void> clearApiCache() async {
    await _cache.deleteCache();
  }

  Future<void> clearAuthCache() async {
    await _auth.clearAuthCache();
  }

  Future<void> logout() async {
    await clearApiCache();
    await _auth.logout();
    await clearAuthCache();
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
    Response response = await _httpClient
        .get(Uri.parse("$base/ping"))
        .timeout(const Duration(seconds: 10));
    await _api.handleError(response);
    return response.body;
  }

  Future<List<T>> getList<T>(
      String path, T Function(dynamic) jsonParser) async {
    await failIfDisconnected();

    Response response = await _httpClient.get(Uri.parse(path),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<T> list =
        List.generate(json.length, (index) => jsonParser(json[index]));
    return list;
  }

  MagicList<T> transformToMagicList<T extends BaseEntity>(List<T> list) {
    MagicList<T> magic = MagicList();
    magic.addAll(list);
    return magic;
  }
}

class GroupResource extends BaseResource {
  GroupResource(super.api, super.httpClient, super.base);

  Future<GroupEntity> getById(int id) async {
    String c = "group_getById_$id";
    if (await _api.isCached(c)) {
      return await _api.getCached<GroupEntity>(c) as GroupEntity;
    }
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    GroupEntity group = GroupEntity.fromJson(json);
    await _api.cache<GroupEntity>(
        c, group, duration: const Duration(hours: 12));
    return group;
  }

  Future<List<GroupEntity>> getChildren(int id) async {
    String c = "group_getChildren_$id";
    if (await _api.isCached(c)) {
      return await _api.getCached<MagicList<GroupEntity>>(c)
          as MagicList<GroupEntity>;
    }
    List<GroupEntity> groups = await getList<GroupEntity>(
        "$base/$id/children", (element) => GroupEntity.fromJson(element));
    await _api.cache<MagicList<GroupEntity>>(c, transformToMagicList(groups),
        duration: const Duration(hours: 1));
    return groups;
  }

  Future<bool> join(int id) async {
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id/join"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    return response.body == "true";
  }
}

class GroupsResource extends BaseResource {
  GroupsResource(super.api, super.httpClient, super.base);

  Future<List<GroupEntity>> get() async {
    String c = "groups_get";
    if (await _api.isCached(c)) {
      return await _api.getCached<MagicList<GroupEntity>>(c)
          as MagicList<GroupEntity>;
    }
    List<GroupEntity> groups = await getList<GroupEntity>(
        base, (element) => GroupEntity.fromJson(element));
    await _api.cache<MagicList<GroupEntity>>(c, transformToMagicList(groups),
        duration: const Duration(hours: 1));
    return groups;
  }

  Future<List<String>> getIds() async {
    String c = "groups_getIds";
    List<String> ids = await getList<String>("$base/ids", (element) => element);
    return ids;
  }

  Future<List<GroupEntity>> getParents() async {
    String c = "groups_getParents";
    if (await _api.isCached(c)) {
      return await _api.getCached<MagicList<GroupEntity>>(c)
          as MagicList<GroupEntity>;
    }
    List<GroupEntity> groups = await getList<GroupEntity>(
        "$base/parents", (element) => GroupEntity.fromJson(element));
    await _api.cache<MagicList<GroupEntity>>(c, transformToMagicList(groups),
        duration: const Duration(hours: 1));
    return groups;
  }

  Future<List<GroupEntity>> getMyGroups() async {
    String c = "groups_getMyGroups";
    if (await _api.isCached(c)) {
      return await _api.getCached<MagicList<GroupEntity>>(c)
          as MagicList<GroupEntity>;
    }
    List<GroupEntity> groups = await getList<GroupEntity>(
        "$base/my", (element) => GroupEntity.fromJson(element));
    await _api.cache<MagicList<GroupEntity>>(c, transformToMagicList(groups),
        duration: const Duration(minutes: 1));
    return groups;
  }
}

class UserResource extends BaseResource {
  UserResource(super.api, super.httpClient, super.base);

  Future<List<UserEntity>> getAll() async {
    return getList<UserEntity>(base, (element) => UserEntity.fromJson(element));
  }

  Future<UserEntity> getById(String id) async {
    String c = "user_getById_$id";
    if (await _api.isCached(c)) {
      return await _api.getCached<UserEntity>(c) as UserEntity;
    }
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    UserEntity user = UserEntity.fromJson(json);
    await _api.cache<UserEntity>(c, user, duration: const Duration(hours: 1));
    return user;
  }

  Future<UserEntity> getMe() async {
    String c = "user_getMe";
    if (await _api.isCached(c)) {
      return await _api.getCached<UserEntity>(c) as UserEntity;
    }
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/me"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    UserEntity user = UserEntity.fromJson(json);
    await _api.cache<UserEntity>(c, user, duration: const Duration(hours: 1));
    return user;
  }

  Future<bool> isRegistered() async {
    String c = "user_isRegistered";
    if (await _api.isCached(c)) {
      return (await _api.getCached<BoolEntity>(c))!.toBool();
    }
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/isRegistered"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    bool r = response.body == "true";
    await _api.cache<BoolEntity>(c, BoolEntity.fromBool(r));
    return r;
  }

  register(UserType type, int? studentId, DateTime? birthday) async {
    if (type == UserType.student && studentId == null) {
      throw StudentButNoIdProvided();
    }
    await failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "person_type": type.index,
          "student_id": studentId,
          "birthday": birthday
        }));
    await _api.handleError(response);
  }
}

class SecurityResource extends BaseResource {
  SecurityResource(super.api, super.httpClient, super.base);

  Future<Token> getToken(String username, String password) async {
    failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}));
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return Token.fromJson(json);
  }

  Future<Token> refreshToken(String refreshToken) async {
    failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse("$baseRealm/token"),
        body: WebAuth.buildQuery({
          "client_id": clientId,
          "grant_type": "refresh_token",
          "refresh_token": refreshToken
        }),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json"
        });
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    return Token.fromJsonLegacy(json);
  }

  logout(String refreshToken) async {
    failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse("$baseRealm/logout"),
        body: WebAuth.buildQuery(
            {"client_id": clientId, "refresh_token": refreshToken}),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json"
        });
    await _api.handleError(response);
  }
}

class HomeworkResource extends BaseResource {
  HomeworkResource(super.api, super.httpClient, super.base);

  Future<HomeworkEntity> getById(String id) async {
    String c = "homework_getById_$id";
    if (await _api.isCached(c)) {
      return await _api.getCached<HomeworkEntity>(c) as HomeworkEntity;
    }
    failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"), headers: {
      "Authorization": "Bearer ${_api.token}",
      "Content-Type": "application/json"
    });
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    HomeworkEntity homework = HomeworkEntity.fromJson(json);
    await _api.cache<HomeworkEntity>(c, homework);
    return homework;
  }

  createHomework(HomeworkEntity homework) async {
    failIfDisconnected();
    Map<String, dynamic> map = homework.toMap();
    map["group"] = homework.group.id;
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(map));
    await _api.handleError(response);
    Week w = Week.fromDate(homework.date);
    String c =
        "homeworks_getFromTo_${homework.group.id}-${w.begin.toString().split(" ")[0]}-${w.end.toString().split(" ")[0]}";
    await _api.removeCached(c);
  }

  update(HomeworkEntity homework) async {
    // FIXME Don't pass all homework entity but only what changed
    failIfDisconnected();
    Map<String, dynamic> map = homework.toMap();
    map["group"] = homework.group.id;
    Response response = await _httpClient.put(Uri.parse("$base/${homework.id}"),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(map));
    await _api.handleError(response);
    Week w = Week.fromDate(homework.date);
    String c =
        "homeworks_getFromTo_${homework.group.id}-${w.begin.toString().split(" ")[0]}-${w.end.toString().split(" ")[0]}";
    await _api.removeCached(c);
  }

  delete(HomeworkEntity homework) async {
    failIfDisconnected();
    Response response = await _httpClient
        .delete(Uri.parse("$base/${homework.id}"), headers: {
      "Authorization": "Bearer ${_api.token}",
      "Content-Type": "application/json"
    });
    await _api.handleError(response);
    Week w = Week.fromDate(homework.date);
    String c =
        "homeworks_getFromTo_${homework.group.id}-${w.begin.toString().split(" ")[0]}-${w.end.toString().split(" ")[0]}";
    await _api.removeCached(c);
  }
}

class HomeworksResource extends BaseResource {
  HomeworksResource(super.api, super.httpClient, super.base);

  Future<List<HomeworkEntity>> getAll() async {
    return getList<HomeworkEntity>(
        base, (element) => HomeworkEntity.fromJson(element));
  }

  Future<List<HomeworkEntity>> getFromTo(
      GroupEntity group, DateTime start, DateTime end) async {
    String c =
        "homeworks_getFromTo_${group.id}-${start.toString().split(" ")[0]}-${end.toString().split(" ")[0]}";
    if (!_api.isOffline && await _api.isCached(c)) {
      return await _api.getCached<MagicList<HomeworkEntity>>(c)
          as MagicList<HomeworkEntity>;
    } else if (_api.isOffline) {
      try {
        return await _api.getCached<MagicList<HomeworkEntity>>(c)
            as MagicList<HomeworkEntity>;
      } catch (e) {
        return [];
      }
    }
    await failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "group": group.id,
          "start": start.toString().split(" ")[0],
          "end": end.toString().split(" ")[0]
        }));
    await _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<HomeworkEntity> list = List.generate(
        json.length, (index) => HomeworkEntity.fromJson(json[index]));
    await _api.cache<MagicList<HomeworkEntity>>(c, transformToMagicList(list));
    return list;
  }
}

class ScheduleResource extends BaseResource {
  ScheduleResource(super.api, super.httpClient, super.base);

  Future<List<CourseEntity>> getFromTo(
      GroupEntity group, DateTime start, DateTime end) async {
    String c =
        "schedule_getFromTo_${group.id}-${start.toString().split(" ")[0]}-${end.toString().split(" ")[0]}";
    if (!_api.isOffline && await _api.isCached(c)) {
      return await _api.getCached<MagicList<CourseEntity>>(c)
          as MagicList<CourseEntity>;
    } else if (_api.isOffline) {
      try {
        return await _api.getCached<MagicList<CourseEntity>>(c)
            as MagicList<CourseEntity>;
      } catch (e) {
        return [];
      }
    }
    await failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "group": group.id,
          "start": start.toString().split(" ").join("T"),
          "end": end.toString().split(" ").join("T")
        }));
    await _api.handleError(response);
    List<dynamic> json = jsonDecode(response.body);
    List<CourseEntity> list =
        json.map((e) => CourseEntity.fromJson(e)).toList();
    await _api.cache<MagicList<CourseEntity>>(c, transformToMagicList(list));
    return list;
  }
}

class ThemeResource extends BaseResource {
  ThemeResource(super.api, super.httpClient, super.base);

  Future<Theme> getById(int id) async {
    String c = "theme_getById_$id";
    if (await _api.isCached(c)) {
      return await _api.getCached<Theme>(c) as Theme;
    }
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    Theme theme = Theme.fromJson(json);
    await _api.cache<Theme>(c, theme, duration: const Duration(days: 3));
    return theme;
  }
}

class ThemesResource extends BaseResource {
  ThemesResource(super.api, super.httpClient, super.base);

  Future<List<Theme>> getAll() async {
    String c = "themes_getAll";
    if (await _api.isCached(c)) {
      return await _api.getCached<MagicList<Theme>>(c) as MagicList<Theme>;
    }
    List<Theme> themes =
        await getList<Theme>(base, (element) => Theme.fromJson(element));
    await _api.cache<MagicList<Theme>>(c, transformToMagicList(themes),
        duration: const Duration(days: 3));
    return themes;
  }
}

class PreferenceResource extends BaseResource {
  PreferenceResource(super.api, super.httpClient, super.base);

  Future<PreferenceEntity> get() async {
    String c = "preference_get";
    if (await _api.isCached(c)) {
      return await _api.getCached<PreferenceEntity>(c) as PreferenceEntity;
    }
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse(base),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    PreferenceEntity pref = PreferenceEntity.fromJson(json);
    await _api.cache<PreferenceEntity>(
        c, pref, duration: const Duration(days: 3));
    return pref;
  }

  save(PreferenceEntity preference) async {
    failIfDisconnected();
    Response response = await _httpClient.post(Uri.parse(base),
        headers: {
          "Authorization": "Bearer ${_api.token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(preference.toMap()));
    await _api.handleError(response);
    String c = "preference_get";
    await _api.removeCached(c);
  }
}

class RoomResource extends BaseResource {
  RoomResource(super.api, super.httpClient, super.base);

  Future<RoomEntity> getById(int id) async {
    String c = "room_getById_$id";
    if (await _api.isCached(c)) {
      return await _api.getCached<RoomEntity>(c) as RoomEntity;
    }
    await failIfDisconnected();
    Response response = await _httpClient.get(Uri.parse("$base/$id"),
        headers: {"Authorization": "Bearer ${_api.token}"});
    await _api.handleError(response);
    Map<String, dynamic> json = jsonDecode(response.body);
    RoomEntity room = RoomEntity.fromJson(json);
    await _api.cache<RoomEntity>(c, room, duration: const Duration(hours: 8));
    return room;
  }
}

class RoomsResource extends BaseResource {
  RoomsResource(super.api, super.httpClient, super.base);

  Future<List<RoomEntity>> getFree() async {
    String c = "rooms_getFree";
    if (await _api.isCached(c)) {
      return await _api.getCached<MagicList<RoomEntity>>(c) as MagicList<RoomEntity>;
    }
    List<RoomEntity> rooms =
    await getList<RoomEntity>("$base/free", (element) => RoomEntity.fromJson(element));
    await _api.cache<MagicList<RoomEntity>>(c, transformToMagicList(rooms));
    return rooms;
  }
}
