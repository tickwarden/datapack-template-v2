// ---------------------------------------------------------------------------
// Template Pack – pure objD (MAXIMUM FEATURE SHOWCASE) – FULL FIXED
// Target: Minecraft 1.20.1 (pack_format 15)
// No objd_gui, no @p, no tellraw menu
// ---------------------------------------------------------------------------

import 'package:objd/core.dart';

const int kPackFormat = 15; // 1.20 – 1.20.1
const String kNamespace = 'template';

// GUI button IDs
const int kGuiGreet = 1;
const int kGuiReset = 2;
const int kGuiRandom = 3;
const int kGuiRaycast = 4;
const int kGuiStorage = 5;
const int kGuiTeam = 6;

Project buildProject() => Project(
      name: 'Template Pack',
      version: 20,
      target: './build/',
      description:
          'Ultimate pure objD Template Pack – MC 1.20.1 (Chest GUI + major features)',
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
        Scoreboard('gui_click'),
        Scoreboard('random'),
        Scoreboard('ray_dist'),
        Scoreboard('temp'),
        Scoreboard.trigger('trigger_val'),

        // Teams
        Team.add(
          'template_red',
          color: Color.Red,
          display: TextComponent('Template Red', color: Color.Red),
          friendlyFire: false,
          collision: ModifyTeam.never,
        ),
        Team.add(
          'template_blue',
          color: Color.Blue,
          display: TextComponent('Template Blue', color: Color.Blue),
          friendlyFire: false,
          collision: ModifyTeam.never,
        ),

        // Global Storage
        Storage('data').merge({
          'initialized': true,
          'version': 1,
          'message': 'Hello from Storage!',
        }),

        // Bossbar – name MUST be non-null (objD null-check in generate)
        Bossbar('template:main', name: 'Template Pack'),
        Bossbar('template:main', name: 'Template Pack').set(
          nameTexts: [
            TextComponent('Template Pack', color: Color.Gold, bold: true),
          ],
          color: Color.Yellow,
          style: 'progress',
          max: 100,
          value: 0,
          visible: true,
        ),

        // Player join / rejoin
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
        Comment('=== MAIN TICK ==='),

        // Per-player counter every 10 seconds
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

        // Chest GUI tick
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
            Tellraw(Entity.Self(), show: [
              TextComponent('You triggered value: ', color: Color.Yellow),
              TextComponent.score(
                Score(Entity.Self(), 'trigger_val'),
                color: Color.Aqua,
              ),
            ]),
            Score(Entity.Self(), 'trigger_val').set(0),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// CHEST GUI
// ---------------------------------------------------------------------------
class ChestGuiTick extends Widget {
  @override
  Widget generate(Context context) {
    final click = Score(Entity.Self(), 'gui_click');

    return Group(
      children: [
        Comment('Detect button clicks'),

        // Slot 12 – Greet
        If(
          Condition.not(Condition.data(
              Data.get(Location.here(), path: 'Items[{Slot:12b}]'))),
          then: [
            Execute.as(Entity.All(distance: Range.to(8)), children: [
              Title(Entity.Self(),
                  show: [TextComponent('Hello!', color: Color.Yellow)]),
              Tellraw(Entity.Self(), show: [
                TextComponent('Greet button clicked!', color: Color.Green)
              ]),
              click.set(kGuiGreet),
            ]),
          ],
        ),

        // Slot 14 – Reset
        If(
          Condition.not(Condition.data(
              Data.get(Location.here(), path: 'Items[{Slot:14b}]'))),
          then: [
            Execute.as(Entity.All(distance: Range.to(8)), children: [
              Score(Entity.Self(), 'counter').set(0),
              Tellraw(Entity.Self(), show: [
                TextComponent('Counter reset!', color: Color.Aqua)
              ]),
              click.set(kGuiReset),
            ]),
          ],
        ),

        // Slot 10 – Random
        If(
          Condition.not(Condition.data(
              Data.get(Location.here(), path: 'Items[{Slot:10b}]'))),
          then: [
            Execute.as(Entity.All(distance: Range.to(8)), children: [
              File.execute('showcase/random', create: false),
              click.set(kGuiRandom),
            ]),
          ],
        ),

        // Slot 16 – Raycast
        If(
          Condition.not(Condition.data(
              Data.get(Location.here(), path: 'Items[{Slot:16b}]'))),
          then: [
            Execute.as(Entity.All(distance: Range.to(8)), children: [
              File.execute('showcase/raycast', create: false),
              click.set(kGuiRaycast),
            ]),
          ],
        ),

        Comment('Refill chest GUI every tick'),
        Data.merge(
          Location.here(),
          nbt: {
            'Items': [
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
              {
                'Slot': 10,
                'id': 'minecraft:diamond',
                'Count': 1,
                'tag': {
                  'display': {
                    'Name':
                        '{"text":"Random Score","color":"aqua","bold":true}',
                    'Lore': [
                      '{"text":"Gives you a random number","color":"gray"}'
                    ],
                  },
                },
              },
              {
                'Slot': 12,
                'id': 'minecraft:emerald',
                'Count': 1,
                'tag': {
                  'display': {
                    'Name': '{"text":"Greet","color":"green","bold":true}',
                    'Lore': [
                      '{"text":"Click to say Hello!","color":"gray"}'
                    ],
                  },
                },
              },
              {
                'Slot': 14,
                'id': 'minecraft:redstone',
                'Count': 1,
                'tag': {
                  'display': {
                    'Name':
                        '{"text":"Reset counter","color":"red","bold":true}',
                    'Lore': [
                      '{"text":"Sets your counter to 0","color":"gray"}'
                    ],
                  },
                },
              },
              {
                'Slot': 16,
                'id': 'minecraft:ender_pearl',
                'Count': 1,
                'tag': {
                  'display': {
                    'Name':
                        '{"text":"Raycast Demo","color":"light_purple","bold":true}',
                    'Lore': [
                      '{"text":"Shoots a ray and places a block","color":"gray"}'
                    ],
                  },
                },
              },
              for (final s in [
                0, 1, 2, 3, 5, 6, 7, 8,
                9, 11, 13, 15, 17,
                18, 19, 20, 21, 22, 23, 24, 25, 26
              ])
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
// SHOWCASE WIDGETS
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
