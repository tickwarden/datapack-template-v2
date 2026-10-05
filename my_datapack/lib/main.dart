// ---------------------------------------------------------------------------
// Template Pack – pure objD
// Target: Minecraft 1.20.1 (pack_format 15)
// No objd_gui, no @p, no tellraw menu
// ---------------------------------------------------------------------------
import 'package:objd/core.dart';

const int kPackFormat = 15; // 1.20 – 1.20.1
const String kNamespace = 'example';

const int kGuiGreet = 1;
const int kGuiReset = 2;

Project buildProject() => Project(
      name: 'Template Pack',
      version: 20,
      target: './build/',
      description: 'Template Pack - objD showcase (MC 1.20.1, Chest GUI)',
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
        Scoreboard('gui_click'),
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
// MAIN (every tick)
// ---------------------------------------------------------------------------
class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    final ticks = Score(Entity.Self(), 'counter');
    return Group(
      children: [
        Comment('Tick logic'),
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
        // Chest GUI at every armor_stand tagged tp_gui
        Execute.at(
          Entity(type: Entities.armor_stand, tags: ['tp_gui']),
          children: [
            ChestGuiTick(),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CHEST GUI (1.20.1 NBT: id + Count + tag.display – no components)
// Detect click = button item missing from slot, then refill every tick
// ---------------------------------------------------------------------------
class ChestGuiTick extends Widget {
  @override
  Widget generate(Context context) {
    final click = Score(Entity.Self(), 'gui_click');

    // container slots: row2 col4 = 12, row2 col6 = 14
    return Group(
      children: [
        Comment('Detect button clicks (item removed from slot)'),
        // Greet (Slot 12) missing?
        If(
          Condition.not(
            Condition.data(
              Data.get(Location.here(), path: 'Items[{Slot:12b}]'),
            ),
          ),
          then: [
            Execute.as(
              Entity.All(distance: Range.to(8)),
              children: [
                Title(
                  Entity.Self(),
                  show: [TextComponent('Hello!', color: Color.Yellow)],
                ),
                click.set(kGuiGreet),
              ],
            ),
          ],
        ),
        // Reset (Slot 14) missing?
        If(
          Condition.not(
            Condition.data(
              Data.get(Location.here(), path: 'Items[{Slot:14b}]'),
            ),
          ),
          then: [
            Execute.as(
              Entity.All(distance: Range.to(8)),
              children: [
                Score(Entity.Self(), 'counter').set(0),
                Tellraw(
                  Entity.Self(),
                  show: [
                    TextComponent('Counter reset', color: Color.Aqua),
                  ],
                ),
                click.set(kGuiReset),
              ],
            ),
          ],
        ),

        Comment('Refill chest GUI every tick (1.20.1 item NBT)'),
        Data.merge(
          Location.here(),
          nbt: {
            'Items': [
              // Title sign – row1 col5 → Slot 4
              {
                'Slot': 4,
                'id': 'minecraft:oak_sign',
                'Count': 1,
                'tag': {
                  'display': {
                    'Name':
                        '{"text":"Template Pack Menu","color":"gold","bold":true}',
                  },
                },
              },
              // Greet – Slot 12
              {
                'Slot': 12,
                'id': 'minecraft:emerald',
                'Count': 1,
                'tag': {
                  'display': {
                    'Name':
                        '{"text":"Greet","color":"green","bold":true}',
                    'Lore': [
                      '{"text":"Click to say Hello!","color":"gray"}',
                    ],
                  },
                },
              },
              // Reset – Slot 14
              {
                'Slot': 14,
                'id': 'minecraft:redstone',
                'Count': 1,
                'tag': {
                  'display': {
                    'Name':
                        '{"text":"Reset counter","color":"red","bold":true}',
                    'Lore': [
                      '{"text":"Sets your counter to 0","color":"gray"}',
                    ],
                  },
                },
              },
              // Gray panes – row 1
              for (final s in [0, 1, 2, 3, 5, 6, 7, 8])
                {
                  'Slot': s,
                  'id': 'minecraft:gray_stained_glass_pane',
                  'Count': 1,
                  'tag': {
                    'display': {'Name': '{"text":" "}'},
                  },
                },
              // Gray panes – row 2 (except 12, 14)
              for (final s in [9, 10, 11, 13, 15, 16, 17])
                {
                  'Slot': s,
                  'id': 'minecraft:gray_stained_glass_pane',
                  'Count': 1,
                  'tag': {
                    'display': {'Name': '{"text":" "}'},
                  },
                },
              // Gray panes – row 3
              for (final s in [18, 19, 20, 21, 22, 23, 24, 25, 26])
                {
                  'Slot': s,
                  'id': 'minecraft:gray_stained_glass_pane',
                  'Count': 1,
                  'tag': {
                    'display': {'Name': '{"text":" "}'},
                  },
                },
            ],
          },
        ),
      ],
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
// Showcase widgets
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
