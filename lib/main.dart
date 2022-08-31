// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'config.dart';
import 'views/home/home.dart';

void main() {
  runApp(const MSM());
}

class MSM extends StatelessWidget {
  const MSM({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return materialApp(const HomePage());
  }
}
