// import the core of the framework:

import 'package:objd/core.dart';
// import the custom pack:
import './packs/template_pack.dart';

void main(List<String> args) {
  createProject(
    Project(
      name: 'template',
      version: 18,
      target: './', // path for where to generate the project
      generate: TemplatePack(), // The starting point of generation
    ),
    args,
  );
}
