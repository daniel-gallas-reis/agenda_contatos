import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:agenda_contatos/helpers/contac_helper.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  final bool? view;

  ContactPage({this.contact, this.view});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  bool _userEdited = false;

  bool? _view = true;

  Contact? _editedContact;

  String? errorNameText = null;
  String? errorEmailText = null;
  String? errorPhoneText = null;

  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final phoneFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact!.toMap());
      nameController.text = _editedContact!.name ?? '';
      emailController.text = _editedContact!.email ?? '';
      phoneController.text = _editedContact!.phone ?? '';
      _view = widget.view;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await requestPop();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text(_editedContact!.name ?? 'Novo Contato'),
          centerTitle: true,
          actions: _view == true ? null : [
            IconButton(
              onPressed: () {
                launch('tel: ${_editedContact!.phone}');
              },
              icon: const Icon(
                Icons.phone,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _view = true;
                });
              },
              icon: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),
          ],
        ),
        floatingActionButton: _view == false
            ? null
            : FloatingActionButton(
                onPressed: () {
                  setState(() {
                    if (nameController.text.isEmpty) {
                      errorNameText = 'Campo obrigatório!';
                      FocusScope.of(context).requestFocus(nameFocus);
                    } else {
                      errorNameText = null;
                    }
                    if (emailController.text.isEmpty) {
                      errorEmailText = 'Cammpo obrigatório!';
                      if (nameController.text.isNotEmpty) {
                        FocusScope.of(context).requestFocus(emailFocus);
                      }
                    } else {
                      errorEmailText = null;
                    }
                    if (phoneController.text.isEmpty) {
                      errorPhoneText = 'Campo obrigatório!';
                      if (nameController.text.isNotEmpty &&
                          emailController.text.isNotEmpty) {
                        FocusScope.of(context).requestFocus(phoneFocus);
                      }
                    } else {
                      errorPhoneText = null;
                    }
                    if (nameController.text.isNotEmpty &&
                        emailController.text.isNotEmpty &&
                        phoneController.text.isNotEmpty) {
                      Navigator.pop(context, _editedContact);
                    }
                  });
                },
                child: const Icon(
                  Icons.save,
                ),
              ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: setImage(),
                    ),
                  ),
                ),
                onTap: (){
                  ImagePicker.platform.pickImage(source: ImageSource.gallery).then((value) {
                    if(value == null){
                      return;
                    }else{
                      setState(() {
                        _editedContact!.img = value.path;
                      });
                    }
                  });
                },
              ),
              TextField(
                enabled: _view,
                focusNode: nameFocus,
                controller: nameController,
                decoration: InputDecoration(
                  errorText: errorNameText,
                  labelText: 'Nome',
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    errorNameText = null;
                    _editedContact!.name = text;
                  });
                },
              ),
              TextField(
                enabled: _view,
                focusNode: emailFocus,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  errorText: errorEmailText,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact!.email = text;
                  setState(() {
                    errorEmailText = null;
                  });
                },
              ),
              TextField(
                enabled: _view,
                focusNode: phoneFocus,
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Celular',
                  errorText: errorPhoneText,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: false,
                  signed: false,
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact!.phone = text;
                  setState(() {
                    errorPhoneText = null;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Descartar alterações?'),
              content:
                  const Text('As alterações serão perdidas ao sair sem salvar'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Sair',
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancelar',
                  ),
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }

  ImageProvider<Object> setImage() {
    if (_editedContact!.img != null) {
      return FileImage(File(_editedContact!.img ?? ''));
    } else {
      return const AssetImage('assets/images/img.png');
    }
  }
}
