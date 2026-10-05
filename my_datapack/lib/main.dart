// ---------------------------------------------------------------------------
// AI DISCLOSURE: This file was generated/extended with AI assistance
// based on the objD 0.4.7 + objd_gui 0.2.0 API docs.
// It has NOT been compiled or tested. Run `dart analyze` before committing.
// ---------------------------------------------------------------------------
// pubspec.yaml dependencies:
//   objd: ^0.4.7
//   objd_gui: ^0.2.0
// ---------------------------------------------------------------------------
import 'package:objd/core.dart';
import 'package:objd_gui/gui.dart';

const int kPackFormat = 48; // Minecraft 1.21
const String kNamespace = 'example';

Project buildProject() => Project(
      name: 'Template Pack',
      version: 21,
      target: './',
      description: 'Template Pack - objD feature showcase (Chest GUI)',
      packFormat: kPackFormat,
      generate: Pack(
        name: kNamespace,
        load: File('load', child: ForLoad()),
        main: File('main', child: ForMain()),
        files: [
          File('welcome', child: WelcomeMessage(playerName: 'Player')),
          File('showcase/loops', child: LoopShowcase(count: 5)),
          File('showcase/math', child: ScoreMathShowcase()),
          // Chest GUI'yi mevcut konumda kurar
          File('setup_gui', child: SetupChestGui()),
        ],
      ),
    );

void main(List<String> args) {
  Scoreboard.prefix = 'tp_';
  final prj = buildProject();
  if (args.contains('--export-zip')) {
    saveAsZip(getAllFiles(prj, args), 'template_pack.zip');
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
// MAIN (her tick)
// ---------------------------------------------------------------------------
class ForMain extends Widget {
  @override
  Widget generate(Context context) {
    final ticks = Score(Entity.Self(), 'counter');
    return Group(
      children: [
        Comment('Commands executing every tick (1/20s)'),
        Execute.as(
          Entity.All(), // @a — @p yok
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
        // Chest GUI: marker etiketli armor stand konumlarında çalışır
        Execute.at(
          Entity(
            type: Entities.armor_stand,
            tags: ['tp_gui'],
          ),
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
            // Başlık / bilgilendirme satırı
            Placeholder(
              slot: Slot.chest(1, 5),
              item: Item(
                Items.oak_sign,
                name: TextComponent('Template Pack Menu',
                    color: Color.Gold, bold: true),
              ),
            ),
            // Greet butonu
            Interactive(
              Item(
                Items.emerald,
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
            // Reset counter butonu
            Interactive(
              Item(
                Items.redstone,
                name: TextComponent('Reset counter',
                    color: Color.Red, bold: true),
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
            name: TextComponent(' '),
          ),
        ),
      ],
      placeholder: Item(
        Items.light_gray_stained_glass_pane,
        name: TextComponent(' '),
      ),
      countScore: 'gui_count',
      pageScore: 'gui_page',
      path: 'gui',
    );
  }
}

// ---------------------------------------------------------------------------
// SETUP: /function example:setup_gui  → mevcut konumda chest + marker
// ---------------------------------------------------------------------------
class SetupChestGui extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        // Marker (görünmez armor stand)
        ArmorStand(
          Location.here(),
          tags: ['tp_gui'],
          invisible: true,
          marker: true,
          basePlate: false,
          name: TextComponent('Template GUI', color: Color.Gold),
          nameVisible: false,
        ),
        // Chest bloğu
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
            TextComponent('Chest GUI placed here. Open the chest!',
                color: Color.Green),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Diğer showcase widget'ları (önceki gibi)
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
