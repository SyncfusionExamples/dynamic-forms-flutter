import 'package:dynamicform_differentfields/Model/dynamic_form_validator.dart';
import '../Enum/formtype.dart';
import 'item_model.dart';

class DynamicModel {
  String controlName;
  String? hintText;
  String value;
  FormType formType;
  //This items property used in dropdown or autocomplete widgets.
  List<ItemModel> items;
  ItemModel? selectedItem;
  bool isRequired;
  List<DynamicFormValidator> validators;
  DynamicModel(this.controlName, this.formType,
      {this.value = '',
      this.hintText,
      this.items = const [],
      this.selectedItem,
      this.isRequired = false,
      this.validators = const []});
}
