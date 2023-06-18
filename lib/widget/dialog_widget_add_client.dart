import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddClientDialog extends StatefulWidget {
  String title;
  AddClientDialog({Key? key,required this.title}) : super(key: key);

  @override
  State<AddClientDialog> createState() => _AddClientDialogState();
}

class _AddClientDialogState extends State<AddClientDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController addClientController = TextEditingController();
  TextEditingController aitClientController = TextEditingController();
  TextEditingController asfController = TextEditingController();
  var selectedClient;
  double? initialAit;
  double? initialASF;

  String idGenerator() {
    final now = DateTime.now();
    return now.microsecondsSinceEpoch.toString();
  }

  getAit() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('clientList')
        .where('name', isEqualTo: selectedClient)
        .get();

    for (var result in snapshot.docs) {
      initialAit = (result.data()['AIT']);
    }

    setState(() {
      aitClientController.text = initialAit.toString();
    });
  }

  getASF() async{
    var snapshot = await FirebaseFirestore.instance
        .collection('clientList')
        .where('name', isEqualTo: selectedClient)
        .get();

    for (var result in snapshot.docs) {
      initialASF = (result.data()['ASF']);
    }

    setState(() {
      asfController.text = initialASF.toString();
    });
  }

  setAit() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('clientList')
        .where('name', isEqualTo: selectedClient)
        .get();

    await snapshot.docs.first.reference.update({'AIT': double.parse(aitClientController.text)});
  }

  setASF() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('clientList')
        .where('name', isEqualTo: selectedClient)
        .get();

    await snapshot.docs.first.reference.update({'ASF': double.parse(asfController.text)});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(vertical: 20.0,horizontal: 20),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(22.0))),
      content: Container(
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20
                  ),
                ),

                SizedBox(height: height * 0.03,),

                (widget.title == "Add Client") ?
                    Column(
                      children: [
                        TextFormField(
                          controller: addClientController,
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: Colors.grey.shade300),
                                borderRadius:
                                BorderRadius.circular(10)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    width: 1.5,
                                    color: Colors.grey.shade300),
                                borderRadius:
                                BorderRadius.circular(10)),
                            hintText: "Add Client",
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "The field is empty";
                            }

                            else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(height: height * 0.03,),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: aitClientController,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    hintText: "Input AIT"
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  }

                                  else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 10,),
                            const Text("%",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 30),)
                          ],
                        ),
                        SizedBox(height: height * 0.03,),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: asfController,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    hintText: "Input ASF"
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  }

                                  else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 10,),
                            const Text("%",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 30),)
                          ],
                        )
                      ],
                    ) :
                (widget.title == "Change AIT") ?
                    Column(
                      children: [
                        StreamBuilder(
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

                                    getAit();
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
                        SizedBox(height: height * 0.03,),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: aitClientController,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    hintText: "Input AIT"
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  }

                                  else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 10,),
                            const Text("%",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 30),)
                          ],
                        )
                      ],
                    ) :

                (widget.title == "Change ASF") ?
                    Column(
                      children: [
                        StreamBuilder(
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

                                    getASF();
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
                        SizedBox(height: height * 0.03,),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: asfController,
                                decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            width: 1.5,
                                            color: Colors.grey.shade300),
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                    hintText: "Input ASF"
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "The field is empty";
                                  }

                                  else {
                                    return null;
                                  }
                                },
                              ),
                            ),

                            const SizedBox(width: 10,),
                            const Text("%",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 30),)
                          ],
                        )
                      ],
                    ) : Container(),

                SizedBox(height: height * 0.03,),

                (widget.title == "Add Client") ?
                SizedBox(
                  height: height * 0.04,
                  width: width * 0.15,
                  child: ElevatedButton(
                    child: const Text('Done'),
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        Map<String, dynamic> data = {
                          'name': addClientController.text,
                          'AIT' : double.parse(aitClientController.text),
                          'ASF' : double.parse(asfController.text.trim())
                        };
                        FirebaseFirestore.instance.collection('clientList').doc(idGenerator()).set(data);
                        var snackBar = const SnackBar(content: Text('Client added'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {});
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ) :
                (widget.title == "Change AIT") ?
                SizedBox(
                  height: height * 0.04,
                  width: width * 0.15,
                  child: ElevatedButton(
                    child: const Text('Done'),
                    onPressed: () async{
                      if(selectedClient != null && aitClientController.text.isNotEmpty){
                        await setAit();
                        var snackBar = const SnackBar(content: Text('AIT Changed'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {});
                        Navigator.of(context).pop();
                      }

                      else{
                        var snackBar = const SnackBar(content: Text('Please fill up the values'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                    },
                  ),
                ) :
                SizedBox(
                  height: height * 0.04,
                  width: width * 0.15,
                  child: ElevatedButton(
                    child: const Text('Done'),
                    onPressed: () async{
                      if(selectedClient != null && asfController.text.isNotEmpty){
                        await setASF();
                        var snackBar = const SnackBar(content: Text('ASF Changed'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        setState(() {});
                        Navigator.of(context).pop();
                      }

                      else{
                        var snackBar = const SnackBar(content: Text('Please fill up the values'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      }

                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
