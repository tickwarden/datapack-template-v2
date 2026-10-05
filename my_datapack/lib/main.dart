// ---------------------------------------------------------------------------
// Template Pack – objD + objd_gui
// Target: Minecraft 1.20.1 (pack_format 15)
// No @p, no tellraw menu, no raw GUI commands
// ---------------------------------------------------------------------------
import 'package:objd/core.dart';
import 'package:objd_gui/gui.dart';

const int kPackFormat = 15;
const String kNamespace = 'example';

Project buildProject() => Project(
      name: 'Template Pack',
      version: 20,
      target: './build/',
      description: 'Template Pack - objD + objd_gui (MC 1.20.1)',
      packFormat: kPackFormat,
      generate: Pack(
        name: kNamespace,
        load: File('load', child: ForLoad()),
        main: File('main', child: ForMain()),
        files: [
          File('welcome', child: WelcomeMessage(playerName: 'Player')),
          File('showcase/loops', child: LoopShowcase(count: 5)),
          File('showcase/math', child: ScoreMathShowcase()),
          File('setup_gui', child: SetupChestGui()),
        ],
      ),
    );

void main(List<String> args) {
  Scoreboard.prefix = 'tp_';
  final prj = buildProject();
  if (args.contains('--export-zip') || args.contains('--prod')) {
    final files = getAllFiles(prj, args);
    final out =
        args.contains('--prod') ? 'Template Pack.zip' : 'template_pack.zip';
    saveAsZip(files, out);
    return;
  }
  createProject(prj, args);
}

// ---------------------------------------------------------------------------
// LOAD
// ---------------------------------------------------------------------------
class ForLoad extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Log('Template Pack loaded successfully!'),
        Scoreboard('config'),
        Scoreboard('counter'),
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
// MAIN
// ---------------------------------------------------------------------------
class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    final ticks = Score(Entity.Self(), 'counter');
    return Group(
      children: [
        Comment('Per-player tick counter'),
        Execute.as(
          Entity.All(),
          children: [
            ticks.add(1),
            If(
              ticks.matches(200),
              then: [
                Tellraw(
                  Entity.Self(),
                  show: [
                    TextComponent('10 seconds passed', color: Color.Aqua),
                  ],
                ),
                ticks.set(0),
              ],
            ),
          ],
        ),
        Comment('objd_gui chest module at each tp_gui marker'),
        Execute.at(
          Entity(type: Entities.armor_stand, tags: ['tp_gui']),
          children: [
            TemplateChestGui(),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CHEST GUI (objd_gui)
// ---------------------------------------------------------------------------
class TemplateChestGui extends Widget {
  @override
  Widget generate(Context context) {
    return GuiModule.chest(
      Location.here(),
      pages: [
        GuiPage(
          [
            Placeholder(
              slot: Slot.chest(1, 5),
              item: Item(
                Items.oak_sign,
                count: 1,
                name: TextComponent(
                  'Template Pack Menu',
                  color: Color.Gold,
                  bold: true,
                ),
              ),
            ),
            Interactive(
              Item(
                Items.emerald,
                count: 1,
                name: TextComponent('Greet', color: Color.Green, bold: true),
                lore: [
                  TextComponent('Click to say Hello!', color: Color.Gray),
                ],
              ),
              slot: Slot.chest(2, 4),
              actions: [
                Title(
                  Entity.Self(),
                  show: [TextComponent('Hello!', color: Color.Yellow)],
                ),
              ],
            ),
            Interactive(
              Item(
                Items.redstone,
                count: 1,
                name: TextComponent(
                  'Reset counter',
                  color: Color.Red,
                  bold: true,
                ),
                lore: [
                  TextComponent('Sets your counter to 0', color: Color.Gray),
                ],
              ),
              slot: Slot.chest(2, 6),
              actions: [
                Score(Entity.Self(), 'counter').set(0),
                Tellraw(
                  Entity.Self(),
                  show: [
                    TextComponent('Counter reset', color: Color.Aqua),
                  ],
                ),
              ],
            ),
          ],
          fillEmptySlots: true,
          placeholder: Item(
            Items.gray_stained_glass_pane,
            count: 1,
            name: TextComponent(' '),
          ),
        ),
      ],
      placeholder: Item(
        Items.light_gray_stained_glass_pane,
        count: 1,
        name: TextComponent(' '),
      ),
      countScore: 'gui_count',
      pageScore: 'gui_page',
      path: 'gui',
    );
  }
}

// ---------------------------------------------------------------------------
// SETUP: /function example:setup_gui
// ---------------------------------------------------------------------------
class SetupChestGui extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        ArmorStand(
          Location.here(),
          tags: ['tp_gui'],
          invisible: true,
          marker: true,
          basePlate: false,
          name: TextComponent('Template GUI', color: Color.Gold),
          nameVisible: false,
        ),
        SetBlock(
          Blocks.chest,
          location: Location.here(),
          nbt: {
            'CustomName':
                '{"text":"Template Pack Menu","color":"gold","bold":true}',
          },
        ),
        Tellraw(
          Entity.Self(),
          show: [
            TextComponent(
              'Chest GUI placed. Open the chest and click Greet / Reset.',
              color: Color.Green,
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Showcase
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

class LoopShowcase extends Widget {
  final int count;
  LoopShowcase({required this.count});

  @override
  Widget generate(Context context) {
    return Group(
      children: [
        For(
          from: 0,
          to: count,
          create: (i) => Tellraw(
            Entity.All(),
            show: [TextComponent('Loop step $i')],
          ),
        ),
        Builder((ctx) {
          final doubled = count * 2;
          return Log('Total steps x2 = $doubled');
        }),
      ],
    );
  }
}

class ScoreMathShowcase extends Widget {
  @override
  Widget generate(Context context) {
    final a = Score(Entity.Self(), 'config');
    final b = Score(Entity.Self(), 'counter');
    return Group(
      children: [
        a.set(10),
        b.set(3),
        a.addScore(b),
        a.multiplyByScore(b),
        If(a > b, then: [Log('a > b')]),
        If.not(a.matches(0), then: [Log('a is not zero')]),
      ],
    );
  }
}
