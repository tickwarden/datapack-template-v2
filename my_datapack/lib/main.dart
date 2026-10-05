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
          File('showcase/random', child: RandomShowcase()),
          File('showcase/storage', child: StorageShowcase()),
          File('showcase/raycast', child: RaycastShowcase()),
          File('showcase/teams', child: TeamShowcase()),
          File('showcase/effects', child: EffectShowcase()),
          File('showcase/particles', child: ParticleShowcase()),
          File('showcase/attributes', child: AttributeShowcase()),
          File('showcase/display', child: DisplayShowcase()),
          File('showcase/interaction', child: InteractionShowcase()),
          File('showcase/bossbar', child: BossbarShowcase()),
          File('showcase/schedule', child: ScheduleShowcase()),
          File('showcase/repeat', child: RepeatShowcase()),
          File('setup_gui', child: SetupChestGui()),
          File('setup_marker', child: SetupMarker()),
          File('uninstall', child: Uninstall()),
        ],
      ),
    );

void main(List<String> args) {
  Scoreboard.prefix = 'tp_';
  final prj = buildProject();

  if (args.contains('--export-zip') || args.contains('--prod')) {
    final files = getAllFiles(prj, args);
    final out =
        args.contains('--prod') ? 'Template_Pack.zip' : 'template_pack.zip';
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
        Comment('=== Template Pack LOAD ==='),
        Log('Template Pack loaded successfully! (pure objD)'),

        // Scoreboards
        Scoreboard('config'),
        Scoreboard('counter'),
        PlayerJoin(
          then: Group(children: [
            Tellraw(Entity.Self(), show: [
              TextComponent('Welcome to Template Pack!',
                  color: Color.Gold, bold: true),
              TextComponent('\nRun '),
              TextComponent('/function template:setup_gui', color: Color.Aqua),
              TextComponent(' to place the Chest GUI.'),
            ]),
            Title(Entity.Self(),
                show: [TextComponent('Template Pack', color: Color.Gold)]),
            Title.subtitle(Entity.Self(),
                show: [
                  TextComponent('Loaded successfully', color: Color.Green)
                ]),
          ]),
        ),
        PlayerJoin.rejoin(
          then: Title(Entity.Self(),
              show: [TextComponent('Welcome back!', color: Color.Green)]),
        ),

        // VersionCheck
        VersionCheck(
          1,
          onUpdate: [Log('Thank you for updating the pack!')],
          onDowndate: [Log('Notice: You installed an older version')],
        ),

        // Background timer (every 5 seconds)
        Timer(
          'heartbeat',
          ticks: 100.ticks,
          children: [
            Comment('Heartbeat – runs every 5s'),
          ],
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
                Tellraw(Entity.Self(), show: [
                  TextComponent('10 seconds passed (counter reset)',
                      color: Color.Aqua),
                ]),
                ticks.set(0),
                Bossbar('template:main', name: 'Template Pack').set(value: 50),
              ],
            ),
          ],
        ),
        Comment('objd_gui chest module at each tp_gui marker'),
        Execute.at(
          Entity(type: Entities.armor_stand, tags: ['tp_gui']),
          children: [ChestGuiTick()],
        ),

        // Trigger handling
        Execute.as(
          Entity.All(scores: [
            Score(Entity.Self(), 'trigger_val').matchesRange(Range.from(1))
          ]),
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
// SETUP
// ---------------------------------------------------------------------------
class SetupChestGui extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        ArmorStand.staticMarker(
          Location.here(),
          tags: ['tp_gui'],
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
        Tellraw(Entity.Self(), show: [
          TextComponent(
              'Chest GUI placed! Open the chest and click the buttons.',
              color: Color.Green),
        ]),
        Particle(Particles.happy_villager,
            location: Location.here(), count: 20),
      ],
    );
  }
}

class SetupMarker extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Marker(
          Location.here(),
          tags: ['tp_marker'],
          data: {'purpose': 'location_storage', 'id': 42},
        ),
        Tellraw(Entity.Self(), show: [
          TextComponent('Marker entity placed (serverside only).',
              color: Color.Aqua),
        ]),
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
        Tellraw(Entity.Self(), show: [
          TextComponent('Hello '),
          TextComponent(playerName, color: Color.Yellow, bold: true),
          TextComponent('!'),
        ]),
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
        Comment('Classic For loop'),
        For(
          from: 0,
          to: count,
          create: (i) => Tellraw(Entity.All(),
              show: [TextComponent('Loop step $i')]),
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
        Comment('Score arithmetic & comparisons'),
        a.set(10),
        b.set(3),
        a.addScore(b),
        a.multiplyByScore(b),
        a.subtract(5),
        a.divideByScore(b),
        If(a > b, then: [Log('a > b')]),
        If.not(a.matches(0), then: [Log('a is not zero')]),
        If(a.matchesRange(Range(10, 50)),
            then: [Log('a is between 10 and 50')]),
      ],
    );
  }
}

class RandomShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('RandomScore'),
        RandomScore(
          Entity.Self(),
          from: 1,
          to: 100,
          objective: 'random',
        ),
        Tellraw(Entity.Self(), show: [
          TextComponent('Your random number: ', color: Color.Aqua),
          TextComponent.score(
            Score(Entity.Self(), 'random'),
            color: Color.Yellow,
          ),
        ]),
      ],
    );
  }
}

