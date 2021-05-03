/// Represents the status of the form
enum FormStatus {
  /// State of the form when the page first loads => No data has been entered by the user
  pure,

  /// State of the form when the user has altered the input field
  dirty,

  /// State of the form when the all fields are valid
  valid,

  /// State of the form field when one of the fields in not valid
  invalid,
}
