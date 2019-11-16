import 'dart:async';
import 'dart:math';

import 'package:askkit/Model/Question.dart';
import 'package:askkit/Model/Talk.dart';
import 'package:askkit/Model/User.dart';
import 'package:askkit/View/Controllers/DatabaseController.dart';
import 'package:askkit/View/Pages/LogInPage.dart';
import 'package:askkit/View/Theme.dart';
import 'package:askkit/View/Widgets/Borders.dart';
import 'package:askkit/View/Widgets/CardTemplate.dart';
import 'package:askkit/View/Widgets/CenterText.dart';
import 'package:askkit/View/Widgets/DynamicFAB.dart';
import 'package:askkit/View/Widgets/QuestionCard.dart';
import 'package:askkit/View/Widgets/ShadowDecoration.dart';
import 'package:askkit/View/Widgets/TextAreaForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';


class QuestionsPage extends StatefulWidget {
  final DatabaseController _dbcontroller;
  final Talk _talk;

  QuestionsPage(this._talk, this._dbcontroller);

  @override
  State<StatefulWidget> createState() {
    return QuestionsPageState();
  }

}

class QuestionsPageState extends State<QuestionsPage> {
  List<Question> questions = new List();

  bool loading = false;
  Timer minuteTimer;
  ScrollController scrollController;

  @override void initState() {
    scrollController = ScrollController();
    minuteTimer = Timer.periodic(Duration(minutes: 1), (t) { setState(() { }); });
    this.fetchQuestions();
  }

  @override void dispose() {
    minuteTimer.cancel();
    super.dispose();
  }

  void fetchQuestions() async {
    Stopwatch sw = Stopwatch()..start();
    setState(() { loading = true; });
    questions = await widget._dbcontroller.getQuestions(widget._talk);
    questions.sort((question1, question2) => question2.upvotes.compareTo(question1.upvotes));
    if (this.mounted)
      setState(() { loading = false; });
    print("Question fetch time: " + sw.elapsed.toString());

    if (scrollController.hasClients)
      scrollController.animateTo(0, duration: Duration(seconds: 1), curve: Curves.ease);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Questions"),
          backgroundColor: Theme.of(context).primaryColor,
          actions: <Widget>[
            IconButton(icon: Icon(Icons.refresh), onPressed: fetchQuestions),
          ],
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        body: getBody(),
        floatingActionButton: DynamicFAB(scrollController, addQuestionForm)
    );
  }

  Widget getBody() {
    return Column(
        children: <Widget>[
          Visibility( visible: this.loading, child: CardTemplate.loadingIndicator(context)),
          Expanded(child: questionList())
        ]
    );
  }


  Widget questionList() {
    if (questions.length == 0 && !this.loading)
      return Column(children: <Widget>[_talkHeader(), CenterText("Feels lonely here 😔\nBe the first to ask something!", textScale: 1.25)]);
    return ListView.builder(
        controller: scrollController,
        itemCount: this.questions.length + 1,
        itemBuilder: (BuildContext context, int i) {
          if (i == 0)
            return _talkHeader();
          return Container(
              decoration: ShadowDecoration(shadowColor: CardTemplate.cardShadow, spreadRadius: 1.0, offset: Offset(0, 1)),
              margin: EdgeInsets.only(top: 10.0),
              child: QuestionCard(this.questions[i - 1], true, widget._dbcontroller)
          );
        }
    );
  }

  void addQuestionForm() {
    TextAreaForm textarea = TextAreaForm("Type a question", "Question can't be empty");
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  textarea,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      FlatButton(
                        child: new Text("Cancel"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: new Text("Submit"),
                        onPressed: () {
                          if (!textarea.validate())
                            return;
                          this.addQuestion(textarea.getText());
                          Navigator.pop(context);
                        },
                      )
                    ],
                  )
                ],
              ),
          );
        });
  }

  void addQuestion(String text) async {
    User user = await widget._dbcontroller.getCurrentUser();
    await widget._dbcontroller.addQuestion(Question(widget._talk.reference, user, text, DateTime.now(), null));
    fetchQuestions();
  }

  Widget _talkHeader() {
    return Container(
        decoration: ShadowDecoration(color: Theme.of(context).primaryColorLight, shadowColor: Colors.black, spreadRadius: 0.25, blurRadius: 7.5),
        padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 15.0),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    children: <Widget>[
                      Text(widget._talk.host.name, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.left),
                      Spacer(),
                      Text("Room " + widget._talk.room, style: Theme.of(context).textTheme.caption, textAlign: TextAlign.left)
                    ],
                  )
              ),
              Container(
                  margin: EdgeInsets.only(bottom: 10.0),
                  child: Text(widget._talk.title, style: Theme.of(context).textTheme.headline, textAlign: TextAlign.center)
              ),
              Container(
                  child: Text(widget._talk.description, style: Theme.of(context).textTheme.subhead, textAlign: TextAlign.center)
              ),
            ]
        )
    );
  }
}
