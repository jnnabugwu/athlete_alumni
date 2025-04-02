import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/athlete.dart';

part 'filter_athletes_event.dart';
part 'filter_athletes_state.dart';

/// BLoC for filtering and sorting athletes
class FilterAthletesBloc extends Bloc<FilterAthletesEvent, FilterAthletesState> {
  /// Constructor
  FilterAthletesBloc() : super(FilterAthletesState.initial()) {
    on<UpdateStatusFilterEvent>(_onUpdateStatusFilter);
    on<AddMajorFilterEvent>(_onAddMajorFilter);
    on<RemoveMajorFilterEvent>(_onRemoveMajorFilter);
    on<AddCareerFilterEvent>(_onAddCareerFilter);
    on<RemoveCareerFilterEvent>(_onRemoveCareerFilter);
    on<UpdateSortOptionEvent>(_onUpdateSortOption);
    on<ToggleSortDirectionEvent>(_onToggleSortDirection);
    on<SearchAthletesEvent>(_onSearchAthletes);
    on<ResetFiltersEvent>(_onResetFilters);
  }

  void _onUpdateStatusFilter(
    UpdateStatusFilterEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    emit(state.copyWith(selectedStatus: event.status));
  }

  void _onAddMajorFilter(
    AddMajorFilterEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    final updatedMajors = List<AthleteMajor>.from(state.selectedMajors)
      ..add(event.major);
    emit(state.copyWith(selectedMajors: updatedMajors));
  }

  void _onRemoveMajorFilter(
    RemoveMajorFilterEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    final updatedMajors = List<AthleteMajor>.from(state.selectedMajors)
      ..remove(event.major);
    emit(state.copyWith(selectedMajors: updatedMajors));
  }

  void _onAddCareerFilter(
    AddCareerFilterEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    final updatedCareers = List<AthleteCareer>.from(state.selectedCareers)
      ..add(event.career);
    emit(state.copyWith(selectedCareers: updatedCareers));
  }

  void _onRemoveCareerFilter(
    RemoveCareerFilterEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    final updatedCareers = List<AthleteCareer>.from(state.selectedCareers)
      ..remove(event.career);
    emit(state.copyWith(selectedCareers: updatedCareers));
  }

  void _onUpdateSortOption(
    UpdateSortOptionEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    emit(state.copyWith(sortOption: event.sortOption));
  }

  void _onToggleSortDirection(
    ToggleSortDirectionEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    emit(state.copyWith(sortAscending: !state.sortAscending));
  }

  void _onSearchAthletes(
    SearchAthletesEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onResetFilters(
    ResetFiltersEvent event, 
    Emitter<FilterAthletesState> emit,
  ) {
    emit(FilterAthletesState.initial());
  }

  /// Apply filters to a list of athletes
  List<Athlete> applyFilters(List<Athlete> athletes) {
    var filteredAthletes = athletes;
    
    // Apply status filter
    if (state.selectedStatus != null) {
      filteredAthletes = filteredAthletes.where(
        (athlete) => athlete.status == state.selectedStatus
      ).toList();
    }
    
    // Apply major filters
    if (state.selectedMajors.isNotEmpty) {
      filteredAthletes = filteredAthletes.where(
        (athlete) => state.selectedMajors.contains(athlete.major)
      ).toList();
    }
    
    // Apply career filters
    if (state.selectedCareers.isNotEmpty) {
      filteredAthletes = filteredAthletes.where(
        (athlete) => state.selectedCareers.contains(athlete.career)
      ).toList();
    }
    
    // Apply sorting
    filteredAthletes = _applySorting(filteredAthletes);
    
    return filteredAthletes;
  }

  List<Athlete> _applySorting(List<Athlete> athletes) {
    final sortedAthletes = List<Athlete>.from(athletes);
    
    switch (state.sortOption) {
      case AthleteSortOption.name:
        sortedAthletes.sort((a, b) => state.sortAscending 
          ? a.name.compareTo(b.name)
          : b.name.compareTo(a.name));
        break;
      case AthleteSortOption.graduationYear:
        sortedAthletes.sort((a, b) {
          final yearA = a.graduationYear?.year ?? 0;
          final yearB = b.graduationYear?.year ?? 0;
          return state.sortAscending 
            ? yearA.compareTo(yearB)
            : yearB.compareTo(yearA);
        });
        break;
      case AthleteSortOption.sport:
        sortedAthletes.sort((a, b) {
          final sportA = a.sport ?? '';
          final sportB = b.sport ?? '';
          return state.sortAscending
            ? sportA.compareTo(sportB)
            : sportB.compareTo(sportA);
        });
        break;
      case AthleteSortOption.university:
        sortedAthletes.sort((a, b) {
          final uniA = a.university ?? '';
          final uniB = b.university ?? '';
          return state.sortAscending
            ? uniA.compareTo(uniB)
            : uniB.compareTo(uniA);
        });
        break;
      case AthleteSortOption.major:
        sortedAthletes.sort((a, b) => state.sortAscending
          ? a.major.displayName.compareTo(b.major.displayName)
          : b.major.displayName.compareTo(a.major.displayName));
        break;
      case AthleteSortOption.career:
        sortedAthletes.sort((a, b) => state.sortAscending
          ? a.career.displayName.compareTo(b.career.displayName)
          : b.career.displayName.compareTo(a.career.displayName));
        break;
    }
    
    return sortedAthletes;
  }
} 