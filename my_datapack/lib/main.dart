import 'package:objd/core.dart';

void main(List<String> args) {
  createProject(
    DataPack(
      name: 'Template Pack',
      main: File(
        'main',
        child: ForMain(),
      ),
      load: File(
        'load',
        child: ForLoad(),
      ),
      version: 21,
    ),
    args,
  );
}

class ForLoad extends Widget {
  @override
  Widget generate(Context context) {
    return Log('Template Pack loaded successfully!');
  }
}

class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    return Comment('Commands executing every tick (1/20s)');
  }
}
