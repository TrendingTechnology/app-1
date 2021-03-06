import 'package:flutter/material.dart';
import 'package:memorare/common/icons_more_icons.dart';
import 'package:memorare/components/web/nav_back_header.dart';
import 'package:memorare/data/add_quote_inputs.dart';
import 'package:memorare/screens/web/add_quote_layout.dart';
import 'package:memorare/screens/web/add_quote_nav_buttons.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/utils/route_names.dart';
import 'package:memorare/utils/router.dart';
import 'package:provider/provider.dart';

class AddQuoteAuthor extends StatefulWidget {
  @override
  _AddQuoteAuthorState createState() => _AddQuoteAuthorState();
}

class _AddQuoteAuthorState extends State<AddQuoteAuthor> {
  String imgUrl  = '';
  String name    = '';
  String job     = '';
  String summary = '';
  String url     = '';
  String wikiUrl = '';

  String _tempImgUrl = '';

  final _nameController     = TextEditingController();
  final _jobController      = TextEditingController();
  final _summaryController  = TextEditingController();
  final _urlController      = TextEditingController();
  final _wikiController     = TextEditingController();

  final _nameFocusNode = FocusNode();

  @override
  void initState() {
    setState(() {
      imgUrl = AddQuoteInputs.authorImgUrl;

      _nameController.text    = AddQuoteInputs.authorName;
      _jobController.text     = AddQuoteInputs.authorJob;
      _summaryController.text = AddQuoteInputs.authorSummary;
      _urlController.text     = AddQuoteInputs.authorUrl;
      _wikiController.text    = AddQuoteInputs.authorWikiUrl;
    });

    super.initState();
  }

  @override
  dispose() {
    AddQuoteInputs.authorImgUrl = imgUrl;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AddQuoteLayout(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              NavBackHeader(),
              body(),
            ],
          ),

          Positioned(
            right: 50.0,
            top: 80.0,
            child: helpButton(),
          )
        ],
      ),
    );
  }

  Widget avatar() {
    return Padding(
      padding: EdgeInsets.only(top: 50.0, bottom: 30.0),
      child: Material(
        elevation: 1.0,
        shape: CircleBorder(),
        clipBehavior: Clip.hardEdge,
        color: Colors.transparent,
        child: imgUrl.length > 0 ?
          Ink.image(
            image: NetworkImage(imgUrl),
            fit: BoxFit.cover,
            width: 200.0,
            height: 200.0,
            child: InkWell(
              onTap: () => showAvatarDialog(),
            ),
          ) :
          Ink(
            width: 200.0,
            height: 200.0,
            child: InkWell(
              onTap: () => showAvatarDialog(),
              child: CircleAvatar(
                child: Icon(
                  Icons.add,
                  size: 50.0,
                  color: Provider.of<ThemeColor>(context).accent,
                ),
                backgroundColor: Colors.black12,
                radius: 80.0,
              ),
            )
          ),
      ),
    );
  }

  Widget body() {
    return SizedBox(
      width: 500.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          title(),

          avatar(),
          nameAndJob(),

          summaryField(),
          links(),
          clearButton(),

          AddQuoteNavButtons(
            onPrevPressed: () => FluroRouter.router.pop(context),
            onNextPressed: () => FluroRouter.router.navigateTo(context, AddQuoteReferenceRoute),
          ),
        ],
      ),
    );
  }

  Widget clearButton() {
    return FlatButton(
      onPressed: () {
        AddQuoteInputs.clearAuthor();

        imgUrl = '';

        _nameController.clear();
        _summaryController.clear();
        _jobController.clear();
        _urlController.clear();
        _wikiController.clear();

        _nameFocusNode.requestFocus();
      },
      child: Opacity(
        opacity: 0.6,
        child: Text(
          'Clear author information',
        ),
      ),
    );
  }

  Widget helpButton() {
    return IconButton(
      iconSize: 40.0,
      icon: Opacity(
        opacity: .6,
        child: Icon(Icons.help),
      ),
      padding: EdgeInsets.symmetric(vertical: 20.0),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: <Widget>[
                  SizedBox(
                    width: 500.0,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Text(
                        'Help',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25.0,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(
                    width: 500.0,
                    child: Opacity(
                      opacity: .6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '• Author information are optional',
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '• If you select the author\'s name in the dropdown list, other fields can stay empty',
                              style: TextStyle(
                                fontSize: 17.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      },
    );
  }

  Widget links() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 300,
          child: TextField(
            controller: _wikiController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(IconsMore.wikipedia_w),
              labelText: 'Wikipedia URL'
            ),
            onChanged: (newValue) {
              wikiUrl = newValue;
              AddQuoteInputs.authorWikiUrl = newValue;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          child: SizedBox(
            width: 300,
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(IconsMore.earth),
                labelText: 'Website URL'
              ),
              onChanged: (newValue) {
                url = newValue;
                AddQuoteInputs.authorUrl = newValue;
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget nameAndJob() {
    return Column(
      children: <Widget>[
        SizedBox(
          width: 200.0,
          child: TextField(
            controller: _nameController,
            autofocus: true,
            focusNode: _nameFocusNode,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Name',
            ),
            onChanged: (newValue) {
              name = newValue;
              AddQuoteInputs.authorName = newValue;
            },
          ),
        ),

        SizedBox(
          width: 200.0,
          child: TextField(
            controller: _jobController,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Job',
            ),
            onChanged: (newValue) {
              job = newValue;
              AddQuoteInputs.authorJob = newValue;
            },
          ),
        ),
      ],
    );
  }

  Widget summaryField() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 100.0),
      child: TextField(
        controller: _summaryController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: 'Summary',
          alignLabelWithHint: true,
        ),
        minLines: 10,
        maxLines: null,
        onChanged: (newValue) {
          summary = newValue;
          AddQuoteInputs.authorSummary = newValue;
        },
      ),
    );
  }

  Widget title() {
    return Column(
      children: <Widget>[
        Text(
          'Add author',
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),

        Opacity(
          opacity: 0.6,
          child: Text(
            '3/6',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }

  void showAvatarDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusDirectional.all(Radius.circular(5.0)),
          ),
          content: Padding(
            padding: const EdgeInsets.all(40.0),
            child: SizedBox(
              width: 250.0,
              height: 150.0,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 60.0),
                    child: Row(
                      children: <Widget>[
                        Text(
                          "Author image's URL",
                          style: TextStyle(
                            fontSize: 20.0,
                          ),
                        ),
                      ],
                    ),
                  ),

                  TextField(
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: imgUrl.length > 0 ? imgUrl : 'URL',
                    ),
                    onChanged: (newValue) {
                      _tempImgUrl = newValue;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Provider.of<ThemeColor>(context).blackOrWhite,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text(
                'SAVE',
              ),
              onPressed: () {
                setState(() {
                  imgUrl = _tempImgUrl;
                });

                AddQuoteInputs.authorImgUrl = imgUrl;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }
}
