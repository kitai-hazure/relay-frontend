import 'package:flutter_riverpod/flutter_riverpod.dart';

// class LiveLearnNotifier
//     extends StateNotifier<AsyncValue<List<LiveLearnModel>>> {
//   final LiveLearnServices _liveLearnServices;
//   LiveLearnNotifier(this._liveLearnServices)
//       : super(const AsyncValue.loading());
//   Future<void> getLiveLearnData() async {
//     final status = await _liveLearnServices.getLiveLearnDetails();
//     state = status.fold(
//       (success) => AsyncValue.data(success),
//       (failure) => AsyncValue.error(failure.message),
//     );
//   }
// }