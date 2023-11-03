class UserData {
  late String _userId = '';
  late String _userFname = '';

  String get userId => _userId;
  String get userFname => _userFname;

  set userSetId(String valueId) {
    _userId = valueId;
  }

  set userSetFname(String valueFname) {
    _userFname = valueFname;
  }

  static final UserData _singleton = UserData._internal();

  factory UserData() {
    return _singleton;
  }

  UserData._internal();

  String getUserId() {
    return _userId;
  }

  String getFname() {
    return _userFname;
  }
}
