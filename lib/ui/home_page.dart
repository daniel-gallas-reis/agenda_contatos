import 'dart:io';
import 'package:agenda_contatos/helpers/contac_helper.dart';
import 'package:agenda_contatos/ui/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper contactHelper = ContactHelper();

  List<dynamic> contacts = [];

  @override
  void initState() {
    super.initState();
    getAllContacts();
  }

  void getAllContacts() {
    contactHelper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
        print(contacts[1].toMap());
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contatos'),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
                const PopupMenuItem<OrderOptions>(
                      value: OrderOptions.orderaz,
                      child: Text('Ordernar de A-Z'),
                    ),
                const PopupMenuItem(
                      value: OrderOptions.orderza,
                      child: Text('Ordernar de Z-A'),
                    ),
                  ],
            onSelected: _orderList,
          ),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showContactPage();
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
        itemCount: contacts.length,
        padding: const EdgeInsets.all(10),
      ),
    );
  }

  Widget _contactCard(BuildContext context, int index) {
    return GestureDetector(
      onLongPress: () {
        showBottomOptions(index);
      },
      onTap: () {
        showContactPage(contact: contacts[index], view: false);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Slidable(
          actionPane: const SlidableBehindActionPane(),
          actionExtentRatio: 0.25,
          secondaryActions: [
            IconSlideAction(
              onTap: () {
                showContactPage(contact: contacts[index], view: true);
              },
              icon: Icons.edit,
              caption: 'Editar',
              color: Colors.blue,
            ),
            IconSlideAction(
              onTap: () {
                contactHelper.deleteContact(contacts[index].id);
                setState(() {
                  contacts.removeAt(index);
                });
              },
              icon: Icons.delete,
              caption: 'Deletar',
              color: Colors.red,
            ),
          ],
          child: Container(
            color: Colors.white,
            child: Card(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5, right: 10),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: setImage(context, index),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contacts[index].name ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                      Text(
                        contacts[index].email ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        contacts[index].phone ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ImageProvider<Object> setImage(BuildContext context, int index) {
    if (contacts[index].img != null) {
      return FileImage(File(contacts[index].img));
    } else {
      return const AssetImage('assets/images/img.png');
    }
  }

  void showContactPage({Contact? contact, bool? view}) async {
    final recContact = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact,
          view: view,
        ),
      ),
    );
    if (recContact != null) {
      if (contact != null) {
        await contactHelper.updateContact(recContact);
      } else {
        await contactHelper.saveContact(recContact);
      }
      getAllContacts();
    }
  }

  void showBottomOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      onPressed: () {
                        launch('tel: ${contacts[index].phone}');
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Ligar',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showContactPage(contact: contacts[index], view: true);
                      },
                      child: const Text(
                        'Editar',
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: TextButton(
                      onPressed: () {
                        contactHelper.deleteContact(contacts[index].id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                      child: const Text(
                        'Excluir',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        print("az");
        contacts!.sort((a, b){
          return a!.name.toLowerCase().compareTo(b!.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        print("za");
        contacts!.sort((a, b){
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {
      print('chegou');
    });
  }

}
