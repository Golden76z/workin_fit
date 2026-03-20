import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workin_fit/features/auth/domain/auth_provider.dart';
import 'package:workin_fit/models/friend.dart';
import 'package:workin_fit/models/friend_request.dart';
import 'package:workin_fit/services/friend_service.dart';

final friendServiceProvider = Provider<FriendService>((ref) => FriendService());

final friendsStreamProvider = StreamProvider<List<Friend>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(friendServiceProvider).streamFriends(user.uid);
});

final incomingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(friendServiceProvider).streamIncomingRequests(user.uid);
});

final outgoingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  return ref.read(friendServiceProvider).streamOutgoingRequests(user.uid);
});
