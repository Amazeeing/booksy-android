import 'package:flutter_riverpod/flutter_riverpod.dart';

class FieldsNotifier extends StateNotifier<Map<String, String?>> {
  FieldsNotifier() : super({});

  void setCourse(String value) {
    state = {'course': value};
  }

  void setTutor(String value) {
    state = {'course': state['course'], 'tutor': value};
  }

  void setDate(String value) {
    state = {...state, 'date': value, 'time': null};
  }

  void setTime(String value) {
    state = {...state, 'time': value};
  }

  void clear() {
    state = {};
  }
}
