import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memorare/components/web/firestore_app.dart';
import 'package:memorare/components/web/nav_back_footer.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';

class DeleteAccount extends StatefulWidget {
  @override
  _DeleteAccountState createState() => _DeleteAccountState();
}

class _DeleteAccountState extends State<DeleteAccount> {
  bool isLoading = false;
  bool isCompleted = false;
  FirebaseUser userAuth;
  String password = '';

  @override
  void initState() {
    super.initState();
    checkAuthStatus();
  }

  void checkAuthStatus() async {
    userAuth = await FirebaseAuth.instance.currentUser();

    setState(() {});

    if (userAuth == null) {
      FluroRouter.router.navigateTo(context, SigninRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        NavBackHeader(),

        content(),

        NavBackFooter(),
      ],
    );
  }

  Widget content() {
    if (isCompleted) {
      return Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Icon(
              Icons.check_circle,
              size: 80.0,
              color: Colors.green,
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 0.0),
            child: Text(
              'Your account has been successfuly deleted. \nWe hope to see you again.',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 15.0,),
            child: FlatButton(
              onPressed: () {
                FluroRouter.router.navigateTo(
                  context,
                  HomeRoute,
                );
              },
              child: Opacity(
                opacity: .6,
                child: Text(
                  'Back to home',
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (isLoading) {
      return Column(
        children: <Widget>[
          CircularProgressIndicator(),

          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: Text(
              'Deleting your data...',
              style: TextStyle(
                fontSize: 20.0,
              ),
            ),
          )
        ],
      );
    }

    return SizedBox(
      width: 600.0,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 60.0),
            child: Text(
              'Delete my account',
              style: TextStyle(
                fontSize: 35.0,
              ),
            ),
          ),

          Card(
            elevation: 0,
            color: Color(0xFFF85C50),
            child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 30.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 25.0),
                    child: Opacity(
                      opacity: .6,
                      child: Icon(
                        Icons.warning,
                        size: 110.0,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  Container(
                    child: Flexible(
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Are you sure you want to delete your account?',
                            style: TextStyle(
                              fontSize: 25.0,
                              color: Colors.white,
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 15.0),
                            child: Opacity(
                              opacity: .6,
                              child: Text(
                                'This action is irreversible. All your data will be whiped.',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 50.0, bottom: 80.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.lock_outline),
                    labelText: 'Confirm this action by entering your password',
                  ),
                  obscureText: true,
                  onChanged: (value) {
                    password = value;
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password login cannot be empty';
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),

          RaisedButton(
            color: Colors.red,
            onPressed: () {
              deleteAccount();
            },
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                'Delete my account',
                style: TextStyle(
                  color: Colors.white,
                )
              ),
            )
          ),
        ],
      ),
    );
  }

  void deleteAccount() async {
    if (userAuth == null) {
      checkAuthStatus();
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final credentials = EmailAuthProvider.getCredential(
        email: userAuth.email,
        password: password,
      );

      await userAuth.reauthenticateWithCredential(credentials);

      await FirestoreApp.instance
      .collection('users')
      .doc(userAuth.uid)
      .update(data: { 'flag': 'delete'});

      await userAuth.delete();

      setState(() {
        isLoading = false;
        isCompleted = true;
      });

    } catch (error) {
      debugPrint(error.toString());

      setState(() {
        isLoading = false;
      });

      Scaffold.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Error while deleting your account. Please try again or contact us.'),
        )
      );
    }
  }
}
