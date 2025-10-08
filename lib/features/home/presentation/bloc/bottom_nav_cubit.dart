import 'package:flutter_bloc/flutter_bloc.dart';

class BottomNavCubit extends Cubit<int> {
  BottomNavCubit([int initialIndex = 2]) : super(initialIndex);

  void setIndex(int index) => emit(index);
}
