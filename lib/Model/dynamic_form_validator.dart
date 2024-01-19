import 'package:dynamicform_differentfields/Enum/validator_type.dart';

class DynamicFormValidator {
  validatorType type;
  String errorMessage;
  int textLength;
  DynamicFormValidator(this.type, this.errorMessage, {this.textLength = 0});
}
