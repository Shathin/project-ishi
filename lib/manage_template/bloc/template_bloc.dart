import 'package:bloc/bloc.dart';
import 'package:database_repo/template_repo.dart';

part 'template_state.dart';
part 'template_event.dart';

class TemplateBloc extends Bloc<TemplateEvent, TemplateState> {
  final TemplateRepo templateRepo;

  TemplateBloc({required this.templateRepo}) : super(LoadingTemplateState());

  @override
  Stream<TemplateState> mapEventToState(TemplateEvent event) async* {
    if (event is LoadTemplateEvent) {
      yield* _mapLoadTemplateEventToState();
    } else if (event is UpdateTemplateFieldEvent) {
      yield* _mapUpdateTemplateFieldEventToState(event);
    } else if (event is ReorderTemplateFieldEvent) {
      yield* _mapReorderTemplateFieldEventToState(event);
    } else if (event is DeleteTemplateFieldEvent) {
      yield* _mapDeleteTemplateFieldEventToState(event);
    } else if (event is CreateNewTemplateFieldEvent) {
      yield* _mapCreateNewTemplateFieldEventToState(event);
    } else if (event is TemplateLoadedEvent) {
      yield TemplateLoadedState(template: event.template);
    }
  }

  Stream<TemplateState> _mapLoadTemplateEventToState() async* {
    yield LoadingTemplateState();

    Template template = await this.templateRepo.readTemplate();

    add(TemplateLoadedEvent(template: template));
  }

  Stream<TemplateState> _mapCreateNewTemplateFieldEventToState(
      CreateNewTemplateFieldEvent event) async* {
    yield LoadingTemplateState();

    await this.templateRepo.createNewField(
          newField: event.newField,
        );

    add(LoadTemplateEvent());
  }

  Stream<TemplateState> _mapUpdateTemplateFieldEventToState(
      UpdateTemplateFieldEvent event) async* {
    yield LoadingTemplateState();

    // TODO : Handle error (i.e., [updateField()] returns false on failure)
    await this.templateRepo.updateField(
          oldField: event.oldField,
          updatedField: event.updatedField,
        );

    add(LoadTemplateEvent());
  }

  Stream<TemplateState> _mapReorderTemplateFieldEventToState(
      ReorderTemplateFieldEvent event) async* {
    add(TemplateLoadedEvent(template: event.updatedTemplate));

    await this.templateRepo.reorderField(
          oldField: event.oldField,
          updatedField: event.updatedField,
        );
  }

  Stream<TemplateState> _mapDeleteTemplateFieldEventToState(
      DeleteTemplateFieldEvent event) async* {
    yield LoadingTemplateState();

    await this.templateRepo.deleteField(deletedField: event.deletedField);

    add(LoadTemplateEvent());
  }
}
