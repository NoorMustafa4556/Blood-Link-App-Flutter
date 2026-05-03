import 'package:flutter/material.dart';
import '../Models/UserModel.dart';
import '../Services/FirebaseService.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthViewModel extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();
  bool _isLoading = false;
  UserModel? _user;

  bool get isLoading => _isLoading;
  UserModel? get user => _user;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.login(email, password);
      await fetchUserData();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(UserModel userModel, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final cred = await _service.signUp(userModel.email, password);
      final newUser = UserModel(
        uid: cred.user!.uid,
        name: userModel.name,
        email: userModel.email,
        phone: userModel.phone,
        bloodGroup: userModel.bloodGroup,
        area: userModel.area,
      );
      await _service.saveUserData(newUser);
      _user = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserData() async {
    if (_service.currentUser != null) {
      _user = await _service.getUserData(_service.currentUser!.uid);
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _service.logout();
    _user = null;
    notifyListeners();
  }
}
