import 'package:athlete_alumni/features/athletes/presentation/widgets/athlete_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/filter_sort_dialog.dart';
import '../bloc/athlete_bloc.dart';
import '../bloc/filter_athletes_bloc.dart';
// Convert to StatefulWidget to handle initialization
class AthletesPage extends StatefulWidget {
const AthletesPage({super.key});
@override
State<AthletesPage> createState() => AthletesPageState();
}
class AthletesPageState extends State<AthletesPage> {
@override
void initState() {
super.initState();
// Load athletes when the page is initialized
WidgetsBinding.instance.addPostFrameCallback((_) {
  debugPrint('🏃 AthletesPage: Dispatching LoadAllAthletes event');
  context.read<AthleteBloc>().add(LoadAllAthletes());
  });
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Athletes'),
actions: [
IconButton(
icon: const Icon(Icons.filter_list),
tooltip: 'Filter & Sort',
onPressed: () => showFilterSortDialog(context),
),
],
),
body: BlocBuilder<AthleteBloc, AthleteState>(
builder: (context, athleteState) {
debugPrint('🏃 AthletesPage: Current state: ${athleteState.runtimeType}');
if (athleteState is AthleteLoading) {
return const Center(child: CircularProgressIndicator());
} else if (athleteState is AthletesLoaded) {
debugPrint('🏃 AthletesPage: Loaded ${athleteState.athletes.length} athletes');
// Use BlocBuilder for the FilterAthletesBloc to get filter state
return BlocBuilder<FilterAthletesBloc, FilterAthletesState>(
builder: (context, filterState) {
// Apply filters from FilterAthletesBloc to the athletes list
final filteredAthletes = context.read<FilterAthletesBloc>()
.applyFilters(athleteState.athletes);
debugPrint('🏃 AthletesPage: After filtering: ${filteredAthletes.length} athletes');
// Show empty state if no athletes match filters
if (filteredAthletes.isEmpty) {
return const Center(
child: Text('No athletes match your filters'),
);
}
return ListView.builder(
itemCount: filteredAthletes.length,
itemBuilder: (context, index) {
return AthleteListItem(
athlete: filteredAthletes[index],
onTap: () => navigateToAthleteDetails(
context,
filteredAthletes[index].id
),
);
},
);
},
);
} else if (athleteState is AthleteError) {
debugPrint('🏃 AthletesPage: Error: ${athleteState.message}');
return Center(child: Text('Error: ${athleteState.message}'));
}
// Initial state or unhandled state
debugPrint('🏃 AthletesPage: Initial state or unhandled state');
return const Center(
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text('Loading athletes...'),
SizedBox(height: 16),
CircularProgressIndicator(),
],
),
);
},
),
);
}
void showFilterSortDialog(BuildContext context) {
showDialog(
context: context,
builder: (dialogContext) => BlocProvider.value(
value: context.read<FilterAthletesBloc>(),
child: const FilterSortDialog(),
),
);
}
void navigateToAthleteDetails(BuildContext context, String athleteId) {
// Navigate to athlete details page
debugPrint('🏃 AthletesPage: Navigating to athlete details for ID: $athleteId');
// Implement navigation when you have the details page ready
}
}