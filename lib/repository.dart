import 'package:hive/hive.dart';
import 'package:ka4alka_voting/domain.dart';

class Repository {
  static const HumanBoxName = 'humans';
  static const VotingBoxName = 'voting';
  static const EventBoxName = 'events';

  Future<void> open() async {
    if (Hive.box<Human>(HumanBoxName).isEmpty) {
      saveHuman(Human(title: 'Евгений Васечкин'));
      saveHuman(Human(title: 'Арсений Титов'));
      saveHuman(Human(title: 'Егор Николаев'));
      saveHuman(Human(title: 'Евгений Иванов'));
      saveHuman(Human(title: 'Михаил Титов'));
      saveHuman(Human(title: 'Евгений Николаев'));
      saveHuman(Human(title: 'Андрей Титов'));
      saveHuman(Human(title: 'Егор Титов'));
      saveHuman(Human(title: 'Евгений Иванов'));
      saveHuman(Human(title: 'Андрей Николаев'));
      saveHuman(Human(title: 'Александр Титов'));
      saveHuman(Human(title: 'Егор Иванов'));
      saveHuman(Human(title: 'Егор Иванов'));
      saveHuman(Human(title: 'Андрей Титов'));
      saveHuman(Human(title: 'Евгений Васечкин'));
      saveHuman(Human(title: 'Егор Титов'));
      saveHuman(Human(title: 'Егор Иванов'));
      saveHuman(Human(title: 'Андрей Титов'));
      saveHuman(Human(title: 'Евгений Николаев'));
      saveHuman(Human(title: 'Евгений Титов'));
      saveHuman(Human(title: 'Андрей Титов'));
      saveHuman(Human(title: 'Евгений Николаев'));
      saveHuman(Human(title: 'Егор Титов'));
      saveHuman(Human(title: 'Евгений Титов'));
    }
  }

  Future<Map<int, Human>> humans() async {
    return Hive.box<Human>(HumanBoxName).toMap().map((key, human) {
      human.id = key;

      return MapEntry(key, human);
    });
  }

  Future<Map<int, Voting>> votings() async {
    return Hive.box<Voting>(VotingBoxName).toMap().map((key, value) {
      value.id = key;

      return MapEntry(key, value);
    });
  }

  Future<Map<int, Event>> events() async {
    return Hive.box<Event>(EventBoxName).toMap().map((key, value) {
      value.id = key;

      return MapEntry(key, value);
    });
  }

  Future<void> saveHuman(Human human) async {
    final box = Hive.box<Human>(HumanBoxName);

    if (human.id == null) {
      human.id = await box.add(human);
    } else {
      await box.put(human.id, human);
    }
  }

  Future<void> deleteHuman(Human human) async {
    Hive.box<Human>(HumanBoxName).delete(human.id);
  }

  Future<Voting> getVoting(int key) async {
    final voting = Hive.box<Voting>(VotingBoxName).get(key);

    if (voting != null) {
      voting.id = key;
    }

    return voting;
  }

  Future<Voting> saveVoting(Voting voting) async {
    final box = Hive.box<Voting>(VotingBoxName);

    if (voting.id == null) {
      voting.id = await box.add(voting);
    } else {
      await box.put(voting.id, voting);
    }

    return voting;
  }

  Future<void> deleteVoting(Voting voting) async {
    Hive.box<Voting>(VotingBoxName).delete(voting.id);
  }

  Future<void> saveEvent(Event event) async {
    final box = Hive.box<Event>(EventBoxName);

    if (event.id == null) {
      event.id = await box.add(event);
    } else {
      await box.put(event.id, event);
    }
  }

  Future<void> deleteEvent(Event event) async {
    Hive.box<Event>(EventBoxName).delete(event.id);
  }
}