class StorageShowcase extends Widget {
  @override
  Widget generate(Context context) {
    final storage = Storage('data');

    return Group(
      children: [
        Comment('Global Storage demo'),
        storage.merge({'last_user': 'Player', 'clicks': 1}),
        storage.copyScore('clicks',
            score: Score(Entity.Self(), 'counter')),
        Tellraw(Entity.Self(), show: [
          TextComponent('Storage message: ', color: Color.Gray),
          TextComponent.storageNbt('template:data',
              path: 'message', interpret: true),
        ]),
      ],
    );
  }
}

class RaycastShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Raycast'),
        Raycast(
          Entity.Self(),
          max: 20,
          step: 0.5,
          through: Blocks.air,
          onhit: [
            SetBlock(Blocks.gold_block, location: Location.here()),
            Particle(Particles.flame,
                location: Location.here(), count: 10),
            Tellraw(Entity.Self(), show: [
              TextComponent('Ray hit! Gold block placed.',
                  color: Color.Gold),
            ]),
          ],
        ),
      ],
    );
  }
}

class TeamShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Team join'),
        Entity.Self().joinTeam('template_red'),
        Tellraw(Entity.Self(), show: [
          TextComponent('You joined ', color: Color.White),
          TextComponent('Template Red', color: Color.Red, bold: true),
        ]),
      ],
    );
  }
}

class EffectShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Effect(
          EffectType.speed,
          entity: Entity.Self(),
          duration: 10.seconds,
          amplifier: 2,
          showParticles: false,
        ),
        Effect(
          EffectType.jump_boost,
          entity: Entity.Self(),
          duration: 10.seconds,
          amplifier: 1,
        ),
        Tellraw(Entity.Self(), show: [
          TextComponent('Speed II + Jump Boost applied for 10s',
              color: Color.Green),
        ]),
      ],
    );
  }
}

class ParticleShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Particle(
          Particles.totem_of_undying,
          location: Location.here(),
          count: 50,
          delta: Location.rel(x: 0.5, y: 1, z: 0.5),
          speed: 0.1,
        ),
        Particle(
          Particles.soul_fire_flame,
          location: Location.rel(y: 1),
          count: 20,
        ),
      ],
    );
  }
}

class AttributeShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Attribute modifier (raw command for max compatibility)'),
        Command(
          'attribute @s minecraft:generic.movement_speed modifier add 00000000-0000-0000-0000-000000000001 template_speed 0.1 add',
        ),
        Tellraw(Entity.Self(), show: [
          TextComponent('Movement speed increased temporarily',
              color: Color.Yellow),
        ]),
      ],
    );
  }
}

class DisplayShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Display entities'),
        Display.text(
          Location.rel(y: 2),
          TextComponent('Floating Text!',
              color: Color.LightPurple, bold: true),
          billboardType: BillboardType.center,
          transformation: Transformation.scaleAll(1.5),
          tags: ['tp_display'],
        ),
        Display.item(
          Location.rel(y: 1.5, x: 1),
          Item(Items.diamond_sword),
          itemDisplay: ItemDisplay.fixed,
          tags: ['tp_display'],
        ),
        Tellraw(Entity.Self(), show: [
          TextComponent('Display entities spawned above you',
              color: Color.LightPurple),
        ]),
      ],
    );
  }
}

class InteractionShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Interaction entity'),
        Interaction(
          Location.here(),
          width: 1.0,
          height: 2.0,
          response: true,
          tags: ['tp_interact'],
        ),
        Tellraw(Entity.Self(), show: [
          TextComponent(
              'Interaction entity placed. Left/Right click it!',
              color: Color.Aqua),
        ]),
      ],
    );
  }
}

class BossbarShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Bossbar('template:main', name: 'Template Pack').set(value: 75),
        Bossbar('template:main', name: 'Template Pack').show(Entity.Self()),
        Tellraw(Entity.Self(), show: [
          TextComponent('Bossbar updated & shown', color: Color.Gold),
        ]),
      ],
    );
  }
}

class ScheduleShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Timeout / Schedule'),
        Timeout(
          'delayed_hello',
          ticks: 40.ticks,
          children: [
            Tellraw(Entity.All(), show: [
              TextComponent(
                  'This message was delayed by 2 seconds!',
                  color: Color.Green),
            ]),
          ],
        ),
        Tellraw(Entity.Self(), show: [
          TextComponent('Scheduled a message in 2 seconds...',
              color: Color.Gray),
        ]),
      ],
    );
  }
}

class RepeatShowcase extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Repeat'),
        Repeat(
          'countdown',
          to: 5,
          ticks: 20.ticks,
          child: Tellraw(Entity.All(), show: [
            TextComponent('Countdown tick!', color: Color.Yellow),
          ]),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// UNINSTALL
// ---------------------------------------------------------------------------
class Uninstall extends Widget {
  @override
  Widget generate(Context context) {
    return Group(
      children: [
        Comment('Clean up everything'),
        Scoreboard.remove('config'),
        Scoreboard.remove('counter'),
        Scoreboard.remove('gui_click'),
        Scoreboard.remove('random'),
        Scoreboard.remove('ray_dist'),
        Scoreboard.remove('temp'),
        Scoreboard.remove('trigger_val'),
        Team.empty('template_red'),
        Team.empty('template_blue'),
        Command('team remove template_red'),
        Command('team remove template_blue'),
        Bossbar('template:main', name: 'Template Pack').remove(),
        Kill(Entity(tags: ['tp_gui'])),
        Kill(Entity(tags: ['tp_marker'])),
        Kill(Entity(tags: ['tp_display'])),
        Kill(Entity(tags: ['tp_interact'])),
        Tellraw(Entity.All(), show: [
          TextComponent('Template Pack fully uninstalled.',
              color: Color.Red),
        ]),
      ],
    );
  }
}
