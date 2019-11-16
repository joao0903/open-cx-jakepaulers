import 'package:askkit/Model/Comment.dart';
import 'package:askkit/Model/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Question extends Comment {
  int upvotes = 0;
  int userVote = 0;
  int numComments = 1;

  DocumentReference talk;

  Question(this.talk, User user, String question, DateTime date, DocumentReference reference) : super(user, question, date, reference);

  void downvote() {
    if (userVote == 1)
      upvotes -= 2;
    else if (userVote == -1)
      upvotes++;
    else upvotes--;
    userVote = (userVote == -1) ? 0 : -1;
  }

  void upvote() {
    if (userVote == 1)
      upvotes--;
    else if (userVote == -1)
      upvotes += 2;
    else upvotes++;

    userVote = (userVote == 1) ? 0 : 1;
  }

  String getCommentsString() {
    if (numComments == 1)
        return "1 comment";
    return "$numComments comments";
  }
}
