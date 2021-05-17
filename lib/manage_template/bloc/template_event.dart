part of 'template_bloc.dart';

abstract class TemplateEvent {}

/// Represents the event of loading the template from the database
class LoadTemplateEvent extends TemplateEvent {}

/// Represents the event of creating a new field
class CreateNewTemplateFieldEvent extends TemplateEvent {
  final TemplateField newField;

  CreateNewTemplateFieldEvent({required this.newField});
}

/// Represents the event of updating a field
class UpdateTemplateFieldEvent extends TemplateEvent {
  final TemplateField oldField;
  final TemplateField updatedField;

  UpdateTemplateFieldEvent({
    required this.oldField,
    required this.updatedField,
  });
}

/// Represents the event of reording the fields (withing the category) of the template
class ReorderTemplateFieldEvent extends TemplateEvent {
  final TemplateField oldField;
  final TemplateField updatedField;
  final Template updatedTemplate;

  ReorderTemplateFieldEvent({
    required this.oldField,
    required this.updatedField,
    required this.updatedTemplate,
  });
}

/// Represents the event of deleting a field
class DeleteTemplateFieldEvent extends TemplateEvent {
  final TemplateField deletedField;

  DeleteTemplateFieldEvent({required this.deletedField});
}

/// Represents the evet of successful loading of the template from the database
class TemplateLoadedEvent extends TemplateEvent {
  final Template template;

  TemplateLoadedEvent({required this.template});
}
