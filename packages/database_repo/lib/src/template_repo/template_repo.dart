import 'dart:async';

// ! Models
import './models/models.dart';

// ! Third party libraris
import 'package:sembast/sembast.dart';

/// Repository that provides operations associated with the template collection
class TemplateRepo {
  final StoreRef _templateStore;
  final Database _database;

  TemplateRepo({
    required Database database,
  })  : this._database = database,
        this._templateStore = stringMapStoreFactory.store('template');

  // * CREATE ===========================================================================

  /// Writes a new template field to the database
  Future<void> createNewField({
    required TemplateField newField,
  }) async {
    await this
        ._templateStore
        .record(newField.fieldKey)
        .add(this._database, newField.objectToMap());
  }

  // * READ =============================================================================

  /// Reads the entire template collection from the database
  Future<Template> readTemplate() async {
    // * Fetch tempate from the database using the [_database] object
    List<RecordSnapshot<dynamic, dynamic>> recordSnapshotList =
        await this._templateStore.find(this._database);

    Map<String, Map<String, dynamic>> templateMap = {};

    recordSnapshotList.forEach((RecordSnapshot snapshot) {
      templateMap[snapshot.key] = snapshot.value;
    });

    return Template.mapToObject(templateMap: templateMap);
  }

  /// Fetches the template field that corresponds to the [fieldKey] argument
  ///
  /// Returns [null] if no field was found
  Future<TemplateField?> readField({
    required String fieldName,
  }) async {
    final String fieldKey = TemplateField.generateFieldKey(fieldName);
    final field =
        await this._templateStore.record(fieldKey).get(this._database);
    if (field == null) return null;
    return TemplateField.mapToObject(
        templateFieldMap: field as Map<String, dynamic>);
  }

  // * UPDATE ===========================================================================

  /// Updates the [oldField] with the [updatedField] supplied to this method as the argument
  ///
  /// Use [reorderField()] method for updates to the field's sequence
  Future<bool> updateField({
    required TemplateField oldField,
    required TemplateField updatedField,
  }) async {
    if (oldField.mandatory) {
      if (oldField.fieldName != updatedField.fieldName ||
          oldField.category != updatedField.category ||
          oldField.type != updatedField.type) {
        // * Reject all changes to the field if the field's name and/or the category and/or the type of a mandatory field was changed
        return false;
      }
    } else {
      if (oldField.fieldName != updatedField.fieldName ||
          oldField.category != updatedField.category) {
        // * Either the field's name was changed
        // * or the category to which the field belonged to has been changed

        // * Delete the existing field from the database
        await this
            ._templateStore
            .record(oldField.fieldKey)
            .delete(this._database);
      }
    }

    if (oldField.category != updatedField.category) {
      // * Place the updated field at the end of the category
      int lastSequence = (await this._templateStore.find(
                this._database,
                finder: Finder(
                  sortOrders: <SortOrder>[SortOrder('sequence')],
                  filter: Filter.equals(
                    'category',
                    updatedField.category.enumToString(),
                  ),
                ),
              ))
          .last
          .value['sequence'];

      await this._templateStore.record(updatedField.fieldKey).put(
            this._database,
            updatedField.copyWith(sequence: lastSequence + 1).objectToMap(),
          );
      return true;
    }

    // * Update the record in the database
    await this._templateStore.record(updatedField.fieldKey).put(
          this._database,
          updatedField.objectToMap(),
        );

    return true;
  }

  /// Method to be used for re-ordering a field among within its category
  Future<void> reorderField({
    required TemplateField oldField,
    required TemplateField updatedField,
  }) async {
    if (oldField.sequence != updatedField.sequence) {
      Filter categoryFilter = Filter.equals(
        'category',
        oldField.category.enumToString(),
      );
      Filter oldSequenceFilter, newSequenceFilter;
      if (oldField.sequence > updatedField.sequence) {
        // * The field was moved upward in the list
        oldSequenceFilter = Filter.lessThan('sequence', oldField.sequence);
        newSequenceFilter =
            Filter.greaterThanOrEquals('sequence', updatedField.sequence);
      } else {
        // * The field was moved downward in the list
        oldSequenceFilter = Filter.greaterThan('sequence', oldField.sequence);
        newSequenceFilter =
            Filter.lessThanOrEquals('sequence', updatedField.sequence);
      }
      List<RecordSnapshot?> records = await this._templateStore.find(
            this._database,
            finder: Finder(
              sortOrders: <SortOrder>[
                SortOrder('sequence'),
              ],
              filter: Filter.and(
                <Filter>[
                  categoryFilter,
                  oldSequenceFilter,
                  newSequenceFilter,
                ],
              ),
            ),
          );

      if (oldField.sequence > updatedField.sequence) {
        // * The field was moved upward in the list
        // * Increment the sequence of everything between the old position (not inclusive) and the new position (inclusive)
        for (RecordSnapshot? record in records) {
          if (record != null) {
            TemplateField oldRecord = TemplateField.mapToObject(
              templateFieldMap: record.value as Map<String, dynamic>,
            );
            TemplateField updatedRecord = oldRecord.copyWith(
              sequence: oldRecord.sequence + 1,
            );
            await this.updateField(
              oldField: oldRecord,
              updatedField: updatedRecord,
            );
          }
        }
      } else {
        // * The field was moved downward in the list
        // * Decrement the sequence of of everything between the old position (not inclusive) and the new pisition (inclusive)

        for (RecordSnapshot? record in records) {
          if (record != null) {
            TemplateField oldRecord = TemplateField.mapToObject(
              templateFieldMap: record.value as Map<String, dynamic>,
            );
            TemplateField updatedRecord = oldRecord.copyWith(
              sequence: oldRecord.sequence - 1,
            );
            await this.updateField(
              oldField: oldRecord,
              updatedField: updatedRecord,
            );
          }
        }
      }
      // * Update the field that was passed as the argument
      await this.updateField(
        oldField: oldField,
        updatedField: updatedField,
      );
    }
  }

  // * DELETE ===========================================================================

  /// Deletes a field from the template collection
  ///
  /// The field is searched using the [deletedTemplateField] argument
  Future<void> deleteField({
    required TemplateField deletedField,
  }) async {
    // * For reordering the sequence of the fields after deletion use the [reorderFields()] method
    await this.reorderField(
      oldField: deletedField,
      updatedField: deletedField.copyWith(sequence: 999),
    );

    // * Delete the field record from the database only if it isn't a mandatory field
    if (!deletedField.mandatory)
      await this
          ._templateStore
          .record(deletedField.fieldKey)
          .delete(this._database);
  }

  // * INIT ===========================================================================

  /// Writes the base template to the database
  ///
  /// Calling this function if a user's template already exists would re-write the template.
  Future<void> initializeTemplate() async {
    // * Clear the template store if it already has any data
    await this._templateStore.delete(this._database);

    // * The [baseTemplate] map is converted to a [Template] object in order to sanitize the [fieldKey] of each field
    final baseTemplateObject = Template.mapToObject(templateMap: baseTemplate);
    final baseTemplateMap = baseTemplateObject.objectToMap();

    for (String fieldKey in baseTemplateMap.keys) {
      await this
          ._templateStore
          .record(fieldKey)
          .add(this._database, baseTemplateMap[fieldKey]);
    }
  }
}
