import 'package:flutter/material.dart';

Future<T?> showTextDialog2<T>(
    BuildContext context, {
      required String title,
      required String value,
    }) =>
    showDialog<T>(
      context: context,
      builder: (context) => TextDialogWidget(
        title: title,
        value: value,
      ),
    );

class TextDialogWidget extends StatefulWidget {
  final String title;
  final String value;

  const TextDialogWidget({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  _TextDialogWidgetState createState() => _TextDialogWidgetState();
}

class _TextDialogWidgetState extends State<TextDialogWidget> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: (widget.title == "Add Client") ? 'Client name' : (widget.title == "Change Link") ? 'Link' : 'Amount',
      ),
    ),
    actions: [
      ElevatedButton(
        child: const Text('Done'),
        onPressed: () {
          var snackBar = SnackBar(content: (widget.title == "Add Client") ? const Text('Client added') : (widget.title == "Change Link") ? const Text('Link added') : const Text('Amount added'));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          Navigator.of(context).pop(controller.text);
        },
      )
    ],
  );
}