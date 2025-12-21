import 'user_model.dart';

class Story {
  final String id;
  final AppUser user;
  final bool isViewed;

  const Story({required this.id, required this.user, this.isViewed = false});
}
