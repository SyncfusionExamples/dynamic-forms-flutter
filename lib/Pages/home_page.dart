import 'package:dynamicform_differentfields/Enum/validator_type.dart';
import 'package:dynamicform_differentfields/Model/dynamic_form_validator.dart';
import 'package:dynamicform_differentfields/Pages/htmleditor_page.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
//import 'package:html_editor_enhanced/html_editor.dart';
import 'package:dropdown_search/dropdown_search.dart';
import '../Enum/formtype.dart';
import '../Model/dynamic_model.dart';
import '../Model/item_model.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:email_validator/email_validator.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<FormState> globalFormKey = GlobalKey<FormState>();
  late List<DynamicModel> dynamicFormsList = [];
  late List<ItemModel> countries = [];
  late List<ItemModel> states = [];
  //final HtmlEditorController controller = HtmlEditorController();
  final DateRangePickerController dateRangePickerController =
      DateRangePickerController();
  final TextEditingController textEditingController = TextEditingController();
  late int selectedIndex = 0;
  late bool isSubmitClicked;

  @override
  void initState() {
    super.initState();
    textEditingController.text = 'dd/MM/yyyy';
    InitializeForms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dynamic Form"),
        backgroundColor: const Color.fromARGB(255, 84, 60, 206),
      ),
      body: _dynamicWidget(),
    );
  }

  Widget _dynamicWidget() {
    return Form(
      key: globalFormKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  dynamicLists(),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: FormHelper.submitButton("Save", () async {
                      isSubmitClicked = true;
                      if (validateAndSave()) {}
                    },
                        btnColor: const Color.fromARGB(255, 84, 60, 206),
                        borderColor: Colors.transparent),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget dynamicLists() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const ScrollPhysics(),
      itemCount: dynamicFormsList.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: Column(
            children: <Widget>[
              Row(children: <Widget>[
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: getWidgetBasedFormType(index),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
            ],
          ),
          onTap: () async {
            selectedIndex = index;
            var selectedform = dynamicFormsList[index].formType;
            if (selectedform == FormType.HTMLReader) {
              // final result = await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) =>
              //         HTMLEditorPage(htmlText: dynamicFormsList[index].value),
              //   ),
              // );
              // setState(() {
              //   dynamicFormsList[index].value =
              //       result ?? dynamicFormsList[index].value;
              // });
            }
          },
        );
      },
    );
  }

  Widget getWidgetBasedFormType(index) {
    var form = dynamicFormsList[index];
    FormType type = form.formType;
    switch (type) {
      case FormType.Text:
        return getTextWidget(index);
      case FormType.Multiline:
        return getMultilineTextWidget(index);
      case FormType.Dropdown:
        return getDropDown(index, form.items);
      case FormType.AutoComplete:
        return getAutoComplete(index);
      case FormType.HTMLReader:
        return getHtmlReadOnly(index);
      case FormType.DatePicker:
        return getDatePicker(index);
    }
  }

  TextFormField getTextWidget(index) {
    return TextFormField(
      decoration: InputDecoration(
          helperText: dynamicFormsList[index].hintText,
          labelText: dynamicFormsList[index].controlName,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0)))),
      keyboardType: dynamicFormsList[index].validators.any((element) =>
              element.type == validatorType.PhoneNumber ||
              element.type == validatorType.Age)
          ? TextInputType.phone
          : TextInputType.text,
      maxLines: null,
      validator: (text) {
        var selectedField = dynamicFormsList[index];
        //Not empty
        if (selectedField.isRequired &&
            selectedField.validators
                .any((element) => element.type == validatorType.Notempty) &&
            (text == null || text.isEmpty)) {
          return selectedField.validators
              .firstWhere((element) => element.type == validatorType.Notempty)
              .errorMessage;
        }

        //Text length
        if (selectedField.validators
            .any((element) => element.type == validatorType.TextLength)) {
          var validator = selectedField.validators.firstWhere(
              (element) => element.type == validatorType.TextLength);
          int? len = text?.length;
          if (len != null && len > validator.textLength) {
            return validator.errorMessage;
          }
        }

        //Phone Number
        if (selectedField.validators
            .any((element) => element.type == validatorType.PhoneNumber)) {
          var validator = selectedField.validators.firstWhere(
              (element) => element.type == validatorType.PhoneNumber);
          int? len = text?.length;
          if (len != null &&
              (len < validator.textLength || len > validator.textLength)) {
            return validator.errorMessage;
          }
        }

        //Age
        if (selectedField.validators
            .any((element) => element.type == validatorType.Age)) {
          var validator = selectedField.validators
              .firstWhere((element) => element.type == validatorType.Age);
          int? len = text?.length;
          if (len != null && len > validator.textLength) {
            return validator.errorMessage;
          }
        }

        //Email
        if (selectedField.validators
            .any((element) => element.type == validatorType.Email)) {
          var validator = selectedField.validators
              .firstWhere((element) => element.type == validatorType.Email);
          if (text != null && !EmailValidator.validate(text)) {
            return validator.errorMessage;
          }
        }
        return null;
      },
      onChanged: (text) {
        dynamicFormsList[index].value = text;
        if (isSubmitClicked) globalFormKey.currentState?.validate();
      },
    );
  }

  TextFormField getMultilineTextWidget(index) {
    return TextFormField(
      decoration: InputDecoration(
          labelText: dynamicFormsList[index].controlName,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0)))),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      onChanged: (text) {
        dynamicFormsList[index].controlName = text;
      },
    );
  }

  DropdownButtonFormField getDropDown(index, List<ItemModel> listItems) {
    return DropdownButtonFormField<ItemModel>(
      value: dynamicFormsList[index].selectedItem,
      borderRadius: BorderRadius.circular(10),
      items: listItems.map<DropdownMenuItem<ItemModel>>((ItemModel value) {
        return DropdownMenuItem<ItemModel>(
          value: value,
          child: Text(value.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          dynamicFormsList[index].selectedItem = value;
          if (dynamicFormsList[index].controlName == "Country") {
            //Get states based on selected country by parent id.
            var filteredstates = states
                .where((element) => value?.id == element.parentId)
                .toList();

            if (dynamicFormsList
                .any((element) => element.controlName == "State")) {
              dynamicFormsList[index + 1].selectedItem = null;
              var existingitem = dynamicFormsList
                  .firstWhere((element) => element.controlName == "State");
              dynamicFormsList.remove(existingitem);
            }

            if (filteredstates.isNotEmpty) {
              dynamicFormsList.insert(
                  index + 1,
                  DynamicModel("State", FormType.Dropdown,
                      items: filteredstates));
            }
          }
        });
      },
      validator: (value) => value == null ? 'Field required' : null,
      decoration: InputDecoration(
          labelText: dynamicFormsList[index].controlName,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0)))),
    );
  }

  Widget getAutoComplete(index) {
    return DropdownSearch<String>.multiSelection(
      items: const ["Facebook", "Twitter", "Microsoft"],
      popupProps: const PopupPropsMultiSelection.menu(
        isFilterOnline: true,
        showSelectedItems: true,
        showSearchBox: true,
        favoriteItemProps: FavoriteItemProps(
          showFavoriteItems: true,
        ),
      ),
      onChanged: print,
      selectedItems: const ["Facebook"],
    );
  }

  Widget getHtmlReadOnly(index) {
    return Html(
      data: dynamicFormsList[index].value,
      shrinkWrap: true,
      style: {
        // tables will have the below background color
        "table": Style(
          backgroundColor: const Color.fromARGB(0x50, 0xee, 0xee, 0xee),
        ),
        // some other granular customizations are also possible
        "tr": Style(
          border: const Border(bottom: BorderSide(color: Colors.grey)),
        ),
        "th": Style(
          padding: const EdgeInsets.all(6),
          backgroundColor: Colors.grey,
        ),
        "td": Style(
          padding: const EdgeInsets.all(6),
          alignment: Alignment.topLeft,
        ),
      },
    );
  }

  Widget getDatePicker(index) {
    return TextFormField(
      controller: textEditingController,
      decoration: InputDecoration(
          labelText: dynamicFormsList[index].controlName,
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14.0)))),
      maxLines: null,
      readOnly: true,
      onTap: () {
        showDialog<Widget>(
            context: context,
            builder: (BuildContext context) {
              return SfDateRangePicker(
                controller: dateRangePickerController,
                selectionColor: Colors.green,
                showActionButtons: true,
                backgroundColor: Colors.white,
                todayHighlightColor: Colors.transparent,
                initialSelectedDate: DateTime(2023, 1, 22),
                onSubmit: (Object? value) {
                  Navigator.pop(context);
                  setState(() {
                    dynamicFormsList[index].value = DateFormat("dd/MM/y")
                        .format(dateRangePickerController.selectedDate!);
                    textEditingController.text = dynamicFormsList[index].value;
                  });
                },
                onCancel: () {
                  Navigator.pop(context);
                },
              );
            });
      },
    );
  }
