import 'package:flutter/material.dart';
import 'package:memorare/components/empty_view.dart';
import 'package:memorare/components/error.dart';
import 'package:memorare/components/loading.dart';
import 'package:memorare/data/queries.dart';
import 'package:memorare/types/author.dart';
import 'package:memorare/types/colors.dart';
import 'package:memorare/types/reference.dart';
import 'package:provider/provider.dart';

List<Reference> _references = [];
List<Author> _authors = [];

class Discover extends StatefulWidget {
  @override
  _DiscoverState createState() => _DiscoverState();
}

class _DiscoverState extends State<Discover> {
  List<Reference> references = [];
  List<Author> authors = [];

  bool isLoading = false;
  bool hasErrorsAuthors = false;
  bool hasErrorsReferences = false;
  Error error;

  @override
  void initState() {
    super.initState();
    setState(() {
      references = _references;
      authors = _authors;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (authors.length == 0) {
      fetchRandomAuthors();
    }

    if (references.length == 0) {
      fetchRandomReferences();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _references = references;
    _authors = authors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (BuildContext context) {
          final themeColor = Provider.of<ThemeColor>(context);
          final backgroundColor = themeColor.background;

          if (isLoading) {
            return LoadingComponent(
              backgroundColor: Colors.transparent,
              color: backgroundColor,
              title: 'Loading Discover section...',
            );
          }

          if (hasErrorsAuthors && hasErrorsReferences) {
            return ErrorComponent(
              description: error != null ? error.toString() : '',
              title: 'Discover',
            );
          }

          if (authors.length == 0 && references.length == 0) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                EmptyView(
                  title: 'Discover',
                  description: 'It is odd. There is no new data to discover at the moment 🤔. ',
                ),
                Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      'Try again'
                    ),
                  ),
                ),
              ],
            );
          }

          List<Widget> circles = [];

          for (var reference in references) {
            circles.add(
              discoverCard(reference.name, reference.imgUrl)
            );
          }

          for (var author in authors) {
            circles.add(
              discoverCard(author.name, author.imgUrl)
            );
          }

          return ListView(
            padding: EdgeInsets.symmetric(vertical: 50.0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  'Discover',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Opacity(
                  opacity: .6,
                  child: Text(
                    'Uncover new authors and references.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                )
              ),
              Divider(height: 60.0,),
              Wrap(
                alignment: WrapAlignment.center,
                children: circles,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget discoverCard(String title, String imgUrl) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: SizedBox(
        width: 170,
        height: 220,
        child: Card(
          elevation: 5.0,
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: InkWell(
            onTap: () {},
            child: Stack(
              children: <Widget>[
                if (imgUrl != null && imgUrl.length > 0)
                  Opacity(
                      opacity: .3,
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        width: 170,
                        height: 220,
                      ),
                    ),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    title.length > 65 ?
                    '${title.substring(0, 64)}...' :
                    title,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        ),
      )
    );
  }

  void fetchRandomAuthors() {
    setState(() {
      isLoading = true;
    });

    Queries.randomAuthors(context)
    .then((authorsResp) {
      setState(() {
        authors = authorsResp;
        isLoading = false;
      });
    })
    .catchError((err) {
      setState(() {
        error = err;
        hasErrorsAuthors = true;
        isLoading = false;
      });
    });
  }

  void fetchRandomReferences() {
    Queries.randomReferences(context)
    .then((referencesResp) {
      setState(() {
        references = referencesResp;
        isLoading = false;
      });
    })
    .catchError((err) {
      error = err;
      hasErrorsReferences = true;
      isLoading = false;
    });
  }
}