import 'package:flutter_test/flutter_test.dart';
import 'package:otomasiku_mobile/shared/widgets/otomasiku_logo.dart';

void main() {
  test('OtomasikuLogo defaults to the shared Otomasiku icon style', () {
    const widget = OtomasikuLogo();

    expect(widget.size, 40);
    expect(widget.classic, isFalse);
  });
}
