import 'package:flutter_bloc/flutter_bloc.dart';

enum NavigationItem {
  home,
  favorites,
  history,
  about,
  settings,
  language,
  theme,
}

class NavigationCubit extends Cubit<NavigationItem> {
  NavigationCubit() : super(NavigationItem.home);

  void navigateTo(NavigationItem item) {
    emit(item);
  }
}
