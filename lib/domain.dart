import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';

import 'blocs/blocs.dart';

part 'domain.g.dart';

@HiveType(typeId: 0)
class Human {
  int id;

  @HiveField(0)
  String title;

  @HiveField(1)
  ImageSource image;

  Human({this.title});

  Human copyWith({String title}) {
    return Human(title: title ?? this.title);
  }

  Widget getAvatarWidget([double radius = 20]) {
    Widget widget;

    if (image == null) {
      widget = Icon(Icons.account_circle, size: radius * 2.3);
    }

    if (image is ImageSourceBase64) {
      widget = CircleAvatar(
          radius: radius,
          backgroundImage:
              MemoryImage((image as ImageSourceBase64).toByteArray()));
    }

    if (image is ImageSourceFilename) {
      widget = CircleAvatar(
          radius: radius,
          backgroundImage: NetworkImage(
              '/storage/${(image as ImageSourceFilename).filename}'));
    }

    return widget;
  }

  @override
  String toString() => '$id $title';
}

// @HiveType(typeId: 4)
abstract class ImageSource {
  static ImageSource fromString(String contents) {
    /// Имя файла
    if (contents.contains('.')) {
      return ImageSourceFilename(filename: contents);
    }

    if (contents.startsWith('data:')) {
      contents = contents.substring(contents.indexOf(',') + 1);
    }

    return ImageSourceBase64(base64: contents);
  }
}

@HiveType(typeId: 1)
class ImageSourceBase64 extends ImageSource {
  @HiveField(0)
  String base64;

  ImageSourceBase64({@required this.base64}) : assert(base64 != null);

  Uint8List toByteArray() => base64Decode(base64);
}

@HiveType(typeId: 2)
class Voting {
  int id;

  @HiveField(0)
  String title;

  @HiveField(1)
  List<int> candidateIds = [];

  @HiveField(2)
  List<int> refereeIds = [];

  @HiveField(3)
  List<Vote> votes = [];

  ///
  bool get isVotingCompleted =>
      candidateIds.every((candidateId) => isVoteCompleted(candidateId));

  List<int> getHumanList(HumanList humanType) =>
      humanType == HumanList.Referee ? refereeIds : candidateIds;

  /// Все ли судьи назначили оценку участнику
  bool isVoteCompleted(int candidateId) {
    if (refereeIds.isEmpty) return false;

    final votesForCandidate = votes.where((v) =>
        v.candidateId == candidateId && refereeIds.contains(v.refereeId));

    return votesForCandidate.length == refereeIds.length &&
        votesForCandidate.every((vote) => vote.value != null);
  }

  int getComputedVote(int candidateId) {
    final votesForCandidate = votes.where((v) =>
        v.candidateId == candidateId && refereeIds.contains(v.refereeId));

    if (votesForCandidate.where((e) => e.value == null).isNotEmpty ||
        votesForCandidate.length != refereeIds.length) return null;

    var remove = 0;

    remove = 2;

    /*
    if (refereeIds.length == 7) {
      remove = 1;
    } else if (refereeIds.length == 9) {
      remove = 2;
    }
     */

    final nv = List<Vote>.of(votesForCandidate).map((e) => e.value).toList();

    nv.sort();
    nv.removeRange(0, remove);
    nv.removeRange(nv.length - remove, nv.length);

    return (nv.reduce((value, element) => value + element) / nv.length).floor();
  }

  List<VoteResult> getResult() {
    final results = candidateIds
        .map((candidateId) => VoteResult(
            candidateId: candidateId, value: getComputedVote(candidateId)))
        .where((element) => element.value != null)
        .toList();

    results.sort((v1, v2) => v2.value.compareTo(v1.value));

    return results;
  }

  Vote getVote(int candidateId, int refereeId) {
    if (!candidateIds.contains(candidateId))
      throw StateError(
          'Список Voting.candidateIds не содержит в себе candidateId значения\n'
          'Необходимо предоставить candidateId, который есть в списке Voting.candidateIds\n'
          'Voting.candidateIds: $candidateIds\n'
          'candidateId: $candidateId');

    if (!refereeIds.contains(refereeId))
      throw StateError(
          'Список Voting.refereeIds не содержит в себе refereeId значения\n'
          'Необходимо предоставить refereeId, который есть в списке Voting.refereeIds');

    final voteIndex = votes.indexWhere(
        (v) => v.candidateId == candidateId && v.refereeId == refereeId);

    var vote;

    if (voteIndex == -1) {
      votes.add(vote = Vote(candidateId: candidateId, refereeId: refereeId));
    } else {
      vote = votes[voteIndex];
    }

    return vote;
  }
}

@HiveType(typeId: 3)
class Vote {
  @HiveField(0)
  int candidateId;

  @HiveField(1)
  int refereeId;

  @HiveField(2)
  int value;

  Vote({this.candidateId, this.refereeId, this.value});
}

@HiveType(typeId: 4)
class Event {
  int id;

  @HiveField(0)
  String title;

  @HiveField(1)
  List<int> votingIds = [];

  Event({this.title});
}

@HiveType(typeId: 5)
class ImageSourceFilename extends ImageSource {
  @HiveField(0)
  String filename;

  ImageSourceFilename({@required this.filename});
}

class VoteResult {
  final int candidateId;
  final int value;

  VoteResult({@required this.candidateId, @required this.value});
}
