import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:memorare/models/http_clients.dart';
import 'package:memorare/models/user_data.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/credentials.dart';
import 'package:memorare/types/user_data.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  @override
  SigninScreenState createState() => SigninScreenState();
}

class SigninScreenState extends State<SigninScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  final String signinMutation = """
    mutation Signin(\$email: String!, \$password: String!) {
      signin(email: \$email, password: \$password) {
        id
        imgUrl
        email
        lang
        name
        rights
        token
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(40.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Text(
                    'Signin into your existing account.',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.email),
                          labelText: 'Email',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) {
                          email = value;
                        },
                        validator: (value) {
                          if (value.isEmpty) {
                            return 'Email login cannot be empty';
                          }

                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        decoration: InputDecoration(
                          icon: Icon(Icons.lock_outline),
                          labelText: 'Password',
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
                Mutation(
                  builder: (RunMutation runMutation, QueryResult result) {
                    return Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: RaisedButton(
                        color: Color(0xFF2ECC71),
                        onPressed: () {
                          runMutation({
                            'email': email,
                            'password': password,
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.all(15.0),
                          child: Text(
                            'Let me in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                            ),
                          )
                        ),
                      ),
                    );
                  },
                  options: MutationOptions(
                    document: signinMutation,
                  ),
                  onCompleted: (dynamic resultData) {
                    if (resultData == null) { return; }

                    Map<String, dynamic> signinJson = resultData['signin'];

                    var userData = UserData.fromJSON(signinJson);
                    var userDataModel = Provider.of<UserDataModel>(context);

                    userDataModel
                      ..update(userData)
                      ..setAuthenticated(true)
                      ..saveToFile(signinJson);

                    Credentials(email: email, password: password).saveToFile();

                    Provider.of<HttpClientsModel>(context).setToken(userData.token);

                    Navigator.of(context).pop();
                  },
                  update: (Cache cache, QueryResult result) {
                    if (result.hasErrors) {
                      for (var error in result.errors) {
                        Scaffold.of(context)
                          .showSnackBar(
                            SnackBar(
                              backgroundColor: ThemeColor.validation,
                              content: Text(
                                '${error.message}',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                      }
                    }
                  },
                ),
              ],
            ),
          )
        ),
      ],
    );
  }
}