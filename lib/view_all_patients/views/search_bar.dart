import 'package:database_repo/patients_repo.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../bloc/patients_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// TODO : Implement by gender and by age searches

enum SearchType {
  Name,
  Age,
  Gender,
}

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  SearchType searchType = SearchType.Name;
  Gender? gender;
  TextEditingController searchByNameTextFieldController =
      TextEditingController();
  TextEditingController searchByAgeTextFieldController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    Widget searchByNameTextField = TextField(
      controller: searchByNameTextFieldController,
      enabled: context.read<PatientsBloc>().state is LoadingPatientsState &&
              searchType == SearchType.Name
          ? false
          : true,
      onChanged: (searchString) => context.read<PatientsBloc>().add(
            LoadPatientsByNameEvent(
              searchString: searchString,
            ),
          ),
      decoration: InputDecoration(
        icon: FaIcon(FontAwesomeIcons.search),
        labelText: "Search By Patient's Name",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        filled: true,
      ),
    );
    Widget searchByAgeTextField = TextField(
      controller: searchByAgeTextFieldController,
      enabled: context.read<PatientsBloc>().state is LoadingPatientsState &&
              searchType == SearchType.Age
          ? false
          : true,
      onChanged: (searchAge) => searchAge.isEmpty
          ? context.read<PatientsBloc>().add(LoadAllPatientsEvent())
          : context.read<PatientsBloc>().add(
                LoadPatientsByAgeEvent(
                  searchAge: int.parse(searchAge),
                ),
              ),
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        icon: FaIcon(FontAwesomeIcons.search),
        labelText: "Search By Patient's Age",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 16.0,
        ),
        filled: true,
      ),
    );
    Widget searchByGenderDropdown = DropdownButton<Gender>(
      hint: Text('Search By Gender'),
      icon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FaIcon(FontAwesomeIcons.venusMars),
      ),
      items: Gender.values
          .map<DropdownMenuItem<Gender>>(
            (Gender gender) => DropdownMenuItem<Gender>(
              child: Text(
                gender.enumToString(),
              ),
              value: gender,
            ),
          )
          .toList(),
      value: gender,
      onChanged: (searchGender) {
        setState(() {
          gender = searchGender ?? Gender.Male;
          context.read<PatientsBloc>().add(
              LoadPatientsByGenderEvent(searchGender: gender ?? Gender.Male));
        });
      },
    );

    Widget searchTypeDropdown = DropdownButton<SearchType>(
      items: SearchType.values
          .map<DropdownMenuItem<SearchType>>(
            (SearchType searchType) => DropdownMenuItem<SearchType>(
              child: Text(
                searchType == SearchType.Name
                    ? "Name"
                    : searchType == SearchType.Gender
                        ? "Gender"
                        : "Age",
              ),
              value: searchType,
            ),
          )
          .toList(),
      value: searchType,
      onChanged: (type) {
        setState(() {
          searchByNameTextFieldController.clear();
          searchByAgeTextFieldController.clear();
          gender = null;
          searchType = type ?? searchType;
          context.read<PatientsBloc>().add(LoadAllPatientsEvent());
        });
      },
    );

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(
        top: 36.0,
        bottom: 16,
        left: 24.0,
        right: 24.0,
      ),
      alignment: Alignment.center,
      child: Row(
        children: <Widget>[
          Text('Search by: '),
          SizedBox(width: 8.0),
          searchTypeDropdown,
          SizedBox(width: 32.0),
          if (searchType == SearchType.Name)
            Expanded(
              child: searchByNameTextField,
            ),
          if (searchType == SearchType.Age)
            Expanded(
              child: searchByAgeTextField,
            ),
          if (searchType == SearchType.Gender) searchByGenderDropdown,
        ],
      ),
    );
  }
}
