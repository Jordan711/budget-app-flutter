import 'package:budget_app_starting/components.dart';
import 'package:budget_app_starting/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';

final viewModel =
    ChangeNotifierProvider.autoDispose<ViewModel>((ref) => ViewModel());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.read(viewModel).authStateChange;
});
final dollarRegex = RegExp(r'^\d+(\.\d{1,2})?$');

class ViewModel extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');

  List<Models> expenses = [];
  List<Models> incomes = [];
  bool isObscure = true;
  double totalExpense = 0;
  double totalIncome = 0;
  double budgetLeft = 0;
  var logger = Logger();

  bool isLoading = true;

  Stream<User?> get authStateChange => _auth.authStateChanges();
  void toggleObscure() {
    isObscure = !isObscure;
    notifyListeners();
  }

  void calculate() {
    totalExpense = 0;
    totalIncome = 0;
    for (int i = 0; i < expenses.length; i++) {
      totalExpense = totalExpense + double.parse(expenses[i].amount);
    }

    for (int i = 0; i < incomes.length; i++) {
      totalIncome = totalIncome + double.parse(incomes[i].amount);
    }

    budgetLeft = totalIncome - totalExpense;
    notifyListeners();
  }

  // Authentication
  Future<void> createUserWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    await _auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .then((value) {
      logger.d("Registration Successful");
      DialogBox(context, "Registration Success! Welcome ${email}");
    }).onError((error, stackTrace) {
      logger.d("Registration Error: $error");
      DialogBox(
          context,
          "Registration Unsuccessful: " +
              error.toString().replaceAll(RegExp('\\[.*?\\]'), ""));
    });
  }

  Future<void> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    await _auth
        .signInWithEmailAndPassword(email: email, password: password)
        .then((value) => logger.d("Login Successful"))
        .onError((error, stackTrace) {
      logger.d("Login Error: $error");
      DialogBox(
          context,
          "Login Unsuccessful: " +
              error.toString().replaceAll(RegExp('\\[.*?\\]'), ""));
    });
  }

  Future<void> signInWithGoogleWeb(BuildContext context) async {
    GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();
    await _auth.signInWithPopup(googleAuthProvider).onError(
        (error, stackTrace) => DialogBox(
            context, error.toString().replaceAll(RegExp('\\[.*?\\]'), "")));
    logger
        .d("Current user is not empty = ${_auth.currentUser!.uid.isNotEmpty}");
  }

  Future<void> signInWithGoogleMobile(BuildContext context) async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn()
        .signIn()
        .onError((error, stackTrace) => DialogBox(
            context, error.toString().replaceAll(RegExp('\\[.*?\\]'), "")));
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

    await _auth.signInWithCredential(credential).then((value) {
      logger.d("Google sign in successful");
    }).onError((error, stackTrace) {
      logger.d("Google sign in error: $error");
      DialogBox(context, error.toString().replaceAll(RegExp('\\[.*?\\]'), ""));
    });
  }

  Future<void> deleteAccount(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Delete User Account'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(
                      'Warning! All your data and account will be permanently deleted, are you sure?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  await userCollection
                      .doc(_auth.currentUser!.uid)
                      .collection("expenses")
                      .get()
                      .then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.delete();
                    }
                  });

                  await userCollection
                      .doc(_auth.currentUser!.uid)
                      .collection("income")
                      .get()
                      .then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.delete();
                    }
                  });

                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
    await _auth.currentUser!.delete().then((value) async {
      _resetState();
      await _auth.signOut();
      isLoading = true;
    }).onError((error, stackTrace) {
      logger.d("Registration Error: $error");
      DialogBox(
          context,
          "Account Deletion Unsuccessful: " +
              error.toString().replaceAll(RegExp('\\[.*?\\]'), ""));
    });
  }

  void _resetState() {
    expenses = []; // Clear expenses data
    incomes = []; // Clear income data
    totalExpense = 0;
    totalIncome = 0;
    budgetLeft = 0;
    notifyListeners(); // Notify listeners to update the UI
  }

  Future<void> logout() async {
    _resetState();
    await _auth.signOut();
    isLoading = true;
  }

  // Database
  Future addExpense(BuildContext context) async {
    final formKey = GlobalKey<FormState>();

    TextEditingController controllerName = TextEditingController();
    TextEditingController controllerAmount = TextEditingController();
    return await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              contentPadding: EdgeInsets.all(32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(10.0),
              ),
              title: Form(
                  key: formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextForm(
                          text: "Name",
                          containerWidth: 130.0,
                          hintText: "Name",
                          controller: controllerName,
                          validator: (text) {
                            if (text.toString().isEmpty) {
                              return "Required";
                            }
                          }),
                      SizedBox(width: 10.0),
                      TextForm(
                          text: "Amount (\$)",
                          containerWidth: 100.0,
                          hintText: "x.xx",
                          controller: controllerAmount,
                          validator: (text) {
                            if (text.toString().isEmpty) {
                              return "Required";
                            }
                            if (double.tryParse(text) == null) {
                              return "Invalid amount";
                            }
                            if (!dollarRegex.hasMatch(text)) {
                              return "Maximum two decimal places allowed";
                            }
                          }),
                      SizedBox(width: 10.0),
                    ],
                  )),
              actions: [
                MaterialButton(
                  child:
                      OpenSans(text: "Save", size: 15.0, color: Colors.white),
                  splashColor: Colors.grey,
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10.0),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await userCollection
                          .doc(_auth.currentUser!.uid)
                          .collection('expenses')
                          .add({
                        "name": controllerName.text,
                        "amount": controllerAmount.text,
                      }).then(
                        (value) {
                          return DialogBox(context,
                              "Expense ${controllerName.text} with \$${controllerAmount.text} has been added");
                        },
                      ).onError((error, stackTrace) {
                        logger.d("Add Expense Error: $error");
                        return DialogBox(context, error.toString());
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                MaterialButton(
                  child:
                      OpenSans(text: "Cancel", size: 15.0, color: Colors.white),
                  splashColor: Colors.grey,
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  Future addIncome(BuildContext context) async {
    final formKey = GlobalKey<FormState>();

    TextEditingController controllerName = TextEditingController();
    TextEditingController controllerAmount = TextEditingController();
    return await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              actionsAlignment: MainAxisAlignment.center,
              contentPadding: EdgeInsets.all(32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(10.0),
                side: BorderSide(width: 1.0, color: Colors.black),
              ),
              title: Form(
                  key: formKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextForm(
                          text: "Name",
                          containerWidth: 130.0,
                          hintText: "Name",
                          controller: controllerName,
                          validator: (text) {
                            if (text.toString().isEmpty) {
                              return "Required";
                            }
                          }),
                      SizedBox(width: 10.0),
                      TextForm(
                          text: "Amount (\$)",
                          containerWidth: 100.0,
                          hintText: "x.xx",
                          controller: controllerAmount,
                          validator: (text) {
                            if (text.toString().isEmpty) {
                              return "Required";
                            }
                            if (double.tryParse(text) == null) {
                              return "Invalid amount";
                            }
                            if (!dollarRegex.hasMatch(text)) {
                              return "Maximum two decimal places allowed";
                            }
                          }),
                      SizedBox(width: 10.0),
                    ],
                  )),
              actions: [
                MaterialButton(
                  child:
                      OpenSans(text: "Save", size: 15.0, color: Colors.white),
                  splashColor: Colors.grey,
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10.0),
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      await userCollection
                          .doc(_auth.currentUser!.uid)
                          .collection('income')
                          .add({
                        "name": controllerName.text,
                        "amount": controllerAmount.text,
                      }).then(
                        (value) {
                          return DialogBox(context,
                              "Income ${controllerName.text} with \$${controllerAmount.text} has been added");
                        },
                      ).onError((error, stackTrace) {
                        logger.d("Add Income Error: $error");
                        return DialogBox(context, error.toString());
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
                MaterialButton(
                  child:
                      OpenSans(text: "Cancel", size: 15.0, color: Colors.white),
                  splashColor: Colors.grey,
                  color: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10.0),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
            ));
  }

  void expenseStream() async {
    await for (var snapshot in userCollection
        .doc(_auth.currentUser!.uid)
        .collection("expenses")
        .snapshots()) {
      expenses = [];
      snapshot.docs.forEach((element) {
        expenses.add(Models.fromJson(element.data()));
      });
      notifyListeners();
      calculate();
    }
  }

  void incomeStream() async {
    await for (var snapshot in userCollection
        .doc(_auth.currentUser!.uid)
        .collection("income")
        .snapshots()) {
      incomes = [];
      snapshot.docs.forEach((element) {
        incomes.add(Models.fromJson(element.data()));
      });
      notifyListeners();
      calculate();
    }
  }

  Future<void> reset(BuildContext context) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Reset All Budget Values'),
            content: const SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('All your changes will be lost! Are you sure?'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Yes'),
                onPressed: () async {
                  await userCollection
                      .doc(_auth.currentUser!.uid)
                      .collection("expenses")
                      .get()
                      .then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.delete();
                    }
                  });

                  await userCollection
                      .doc(_auth.currentUser!.uid)
                      .collection("income")
                      .get()
                      .then((snapshot) {
                    for (DocumentSnapshot ds in snapshot.docs) {
                      ds.reference.delete();
                    }
                  });

                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }
}