//  Widget getHtmlEditor(index) {
//     return HtmlEditor(
//       controller: controller, //required
//       htmlEditorOptions: const HtmlEditorOptions(
//         hint: "Your text here...",
//         //initalText: "text content initial, if any",
//       ),
//       otherOptions: const OtherOptions(
//         height: 400,
//       ),
//     );
//   }

  bool validateAndSave() {
    final form = globalFormKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  //Add dummy forms, it will be invoked when page initialized.
  void InitializeForms() {
    states.add(ItemModel(1, "TamilNadu", parentId: 1));
    states.add(ItemModel(2, "Delhi", parentId: 1));
    states.add(ItemModel(3, "Kerala", parentId: 1));
    states.add(ItemModel(4, "California", parentId: 2));
    states.add(ItemModel(5, "Alaska", parentId: 2));
    states.add(ItemModel(6, "Colorado", parentId: 2));
    states.add(ItemModel(7, "Queensland", parentId: 3));
    states.add(ItemModel(8, "Tasmania", parentId: 3));
    states.add(ItemModel(9, "Victoria", parentId: 3));

    countries.add(ItemModel(1, "India"));
    countries.add(ItemModel(2, "USA"));
    countries.add(ItemModel(3, "Australia"));
    countries.add(ItemModel(4, "England"));

    DynamicModel dynamicModel = DynamicModel("Name", FormType.Text,
        isRequired: true, hintText: "Maximum length should be 10");
    dynamicModel.validators = [];
    dynamicModel.validators.add(DynamicFormValidator(
        validatorType.Notempty, "Name should not be Empty"));
    dynamicModel.validators.add(DynamicFormValidator(
        validatorType.TextLength, "Maximum length should be 10",
        textLength: 10));
    dynamicFormsList.add(dynamicModel);

    dynamicModel = DynamicModel("Phone Number", FormType.Text,
        isRequired: true, hintText: "Phone number should be 10 digits");
    dynamicModel.validators = [];
    dynamicModel.validators.add(DynamicFormValidator(
        validatorType.Notempty, "Phone number should not be Empty"));
    dynamicModel.validators.add(DynamicFormValidator(
        validatorType.PhoneNumber, "Phone number should be 10 digits",
        textLength: 10));
    dynamicFormsList.add(dynamicModel);

    dynamicModel = DynamicModel("Email", FormType.Text, isRequired: true);
    dynamicModel.validators = [];
    dynamicModel.validators.add(DynamicFormValidator(
        validatorType.Notempty, "Email address should not be Empty"));
    dynamicModel.validators.add(DynamicFormValidator(
      validatorType.Email,
      "Invalid email address",
    ));
    dynamicFormsList.add(dynamicModel);

    dynamicModel = DynamicModel("Age", FormType.Text);
    dynamicModel.validators = [];
    dynamicModel.validators.add(DynamicFormValidator(
      validatorType.Age,
      "Age should be 2 digits",
    ));
    dynamicFormsList.add(dynamicModel);

    dynamicFormsList.add(DynamicModel("Address", FormType.Multiline));
    dynamicFormsList.add(DynamicModel("DOB", FormType.DatePicker));
    dynamicFormsList
        .add(DynamicModel("Country", FormType.Dropdown, items: countries));
    dynamicFormsList.add(DynamicModel("Contact", FormType.AutoComplete));
    dynamicFormsList.add(DynamicModel("About", FormType.HTMLReader,
        value:
            """"<p><strong>Bold&nbsp; <span style="background-color: rgb(255, 255, 0);">BackGroundColor</span></strong></p><p style="text-align: justify;"><strong><em>Italic.</em></strong></p><p><span style="text-decoration: underline;">Underline</span></p><p><span style="color: rgb(255, 0, 0); text-decoration: inherit;">Text colour</span></p><p style="text-align: left;"><span style="color: rgb(255, 0, 0); text-decoration: inherit;">Left Alignments</span></p><p style="text-align: center;"><span style="color: rgb(255, 0, 0); text-decoration: inherit;">Centre alignments</span></p><p style="text-align: right;"><span style="color: rgb(255, 0, 0); text-decoration: inherit;">Right alignments</span></p><p style="text-align: justify;"><span style="color: rgb(255, 0, 0); text-decoration: inherit;">Alignment justify</span></p><pre><span style="color: rgb(255, 0, 0); text-decoration: inherit;"><span style="color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal; background-color: rgb(255, 255, 255); display: inline !important; float: none;">code</span><span style=" color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal;">&nbsp;</span><br></span></pre><p><span style="text-decoration: inherit;">Paragraph </span></p><ol><li><h1><span style="text-decoration: inherit;">Heading 1, </span></h1></li><li><h2><span style="text-decoration: inherit;">Heading 2, </span></h2></li><li><h3><span style="text-decoration: inherit;">Heading 3, </span></h3></li><li><h4><span style="text-decoration: inherit;">Heading 4,&nbsp;</span></h4></li></ol><blockquote><span style="text-decoration: inherit;"><span style="color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal; background-color: rgb(255, 255, 255); display: inline !important; float: none;">quotation<span>&nbsp;</span></span></span></blockquote><p><span style="text-decoration: inherit;"><span style="color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal; background-color: rgb(255, 255, 255); display: inline !important; float: none;"><span><a class="e-rte-anchor" href="https://stagingboldsign.bolddesk.com/" title="Hyper link" target="_blank">Hyper link</a></span></span></span></p><p><span style="text-decoration: inherit;"><span style="color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal; background-color: rgb(255, 255, 255); display: inline !important; float: none;"><span><img src="https://stagingboldsign.bolddesk.com/attachment/inline?token=eyJhbGciOiJodHRwOi8vd3d3LnczLm9yZy8yMDAxLzA0L3htbGRzaWctbW9yZSNobWFjLXNoYTI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjQ4ODE0Iiwib3JnaWQiOiIxIiwiaXNzIjoic3RhZ2luZ2JvbGRzaWduLmJvbGRkZXNrLmNvbSJ9.ioxUtZ5A5JnEgC7BtUfEp4pYlOayWGu7MIobDVyUGKM" class="e-rte-image e-imginline e-img-focus" alt="MicrosoftTeams-image.png" width="auto" height="auto" style="min-width: 0px; max-width: 814px; min-height: 0px;"> </span></span></span></p><p><span style="text-decoration: inherit;"> </span></p><table class="e-rte-table" style="width: 100%; min-width: 0px;"><tbody><tr><td class="" style="width: 50%;">Test 1</td><td style="width: 50%;" class=""><span style="color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal; background-color: rgb(255, 255, 255); display: inline !important; float: none;">Test 2</span><br></td></tr><tr><td style="width: 50%;" class=""><span style="color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal; background-color: rgb(255, 255, 255); display: inline !important; float: none;">Test 4</span><br></td><td style="width: 50%;" class=""><span style="color: rgb(0, 0, 0); font-family: Heebo, &quot;open sans&quot;, sans-serif, -apple-system, BlinkMacSystemFont; font-size: 14px; font-style: normal; font-weight: 400; text-align: left; text-indent: 0px; white-space: normal; background-color: rgb(255, 255, 255); display: inline !important; float: none;">Test 4</span><br></td></tr></tbody></table><pre><span style="color: rgb(255, 0, 0); text-decoration: inherit;">Coding control<br></span></pre>"""));
  }
}
