// ---------------------------------------------------------------------------
// AI DISCLOSURE: This file was generated/extended with AI assistance
// (Claude, Anthropic) in Oct 2026, based on the objD 0.4.7 API docs
// (https://pub.dev/documentation/objd/latest/). It has NOT been compiled or
// tested by the AI. Review it and run `dart analyze` before committing.
// ---------------------------------------------------------------------------
import 'package:objd/core.dart';

// NOTE: 48 = Minecraft 1.21. Update this to your target version.
const int kPackFormat = 48;
const String kNamespace = 'example';

// Trigger objective name = Scoreboard.prefix ('tp_') + 'menu'.
// If you change the prefix, update this as well.
const String kMenuObj = 'tp_menu';

Project buildProject() => Project(
      name: 'Template Pack',
      version: 21,
      target: './',
      description: 'Template Pack - objD feature showcase',
      packFormat: kPackFormat,
      // supportedFormats: [48, 57], // optional: support multiple formats
      generate: Pack(
        name: kNamespace,
        load: File('load', child: ForLoad()),
        main: File('main', child: ForMain()),
        // Extra function files (e.g. called with /function example:welcome)
        files: [
          File('welcome', child: WelcomeMessage(playerName: 'Player')),
          File('showcase/loops', child: LoopShowcase(count: 5)),
          File('showcase/math', child: ScoreMathShowcase()),
        ],
      ),
    );

void main(List<String> args) {
  // Automatic prefix for all scoreboard names
  Scoreboard.prefix = 'tp_';

  final prj = buildProject();

  // Optional: export as a zip instead of writing files to disk
  if (args.contains('--export-zip')) {
    saveAsZip(getAllFiles(prj, args), 'template_pack.zip');
    return;
  }

  createProject(prj, args);
}

// ---------------------------------------------------------------------------
// LOAD: runs once on /reload or when the world loads
// ---------------------------------------------------------------------------
class ForLoad extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Log('Template Pack loaded successfully!'),

        // Scoreboard variants
        Scoreboard('config'),
        Scoreboard('counter'),
        Scoreboard.trigger('menu'),

        // Detect player join / rejoin
        PlayerJoin(
          then: Tellraw(
            Entity.Self(),
            show: [TextComponent('Welcome!', color: Color.Gold)],
          ),
        ),
        PlayerJoin.rejoin(
          then: Title(
            Entity.Self(),
            show: [TextComponent('Welcome back', color: Color.Green)],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// MAIN: runs every tick (1/20 s)
// ---------------------------------------------------------------------------
class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    final ticks = Score(Entity.Self(), 'counter');

    return Group(
      children: [
        Comment('Commands executing every tick (1/20s)'),

        // Increase the counter for each player, send a message every 200 ticks (10 s)
        Execute.as(
          Entity.Player(),
          children: [
            ticks.add(1),
            If(
              ticks.matches(200),
              then: [
                Tellraw(
                  Entity.Self(),
                  show: [TextComponent('10 seconds passed', color: Color.Aqua)],
                ),
                ticks.set(0),
              ],
              orElse: [
                // Example orElse branch; can be left out
                Comment('counter has not reached 200 yet'),
              ],
            ),
          ],
        ),

        // Clickable chat menu (opened with /trigger tp_menu)
        GuiMenu(),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// GUI: clickable chat menu (trigger based)
// The player types `/trigger tp_menu` -> menu opens -> clicks a button.
// Buttons run `/trigger tp_menu set N`; the N values are handled below.
// ---------------------------------------------------------------------------
class GuiMenu extends Widget {
  static const int open = 1;
  static const int greet = 2;
  static const int resetCounter = 3;

  TextComponent _button(String label, int value, Color color) {
    return TextComponent(
      '[ $label ]',
      color: color,
      bold: true,
      clickEvent:
          TextClickEvent.run_command(Command('trigger $kMenuObj set $value')),
    );
  }

  @override
  Widget generate(Context context) {
    final menu = Score(Entity.Self(), 'menu');

    return Group(
      children: [
        // Triggers get disabled after use, so re-enable them every tick
        Command('scoreboard players enable @a $kMenuObj'),

        Execute.as(
          Entity.Player(),
          children: [
            If(
              menu.matches(open),
              then: [
                Tellraw(
                  Entity.Self(),
                  show: [
                    TextComponent('=== Template Pack Menu ===\n',
                        color: Color.Gold, bold: true),
                    _button('Greet', greet, Color.Green),
                    TextComponent(' '),
                    _button('Reset counter', resetCounter, Color.Red),
                  ],
                ),
                menu.set(0),
              ],
            ),
            If(
              menu.matches(greet),
              then: [
                Title(
                  Entity.Self(),
                  show: [TextComponent('Hello!', color: Color.Yellow)],
                ),
                menu.set(0),
              ],
            ),
            If(
              menu.matches(resetCounter),
              then: [
                Score(Entity.Self(), 'counter').set(0),
                Tellraw(
                  Entity.Self(),
                  show: [TextComponent('Counter reset', color: Color.Aqua)],
                ),
                menu.set(0),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Custom widget with parameters
// ---------------------------------------------------------------------------
class WelcomeMessage extends Widget {
  final String playerName;
  WelcomeMessage({required this.playerName});

  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Tellraw(
          Entity.Self(),
          show: [
            TextComponent('Hello '),
            TextComponent(playerName, color: Color.Yellow, bold: true),
          ],
        ),
        Tag('welcomed', entity: Entity.Self()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Loops: For + Builder
// ---------------------------------------------------------------------------
class LoopShowcase extends Widget {
  final int count;
  LoopShowcase({required this.count});

  @override
  Widget generate(Context context) {
    return Group(
      children: [
        // Similar to objD's own README example: generate n commands
        For(
          from: 0,
          to: count,
          create: (i) => Tellraw(
            Entity.All(),
            show: [TextComponent('Loop step $i')],
          ),
        ),

        // Builder: plain Dart logic inside the widget tree
        Builder((ctx) {
          final doubled = count * 2;
          return Log('Total steps x2 = $doubled');
        }),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Score operations, operators and conditions
// ---------------------------------------------------------------------------
class ScoreMathShowcase extends Widget {
  @override
  Widget generate(Context context) {
    final a = Score(Entity.Self(), 'config');
    final b = Score(Entity.Self(), 'counter');

    return Group(
      children: [
        a.set(10),
        b.set(3),
        a.addScore(b), // a += b
        a.multiplyByScore(b), // a *= b
        If(
          a > b,
          then: [Log('a > b')],
        ),
        If.not(
          a.matches(0),
          then: [Log('a is not zero')],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Code generation (optional, requires objd_gen + build_runner):
//   @Wdg      -> generates a Widget class from a function
//   @Func()   -> generates a Minecraft function file from a Widget variable
//   @Pck()    -> generates a Pack widget from a File list
//   @Prj()    -> generates the main() function automatically
// To use them, import 'package:objd/annotations.dart' and run
// `dart run build_runner build`.
// ---------------------------------------------------------------------------
