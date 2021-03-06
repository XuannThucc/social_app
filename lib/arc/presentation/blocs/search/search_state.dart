part of 'search_bloc.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object> get props => [];
}

class InitState extends SearchState{}

class SearchSuccessState extends SearchState{
  final List<UserData>? listUser;
  const SearchSuccessState(this.listUser);
}

class LoadingSearchState extends SearchState{}

class LoadingListState extends SearchState{}

class LoadListUserFailedState extends SearchState{}

class LoadListUserSuccessState extends SearchState{
  final List<UserData>? listUser;
  const LoadListUserSuccessState(this.listUser);
}