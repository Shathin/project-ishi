part of 'template_bloc.dart';

abstract class TemplateState {}

/// Represents the state of loading the template from the database
class LoadingTemplateState extends TemplateState {}

/// Represents the state of completion of loading the template from the database
class TemplateLoadedState extends TemplateState {
  final Template template;

  TemplateLoadedState({required this.template});
}
