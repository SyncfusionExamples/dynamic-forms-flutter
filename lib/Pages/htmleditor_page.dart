// import 'package:flutter/material.dart';
// import 'package:html_editor_enhanced/html_editor.dart';

// class HTMLEditorPage extends StatelessWidget {
//   final HtmlEditorController controller = HtmlEditorController();
//   String htmlText = '';

//   HTMLEditorPage({
//     Key? key,
//     this.htmlText = '',
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Editor Page"),
//         backgroundColor: const Color.fromARGB(255, 84, 60, 206),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             HtmlEditor(
//               controller: controller, //required
//               htmlEditorOptions: HtmlEditorOptions(
//                 hint: "Your text here...",
//                 initialText: htmlText,
//               ),
//               otherOptions: OtherOptions(
//                   height: MediaQuery.of(context).size.height - 180),
//               htmlToolbarOptions: const HtmlToolbarOptions(
//                   toolbarPosition: ToolbarPosition.belowEditor),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(12.0),
//               child: ElevatedButton(
//                 style: raisedButtonStyle,
//                 onPressed: () {
//                   Navigator.pop(context, controller.getText());
//                 },
//                 child: const Text('Save'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// final ButtonStyle raisedButtonStyle = ElevatedButton.styleFrom(
//   minimumSize: const Size(130, 46),
//   backgroundColor: const Color.fromARGB(255, 84, 60, 206),
//   padding: const EdgeInsets.symmetric(horizontal: 16),
//   shape: const RoundedRectangleBorder(
//     borderRadius: BorderRadius.all(Radius.circular(2)),
//   ),
// );
