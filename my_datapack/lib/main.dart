import 'package:objd/core.dart';

void main(List<String> args) {
  createProject(
    Project(
      name: 'example',
      version: 21,   // <- virgül şart
      generate: Pack(
        name: 'example',
        load: File(
          'load',
          child: ForLoad(),
        ),
        main: File(
          'main',
          child: ForMain(),
        ),
      ),
    ),
    args,
  );
}

class ForLoad extends Widget {
  @override
  Widget generate(Context context) {
    return Log('Datapack loaded successfully!');
  }
}

class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    return Comment('Commands executing every tick (1/20s)');
  }
}