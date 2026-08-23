import 'package:flutter_test/flutter_test.dart';
import 'package:scrcpy_web/services/scrcpy_service_stub.dart';
import 'package:scrcpy_web/viewmodels/scrcpy_sessions_view_model.dart';

void main() {
  group('ScrcpySessionsViewModel', () {
    test('thêm phiên mới và tự chuyển tới phiên đó', () {
      final vm = ScrcpySessionsViewModel(ScrcpyServiceStub());
      addTearDown(vm.dispose);

      vm.addSession();
      expect(vm.sessions, hasLength(1));
      expect(vm.activeIndex, 0);

      vm.addSession();
      expect(vm.sessions, hasLength(2));
      expect(vm.activeIndex, 1);
    });

    test('chuyển phiên hoạt động bằng setActive', () {
      final vm = ScrcpySessionsViewModel(ScrcpyServiceStub());
      addTearDown(vm.dispose);

      vm.addSession();
      vm.addSession();
      vm.addSession();
      vm.setActive(0);
      expect(vm.activeIndex, 0);

      // Index ngoài phạm vi không làm thay đổi
      vm.setActive(-1);
      vm.setActive(99);
      expect(vm.activeIndex, 0);
    });

    test('xóa phiên giữa danh sách giữ đúng thứ tự và index hợp lệ', () async {
      final vm = ScrcpySessionsViewModel(ScrcpyServiceStub());
      addTearDown(vm.dispose);

      vm.addSession(); // phiên sẽ bị xóa
      final b = vm.addSession();
      final c = vm.addSession();
      vm.setActive(0);

      // Xóa chính phiên đang active (index 0)
      await vm.removeSession(0);

      final remainingIds = vm.sessions.map((s) => s.id).toList();
      expect(remainingIds, [b.id, c.id]);
      expect(vm.activeIndex, 0);
    });

    test('xóa phiên cuối khi đang active thu nhỏ index về hợp lệ', () async {
      final vm = ScrcpySessionsViewModel(ScrcpyServiceStub());
      addTearDown(vm.dispose);

      vm.addSession();
      vm.addSession();
      vm.setActive(1);

      await vm.removeSession(1);

      expect(vm.sessions, hasLength(1));
      expect(vm.activeIndex, 0);
    });

    test('removeSession ngoài phạm vi là no-op', () async {
      final vm = ScrcpySessionsViewModel(ScrcpyServiceStub());
      addTearDown(vm.dispose);

      vm.addSession();
      await vm.removeSession(5);
      await vm.removeSession(-1);
      expect(vm.sessions, hasLength(1));
    });

    test('dispose gỡ callback khỏi service', () {
      final stub = ScrcpyServiceStub();
      final vm = ScrcpySessionsViewModel(stub);
      expect(stub.onStateChanged, isNotNull);
      vm.dispose();
      expect(stub.onStateChanged, isNull);
    });
  });
}
