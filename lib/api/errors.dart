class UserNotRegistered extends Error {
  @override
  String toString() => "User is not registered";
}

class HomeworkMalformed extends Error {
  @override
  String toString() => "Homework is malformed";
}

class UnauthorizedGroupTarget extends Error {
  @override
  String toString() => "Unauthorized group target";
}

class UnknownPersonType extends Error {
  @override
  String toString() => "Unknown person type";
}

class AlreadyRegistered extends Error {
  @override
  String toString() => "User is already registered";
}

class UserNotAllowed extends Error {
  @override
  String toString() => "User is not allowed";
}

class NotReactiveFriendly extends Error {
  @override
  String toString() => "This server is missing some zest of reactive";
}

class StudentButNoIdProvided extends Error {
  @override
  String toString() => "The user type student has no student id associated";
}

class UnknownStudentId extends Error {
  @override
  String toString() => "Student id not authorized";
}
