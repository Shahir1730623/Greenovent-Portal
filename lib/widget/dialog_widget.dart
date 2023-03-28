import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../app_colors.dart';

Future<T?> showTextDialog<T>(
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
  var selectedClient;
  String? selectedStatus;
  String? selectedEditStatus;

  List<String> statusList = ["Ongoing", "Completed"];
  List<String> editStatusList = ['allow', 'deny'];


  @override
  void initState() {
    super.initState();
    //controller = TextEditingController(text: widget.value);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return (widget.title == "Delete client") ?
    AlertDialog(
      title: Text(widget.title),
      content: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('clientList')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error = ${snapshot.error}');
          }
          if (!snapshot.hasData) {
            // if snapshot has no data this is going to run
            return Container(
                alignment: FractionalOffset.center,
                child: const CircularProgressIndicator());
          }
          else {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonFormField(
                items: snapshot.data!.docs.map((value) {
                  return DropdownMenuItem(
                    value: value.get('name'),
                    child: Text('${value.get('name')}'),
                  );
                }).toList(),
                decoration: InputDecoration(
                  isDense: true,
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 1.5,
                          color: Colors.grey.shade300),
                      borderRadius:
                      BorderRadius.circular(10)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        width: 1.5,
                        color: Colors.grey.shade300),
                  ),
                ),
                iconSize: 26,
                dropdownColor: Colors.white,
                isExpanded: true,
                value: selectedClient,
                hint: const Text(
                  "Select a client",
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.black,
                  ),
                ),
                onChanged: (newValue) {
                  setState(() {
                    selectedClient = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return "Select a client";
                  } else {
                    return null;
                  }
                },
              ),
            );
          }
        },
      ),
      actions: [
        ElevatedButton(
          child: const Text('Done'),
          onPressed: () => Navigator.of(context).pop(selectedClient),
        )
      ],
    ) :
    (widget.title == "Change Edit Status") ?
    AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: width * 0.2,
        child: DropdownButtonFormField(
          items: editStatusList.map((status) {
            return DropdownMenuItem(
              value: status,
              child: Text(status),
            );
          }).toList(),
          decoration: InputDecoration(
            isDense: true,
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.grey.shade300),
                borderRadius:
                BorderRadius.circular(10)),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                  width: 1.5,
                  color: Colors.grey.shade300),
            ),
          ),
          iconSize: 26,
          dropdownColor: Colors.white,
          isExpanded: true,
          value: selectedEditStatus,
          hint: const Text(
            "Select edit status",
            style: TextStyle(
              fontSize: 15.0,
              color: Colors.black,
            ),
          ),
          onChanged: (newValue) {
            setState(() {
              selectedEditStatus = newValue;
            });
          },
          validator: (value) {
            if (value == null) {
              return "Select status";
            } else {
              return null;
            }
          },
        ),
      ),
      actions: [
        ElevatedButton(
          child: const Text('Done'),
          onPressed: () => Navigator.of(context).pop(selectedEditStatus),
        )
      ],

    ):
    AlertDialog(
        title: Text(widget.title),
        content: SizedBox(
          width: width * 0.2,
          child: DropdownButtonFormField(
            items: statusList.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status),
              );
            }).toList(),
            decoration: InputDecoration(
              isDense: true,
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      width: 1.5,
                      color: Colors.grey.shade300),
                  borderRadius:
                  BorderRadius.circular(10)),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                    width: 1.5,
                    color: Colors.grey.shade300),
              ),
            ),
            iconSize: 26,
            dropdownColor: Colors.white,
            isExpanded: true,
            value: selectedStatus,
            hint: const Text(
              "Select campaign status",
              style: TextStyle(
                fontSize: 15.0,
                color: Colors.black,
              ),
            ),
            onChanged: (newValue) {
              setState(() {
                selectedStatus = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return "Select status";
              } else {
                return null;
              }
            },
          ),
        ),
      actions: [
        ElevatedButton(
          child: const Text('Done'),
          onPressed: () => Navigator.of(context).pop(selectedStatus),
        )
      ],

    );
  }
}