import '../models/mp_stats.dart';

class MyController {
  final MyModel model;

  MyController(this.model);

  void changeData(String newData) {
    model.updateData(newData);
  }
}
