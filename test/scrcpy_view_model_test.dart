import 'package:flutter_test/flutter_test.dart';
import 'package:scrcpy_web/models/scrcpy_state.dart';
import 'package:scrcpy_web/viewmodels/scrcpy_view_model.dart';

void main() {
  group('ScrcpyViewModel', () {
    test('trạng thái ban đầu là disconnected', () {
      final vm = ScrcpyViewModel();
      addTearDown(vm.dispose);

      expect(vm.state, ScrcpyState.disconnected);
      expect(vm.stateNotifier.value, ScrcpyState.disconnected);
    });

    test('updateState cập nhật stateNotifier và thông báo listeners', () {
      final vm = ScrcpyViewModel();
      addTearDown(vm.dispose);

      var notified = 0;
      vm.addListener(() => notified++);

      vm.updateState(ScrcpyState.connecting);
      expect(vm.state, ScrcpyState.connecting);

      vm.updateState(ScrcpyState.connected);
      expect(vm.state, ScrcpyState.connected);
      expect(notified, 2);
    });

    test('stateNotifier phát giá trị mới khi updateState', () {
      final vm = ScrcpyViewModel();
      addTearDown(vm.dispose);

      final seen = <ScrcpyState>[];
      vm.stateNotifier.addListener(() => seen.add(vm.stateNotifier.value));

      vm.updateState(ScrcpyState.connecting);
      vm.updateState(ScrcpyState.connected);
      vm.updateState(ScrcpyState.error);
      vm.updateState(ScrcpyState.disconnected);

      expect(seen, [
        ScrcpyState.connecting,
        ScrcpyState.connected,
        ScrcpyState.error,
        ScrcpyState.disconnected,
      ]);
    });
  });
}
