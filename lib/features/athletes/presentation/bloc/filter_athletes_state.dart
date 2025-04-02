part of 'filter_athletes_bloc.dart';

/// State for the FilterAthletesBloc
class FilterAthletesState extends Equatable {
  /// Status filter (null means no filter)
  final AthleteStatus? selectedStatus;
  
  /// Selected majors for filtering
  final List<AthleteMajor> selectedMajors;
  
  /// Selected careers for filtering
  final List<AthleteCareer> selectedCareers;
  
  /// Current sort option
  final AthleteSortOption sortOption;
  
  /// Whether to sort in ascending order
  final bool sortAscending;
  
  /// Search query for text search
  final String searchQuery;

  final bool isLoading;
  
  /// Filtered athletes
  final List<Athlete> filteredAthletes;

  /// Constructor
  const FilterAthletesState({
    this.selectedStatus,
    this.selectedMajors = const [],
    this.selectedCareers = const [],
    this.sortOption = AthleteSortOption.name,
    this.sortAscending = true,
    this.searchQuery = '',
    this.filteredAthletes = const [],
    this.isLoading = false,
  });

  /// Initial state
  factory FilterAthletesState.initial() {
    return const FilterAthletesState(
      selectedStatus: null,
      selectedMajors: [],
      selectedCareers: [],
      sortOption: AthleteSortOption.name,
      sortAscending: true,
      searchQuery: '',
      filteredAthletes: [],
    );
  }

  /// Create a copy with modified fields
  FilterAthletesState copyWith({
    AthleteStatus? selectedStatus,
    List<AthleteMajor>? selectedMajors,
    List<AthleteCareer>? selectedCareers,
    AthleteSortOption? sortOption,
    bool? sortAscending,
    String? searchQuery,
    List<Athlete>? filteredAthletes,
  }) {
    return FilterAthletesState(
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedMajors: selectedMajors ?? this.selectedMajors,
      selectedCareers: selectedCareers ?? this.selectedCareers,
      sortOption: sortOption ?? this.sortOption,
      sortAscending: sortAscending ?? this.sortAscending,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredAthletes: filteredAthletes ?? this.filteredAthletes,
    );
  }

  /// Checks if all filters and sorts are at their default values
  bool get isDefault => 
      searchQuery.isEmpty &&
      selectedStatus == null &&
      selectedMajors.isEmpty &&
      selectedCareers.isEmpty &&
      sortOption == AthleteSortOption.name &&
      sortAscending == true;

  @override
  List<Object?> get props => [
    selectedStatus,
    selectedMajors,
    selectedCareers,
    sortOption,
    sortAscending,
    searchQuery,
    filteredAthletes,
  ];
} 