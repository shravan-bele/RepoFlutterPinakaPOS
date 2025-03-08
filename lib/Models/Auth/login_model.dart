class LoginResponse { // Build #1.0.8, Naveen added
  bool? success;
  int? statusCode;
  String? code;
  String? message;
  String? token;
  int? id;
  String? email;
  String? nicename;
  String? firstName;
  String? lastName;
  String? displayName;

  LoginResponse({
    this.success,
    this.statusCode,
    this.code,
    this.message,
    this.token,
    this.id,
    this.email,
    this.nicename,
    this.firstName,
    this.lastName,
    this.displayName,
  });

  LoginResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    statusCode = json['statusCode'];
    code = json['code'];
    message = json['message'];
    token = json['data']?['token'];
    id = json['data']?['id'];
    email = json['data']?['email'];
    nicename = json['data']?['nicename'];
    firstName = json['data']?['firstName'];
    lastName = json['data']?['lastName'];
    displayName = json['data']?['displayName'];
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'statusCode': statusCode,
      'code': code,
      'message': message,
      'data': {
        'token': token,
        'id': id,
        'email': email,
        'nicename': nicename,
        'firstName': firstName,
        'lastName': lastName,
        'displayName': displayName,
      }
    };
  }
}


class LoginRequest{

  String _username;
  String _password;

  set username(String value) {
    _username = value;
  }

  set password(String value) {
    _password = value;
  }

  LoginRequest(this._username, this._password,);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = _username;
    data['password'] = _password;
    return data;
  }
}