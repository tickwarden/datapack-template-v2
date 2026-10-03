import 'package:objd/core.dart';

// build_runner'ın bu dosyayı tarayıp çıktı üretebilmesi için:
@Packs()
final List<Pack> mainPacks = [
  Pack(
    name: 'example',
    main: File(
      'main',
      child: ForMain(),
    ),
    load: File(
      'load',
      child: ForLoad(),
    ),
  ),
];

class ForLoad extends Widget {
  @override
  Widget generate(Context context) {
    return Log('Datapack loaded!');
  }
}

class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    return Comment('Tick commands');
  }
}