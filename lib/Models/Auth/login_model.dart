class LoginResponse {
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
 // String? role; // New field added

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
   // this.role,
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
  //  role = json['data']?['role']; // Mapping the new field
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
      //  'role': role, // Adding the new field to JSON
      }
    };
  }
}

class LoginRequest { // Build #1.0.13: Updated login request
  String _empLoginPin;

  set empLoginPin(String value) {
    _empLoginPin = value;
  }

  LoginRequest(this._empLoginPin);

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['emp_login_pin'] = _empLoginPin;
    return data;
  }
}