import 'package:objd/core.dart';

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
    return Log('Datapack yuklendi!');
  }
}

class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    return Comment('Tick komutlari');
  }
}