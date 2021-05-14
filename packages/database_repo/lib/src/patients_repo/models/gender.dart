enum Gender {
  Male,
  Female,
  PreferNotToSay,
  Other,
}

/// An extension that provides additional functionality to the [Gender] enum
extension GenderStringInterconversion on Gender {
  /// Method that converts the string version of the enum to enum type
  ///
  /// This method performs exact string match! If no match is found then method defaults to returning [Gender.Other]
  static Gender stringToEnum(String typeString) {
    switch (typeString) {
      case 'Male':
        return Gender.Male;
      case 'Female':
        return Gender.Female;
      case 'Other':
        return Gender.Other;
      default:
        return Gender.PreferNotToSay;
    }
  }

  /// Method that converts the enum type to a string
  String enumToString() => this
      .toString()
      .split('.')
      .last
      .split(RegExp(r"(?<=[a-z])(?=[A-Z])"))
      .join(" ");
}
