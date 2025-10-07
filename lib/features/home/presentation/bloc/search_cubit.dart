import 'package:flutter_bloc/flutter_bloc.dart';

class SearchCubit extends Cubit<Map<String, dynamic>> {
  SearchCubit() : super({'query': '', 'isSearching': false,'isVisible': false});
  void clear() => emit({'query': '', 'isSearching': false,'isVisible': false});
  void showSearch() => emit({'query': state['query'], 'isSearching': true,'isVisible': true});
  void hideSearch() => emit({'query': state['query'], 'isSearching': false,'isVisible': false});
  void setSearch(String query) => emit({'query': query, 'isSearching': true,'isVisible': true});
}