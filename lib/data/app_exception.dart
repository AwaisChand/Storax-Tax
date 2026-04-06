class AppExceptions implements Exception {
  final String? message;
  final String prefix;

  AppExceptions([this.message, this.prefix = ""]);

  @override
  String toString() {
    return "$prefix: $message";
  }
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message])
      : super(message, "Error During Communication");
}

class BadRequestException extends AppExceptions {
  BadRequestException([String? message]) : super(message, "Bad Request");
}

class UnAuthorizedException extends AppExceptions {
  UnAuthorizedException([String? message]) : super(message, "Unauthorized");
}

class InValidInputException extends AppExceptions {
  InValidInputException([String? message]) : super(message, "Invalid Input");
}

class NotFoundException extends AppExceptions {
  NotFoundException([String? message]) : super(message, "Not Found");
}

class ServerErrorException extends AppExceptions {
  ServerErrorException([String? message]) : super(message, "Server Error");
}
