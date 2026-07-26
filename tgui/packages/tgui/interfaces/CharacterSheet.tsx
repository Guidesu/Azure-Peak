import { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import {
  Box,
  Button,
  Dropdown,
  Input,
  NumberInput,
  Stack,
} from 'tgui-core/components';

import { DraggableTile } from './common/DraggableTile';

type BackendAct = (action: string, payload?: Record<string, unknown>) => void;

type OptionMap = Record<string, string>;

type Charflaw = {
  name: string;
  desc: string;
};

type Data = {
  real_name: string;
  nickname: string;
  pronouns: string;
  pronoun_options: string[];
  titles_pref: string;
  titles_options: string[];
  clothes_pref: string;
  clothes_options: string[];
  voice_type: string;
  voice_type_options: string[];
  voice_pack: string;
  voice_pack_options: string[];
  combat_music: string | null;
  combat_music_options: string[];
  age: string;
  age_options: string[];
  species: string;
  species_options: OptionMap;
  subspecies: string;
  subspecies_options: OptionMap;
  origin: string | null;
  origin_options: OptionMap;
  race_bonus: string | null;
  race_bonus_options: string[];
  extra_language: string;
  extra_language_options: OptionMap;
  statpack: string | null;
  statpack_options: OptionMap;
  taur_type: string | null;
  taur_options: OptionMap;
  taur_color: string;
  faith: string | null;
  faith_options: OptionMap;
  patron: string | null;
  patron_options: OptionMap;

  // Vices
  charflaws: Charflaw[];
  charflaw_options: OptionMap;
  max_vices: number;
  has_averse_vice: boolean;
  averse_faction: string;
  averse_faction_options: string[];

  // Body / colors
  dominant_hand: string;
  skin_tone_wording: string;
  uses_skin_tones: boolean;
  skin_tone: string;
  skin_tone_options: OptionMap;
  uses_mutant_colors: boolean;
  mutant_color: string;
  mutant_color2: string;
  mutant_color3: string;
  update_mutant_colors: boolean;
  body_size: number;

  // Voice / bark
  highlight_color: string;
  voice_color: string;
  voice_pitch: number;
  bark_sound: string | null;
  bark_options: OptionMap;
  bark_speed: number;
  bark_pitch: number;
  bark_variance: number;

  // Flavor / OOC text
  flavortext: string | null;
  nsfwflavortext: string | null;
  ooc_notes: string | null;
  rumour: string | null;
  noble_gossip: string | null;
  erpprefs: string | null;
  ooc_extra: string | null;
  song_title: string | null;
  song_artist: string | null;
  headshot_link: string | null;
  examine_theme: string;
  examine_theme_options: OptionMap;
  img_gallery: string[];
  nsfw_img_gallery: string[];

  // Estate (ported Manors system)
  have_manor: boolean;
  manor_name: string;
  manor_type: string;
  manor_type_display: string;
  manor_type_options: string[];

  // Hub
  playerquality_text: string;
  triumphs_text: string;
  triumph_buys_enabled: boolean;
  agevetted: boolean;
  current_quirks: string;
  roundstart_traits_enabled: boolean;
  preview_url: string | null;
  preview_dir: number;
};

const optionKeys = (options: string[] | OptionMap | undefined): string[] => {
  if (!options) {
    return [];
  }
  return Array.isArray(options) ? options : Object.keys(options);
};

const FieldRow = ({ label, children }: { label: string; children: ReactNode }) => (
  <Stack align="center" mb={0.4}>
    <Stack.Item width="9.5em" className="CharacterSheet__FieldLabel">
      {label}
    </Stack.Item>
    <Stack.Item grow>{children}</Stack.Item>
  </Stack>
);

const SelectField = ({
  label,
  value,
  options,
  act,
  action,
  placeholder,
  extra,
}: {
  label: string;
  value: string | null | undefined;
  options: string[] | OptionMap | undefined;
  act: BackendAct;
  action: string;
  placeholder?: string;
  extra?: ReactNode;
}) => (
  <FieldRow label={label}>
    <Stack align="center">
      <Stack.Item grow>
        <Dropdown
          fluid
          selected={value || undefined}
          placeholder={placeholder || 'None available'}
          options={optionKeys(options)}
          onSelected={(picked) => act(action, { value: picked })}
        />
      </Stack.Item>
      {!!extra && <Stack.Item>{extra}</Stack.Item>}
    </Stack>
  </FieldRow>
);

const ColorField = ({
  label,
  color,
  act,
  action,
}: {
  label: string;
  color: string;
  act: BackendAct;
  action: string;
}) => (
  <FieldRow label={label}>
    <Stack align="center">
      <Stack.Item>
        <Box className="CharacterSheet__ColorSwatch" style={{ backgroundColor: `#${color}` }} />
      </Stack.Item>
      <Stack.Item>
        <Button onClick={() => act(action)}>Change Color</Button>
      </Stack.Item>
    </Stack>
  </FieldRow>
);

const TextField = ({
  label,
  value,
  minLength,
  action,
  act,
  warn,
}: {
  label: string;
  value: string | null;
  minLength?: number;
  action: string;
  act: BackendAct;
  warn?: boolean;
}) => (
  <FieldRow label={label}>
    <Stack align="center">
      <Stack.Item grow color={warn ? 'bad' : undefined}>
        {value ? `${value.length} characters set` : 'Not set'}
        {!!minLength && !value && ` (minimum ${minLength})`}
      </Stack.Item>
      <Stack.Item>
        <Button onClick={() => act(action)}>Edit</Button>
      </Stack.Item>
    </Stack>
  </FieldRow>
);

const GalleryField = ({
  label,
  images,
  addAction,
  clearAction,
  act,
}: {
  label: string;
  images: string[];
  addAction: string;
  clearAction: string;
  act: BackendAct;
}) => (
  <FieldRow label={label}>
    <Stack align="center">
      <Stack.Item grow>{images.length} / 3 images</Stack.Item>
      <Stack.Item>
        <Button icon="plus" disabled={images.length >= 3} onClick={() => act(addAction)}>
          Add
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="trash" disabled={!images.length} onClick={() => act(clearAction)}>
          Clear
        </Button>
      </Stack.Item>
    </Stack>
  </FieldRow>
);

export const CharacterSheet = () => {
  const { act, data } = useBackend<Data>();

  if (!data.species) {
    return (
      <Window title="Character Sheet" width={1180} height={820}>
        <Window.Content>
          <Stack align="center" justify="center" fill>
            <Stack.Item>Loading character data...</Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

  const taurOptions: OptionMap = { None: 'None', ...data.taur_options };

  return (
    <Window title="Character Sheet" width={1180} height={820}>
      <Window.Content scrollable>
        <Box className="CharacterSheet">
          <div className="CharacterSheet__Shell">
            <div className="CharacterSheet__PortraitCol">
              <div className="CharacterSheet__Tile CharacterSheet__Tile--portrait">
                <div className="CharacterSheet__TileHeader">Portrait</div>
                <div className="CharacterSheet__TileBody CharacterSheet__TileBody--portrait">
                  <Box
                    className="CharacterSheet__PortraitFrame"
                    style={{
                      backgroundImage: data.preview_url ? `url(${data.preview_url})` : undefined,
                    }}
                  />
                  <Button fluid icon="sync-alt" onClick={() => act('spin_preview')}>
                    Turn
                  </Button>
                </div>
              </div>

              <div className="CharacterSheet__Tile">
                <div className="CharacterSheet__TileHeader">Hub</div>
                <div className="CharacterSheet__TileBody">
                  <Stack vertical>
                    <Stack.Item>
                      <Button fluid icon="floppy-disk" onClick={() => act('save_sheet')}>
                        Save
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="user-group" onClick={() => act('change_slot')}>
                        Change Character
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="skull" onClick={() => act('open_villain_selection')}>
                        Villain Selection
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="scroll" onClick={() => act('open_lore_primer')}>
                        Lore Primer
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="list" onClick={() => act('open_changelog')}>
                        Changelog
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="chart-simple" onClick={() => act('open_playerquality')}>
                        PQ: {data.playerquality_text}
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="trophy" onClick={() => act('open_triumphs')}>
                        Triumphs: {data.triumphs_text}
                      </Button>
                    </Stack.Item>
                    {!!data.triumph_buys_enabled && (
                      <Stack.Item>
                        <Button fluid icon="coins" onClick={() => act('open_triumph_buy_menu')}>
                          Triumph Buy
                        </Button>
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Button fluid icon="id-card" selected={data.agevetted} onClick={() => act('open_agevet')}>
                        Verified: {data.agevetted ? 'Yes' : 'No'}
                      </Button>
                    </Stack.Item>
                  </Stack>
                  {!!data.roundstart_traits_enabled && (
                    <Box color="label" mt={0.5}>Current Quirks: {data.current_quirks}</Box>
                  )}
                </div>
              </div>

              <div className="CharacterSheet__Tile CharacterSheet__Tile--callout">
                <div className="CharacterSheet__TileHeader">Ready to Play?</div>
                <div className="CharacterSheet__TileBody">
                  <Box color="label" mb={0.5}>
                    Stats, traits, skills and items are set up in TAT Build — that screen is also where you Join the
                    World.
                  </Box>
                  <Button
                    fluid
                    bold
                    className="CharacterSheet__SealButton"
                    icon="dungeon"
                    onClick={() => act('open_tat')}
                  >
                    Open TAT Build
                  </Button>
                </div>
              </div>
            </div>

            <div className="CharacterSheet__Grid CharacterSheet__Grid--free">
              <DraggableTile
                storageKey="identity"
                title="Identity"
                defaultRect={{ x: 0, y: 0, w: 480, h: 260 }}
              >
                  <FieldRow label="Name">
                    <Input fluid value={data.real_name} onEnter={(value) => act('set_name', { value })} />
                  </FieldRow>
                  <FieldRow label="Nickname">
                    <Input fluid value={data.nickname} onEnter={(value) => act('set_nickname', { value })} />
                  </FieldRow>
                  <SelectField label="Pronouns" value={data.pronouns} options={data.pronoun_options} act={act} action="set_pronouns" />
                  <SelectField label="Titles" value={data.titles_pref} options={data.titles_options} act={act} action="set_titles_pref" />
                  <SelectField label="Clothing" value={data.clothes_pref} options={data.clothes_options} act={act} action="set_clothes_pref" />
                  <SelectField label="Dominant Hand" value={data.dominant_hand} options={['Left-handed', 'Right-handed']} act={act} action="set_domhand" />
                  <ColorField label="Nickname Color" color={data.highlight_color} act={act} action="set_highlight_color" />
              </DraggableTile>

              <DraggableTile
                storageKey="heritage"
                title="Heritage"
                defaultRect={{ x: 490, y: 0, w: 480, h: 260 }}
              >
                  <SelectField label="Species" value={data.species} options={data.species_options} act={act} action="set_species" />
                  <SelectField label="Subrace" value={data.subspecies} options={data.subspecies_options} act={act} action="set_subspecies" />
                  <SelectField
                    label="Origin"
                    value={data.origin}
                    options={data.origin_options}
                    act={act}
                    action="set_origin"
                    extra={
                      <Stack>
                        <Stack.Item>
                          <Button icon="map" onClick={() => act('open_origin_map')}>
                            Map
                          </Button>
                        </Stack.Item>
                        <Stack.Item>
                          <Button icon="book" onClick={() => act('open_origin_lore')}>
                            Lore
                          </Button>
                        </Stack.Item>
                      </Stack>
                    }
                  />
                  {!!optionKeys(data.race_bonus_options).length && (
                    <SelectField label="Racial Bonus" value={data.race_bonus} options={data.race_bonus_options} act={act} action="set_race_bonus" />
                  )}
                  <SelectField
                    label="Extra Language"
                    value={data.extra_language}
                    options={data.extra_language_options}
                    act={act}
                    action="set_extra_language"
                  />
                  <SelectField label="Statpack" value={data.statpack} options={data.statpack_options} act={act} action="set_statpack" />
              </DraggableTile>

              <DraggableTile
                storageKey="voice"
                title="Voice & Sound"
                defaultRect={{ x: 980, y: 0, w: 340, h: 420 }}
              >
                  <SelectField label="Voice Type" value={data.voice_type} options={data.voice_type_options} act={act} action="set_voice_type" />
                  <SelectField
                    label="Voice Pack"
                    value={data.voice_pack}
                    options={data.voice_pack_options}
                    act={act}
                    action="set_voice_pack"
                    extra={
                      <Button
                        icon="play"
                        tooltip="Preview"
                        disabled={data.voice_pack === 'Default'}
                        onClick={() => act('preview_voice_pack')}
                      />
                    }
                  />
                  <ColorField label="Voice Color" color={data.voice_color} act={act} action="set_voice_color" />
                  <FieldRow label="Voice Pitch">
                    <NumberInput
                      width="5em"
                      step={0.05}
                      stepPixelSize={5}
                      minValue={0.5}
                      maxValue={1.5}
                      value={data.voice_pitch}
                      format={(v) => v.toFixed(2)}
                      onChange={(value) => act('set_voice_pitch', { value })}
                    />
                  </FieldRow>
                  <SelectField
                    label="Combat Music"
                    value={data.combat_music}
                    options={data.combat_music_options}
                    act={act}
                    action="set_combat_music"
                    placeholder="Default"
                  />
                  <SelectField label="Bark Sound" value={data.bark_sound} options={data.bark_options} act={act} action="set_bark_sound"
                    extra={<Button icon="play" tooltip="Preview" onClick={() => act('preview_bark')} />}
                  />
                  <FieldRow label="Bark Speed">
                    <NumberInput width="5em" step={1} stepPixelSize={5} value={data.bark_speed} onChange={(value) => act('set_bark_speed', { value })} />
                  </FieldRow>
                  <FieldRow label="Bark Pitch">
                    <NumberInput width="5em" step={0.1} stepPixelSize={5} value={data.bark_pitch} format={(v) => v.toFixed(1)} onChange={(value) => act('set_bark_pitch', { value })} />
                  </FieldRow>
                  <FieldRow label="Bark Variance">
                    <NumberInput width="5em" step={0.05} stepPixelSize={5} value={data.bark_variance} format={(v) => v.toFixed(2)} onChange={(value) => act('set_bark_variance', { value })} />
                  </FieldRow>
              </DraggableTile>

              <DraggableTile
                storageKey="body"
                title="Body"
                defaultRect={{ x: 0, y: 270, w: 480, h: 320 }}
              >
                  <SelectField label="Age" value={data.age} options={data.age_options} act={act} action="set_age" />
                  <SelectField
                    label="Taur Body"
                    value={data.taur_type || 'None'}
                    options={taurOptions}
                    act={act}
                    action="set_taur_type"
                  />
                  <ColorField label="Taur Color" color={data.taur_color} act={act} action="set_taur_color" />
                  {!!data.uses_skin_tones && (
                    <SelectField
                      label={data.skin_tone_wording || 'Skin Tone'}
                      value={data.skin_tone}
                      options={data.skin_tone_options}
                      act={act}
                      action="set_skin_tone"
                    />
                  )}
                  {!!data.uses_mutant_colors && (
                    <>
                      <ColorField label="Mutant Color #1" color={data.mutant_color} act={act} action="set_mutant_color" />
                      <ColorField label="Mutant Color #2" color={data.mutant_color2} act={act} action="set_mutant_color2" />
                      <ColorField label="Mutant Color #3" color={data.mutant_color3} act={act} action="set_mutant_color3" />
                      <FieldRow label="Update Colors">
                        <Button
                          icon={data.update_mutant_colors ? 'toggle-on' : 'toggle-off'}
                          selected={data.update_mutant_colors}
                          onClick={() => act('toggle_update_mutant_colors')}
                        >
                          {data.update_mutant_colors ? 'Yes' : 'No'}
                        </Button>
                      </FieldRow>
                    </>
                  )}
                  <FieldRow label="Sprite Scale">
                    <NumberInput
                      width="5em"
                      step={1}
                      stepPixelSize={5}
                      unit="%"
                      value={data.body_size}
                      onChange={(value) => act('set_body_size', { value })}
                    />
                  </FieldRow>
              </DraggableTile>

              <DraggableTile
                storageKey="faith"
                title="Faith"
                defaultRect={{ x: 490, y: 270, w: 340, h: 160 }}
              >
                  <SelectField label="Faith" value={data.faith} options={data.faith_options} act={act} action="set_faith" />
                  <SelectField label="Patron" value={data.patron} options={data.patron_options} act={act} action="set_patron" />
              </DraggableTile>

              <DraggableTile
                storageKey="estate"
                title="Estate"
                defaultRect={{ x: 490, y: 440, w: 340, h: 200 }}
              >
                  <FieldRow label="Landed">
                    <Button
                      icon={data.have_manor ? 'toggle-on' : 'toggle-off'}
                      selected={data.have_manor}
                      onClick={() => act('toggle_have_manor')}
                    >
                      {data.have_manor ? 'Yes' : 'No'}
                    </Button>
                  </FieldRow>
                  {!!data.have_manor && (
                    <>
                      <FieldRow label="Estate Name">
                        <Input fluid value={data.manor_name} onEnter={(value) => act('set_manor_name', { value })} />
                      </FieldRow>
                      <SelectField
                        label="Estate Type"
                        value={data.manor_type_display}
                        options={data.manor_type_options}
                        act={act}
                        action="set_manor_type"
                      />
                    </>
                  )}
              </DraggableTile>

              <DraggableTile
                storageKey="vices"
                title="Vices"
                defaultRect={{ x: 840, y: 270, w: 340, h: 260 }}
              >
                  {data.charflaws.map((cf) => (
                    <Stack key={cf.name} align="center" mb={0.3}>
                      <Stack.Item grow>
                        <b>{cf.name}</b>
                        {!!cf.desc && <Box color="label">{cf.desc}</Box>}
                      </Stack.Item>
                      <Stack.Item>
                        <Button icon="trash" onClick={() => act('remove_vice', { index: data.charflaws.indexOf(cf) + 1 })} />
                      </Stack.Item>
                    </Stack>
                  ))}
                  {data.charflaws.length < data.max_vices && (
                    <SelectField label="Add Vice" value={null} options={data.charflaw_options} act={act} action="add_vice" placeholder="Choose a vice..." />
                  )}
                  {!!data.has_averse_vice && (
                    <SelectField label="Loathed Group" value={data.averse_faction} options={data.averse_faction_options} act={act} action="set_averse_faction" />
                  )}
              </DraggableTile>

              <DraggableTile
                storageKey="other"
                title="Other"
                defaultRect={{ x: 840, y: 540, w: 340, h: 300 }}
              >
                  <Stack vertical>
                    <Stack.Item>
                      <Button fluid icon="shirt" onClick={() => act('open_loadout')}>
                        Loadout
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="utensils" onClick={() => act('open_culinary')}>
                        Food Preferences
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="palette" onClick={() => act('open_customizers')}>
                        Customizers
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="paw" onClick={() => act('open_markings')}>
                        Body Markings
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="book-open" onClick={() => act('open_descriptors')}>
                        Descriptors
                      </Button>
                    </Stack.Item>
                    <Stack.Item>
                      <Button fluid icon="dragon" onClick={() => act('open_familiar_prefs')}>
                        Familiar Preferences
                      </Button>
                    </Stack.Item>
                  </Stack>
              </DraggableTile>

              <DraggableTile
                storageKey="flavor"
                title="Flavor & OOC"
                defaultRect={{ x: 0, y: 600, w: 560, h: 420 }}
              >
                  <TextField label="Flavortext" value={data.flavortext} action="set_flavortext" act={act} warn={!data.flavortext} />
                  <TextField label="NSFW Flavortext" value={data.nsfwflavortext} action="set_nsfwflavortext" act={act} />
                  <TextField label="OOC Notes" value={data.ooc_notes} action="set_ooc_notes" act={act} />
                  <TextField label="Rumours" value={data.rumour} action="set_rumour" act={act} />
                  <TextField label="Noble Gossip" value={data.noble_gossip} action="set_gossip" act={act} />
                  <FieldRow label="">
                    <Button icon="eye" onClick={() => act('preview_rumour')}>
                      Preview Rumours &amp; Gossip
                    </Button>
                  </FieldRow>
                  <TextField label="ERP Preferences" value={data.erpprefs} action="set_erpprefs" act={act} />
                  <FieldRow label="Song URL">
                    <Stack align="center">
                      <Stack.Item grow>{data.ooc_extra || 'Not set'}</Stack.Item>
                      <Stack.Item>
                        <Button onClick={() => act('set_song_url')}>Edit</Button>
                      </Stack.Item>
                    </Stack>
                  </FieldRow>
                  <FieldRow label="Song Title">
                    <Input fluid value={data.song_title || ''} onEnter={(value) => act('set_song_title', { value })} />
                  </FieldRow>
                  <FieldRow label="Song Artist">
                    <Input fluid value={data.song_artist || ''} onEnter={(value) => act('set_song_artist', { value })} />
                  </FieldRow>
                  <FieldRow label="Headshot">
                    <Stack align="center">
                      <Stack.Item grow>{data.headshot_link || 'Not set'}</Stack.Item>
                      <Stack.Item>
                        <Button onClick={() => act('set_headshot')}>Edit</Button>
                      </Stack.Item>
                    </Stack>
                  </FieldRow>
                  {!!data.headshot_link && (
                    <FieldRow label="">
                      <img src={data.headshot_link} style={{ width: '100px', height: '100px' }} />
                    </FieldRow>
                  )}
                  <SelectField label="Examine Theme" value={data.examine_theme} options={data.examine_theme_options} act={act} action="set_examine_theme" />
                  <GalleryField label="Image Gallery" images={data.img_gallery} addAction="add_gallery_image" clearAction="clear_gallery" act={act} />
                  <GalleryField label="NSFW Gallery" images={data.nsfw_img_gallery} addAction="add_nsfw_gallery_image" clearAction="clear_nsfw_gallery" act={act} />
                  <FieldRow label="">
                    <Button icon="user" onClick={() => act('preview_examine')}>
                      Preview Examine Panel
                    </Button>
                  </FieldRow>
              </DraggableTile>
            </div>
          </div>
        </Box>
      </Window.Content>
    </Window>
  );
};

export default CharacterSheet;
