// Native TGUI rebuild of the classic Body Markings popup. One flat data
// shape (per-zone ordered list of marking name -> color) drives a single
// generic panel — see character_sheet_markings_ui.dm. Styled to match
// CharacterSheet.tsx / CharacterCustomizers.tsx.
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Section, Stack } from 'tgui-core/components';

type BackendAct = (action: string, payload?: Record<string, unknown>) => void;

type MarkingRow = {
  name: string;
  color: string;
  index: number;
  can_move_up: boolean;
  can_move_down: boolean;
};

type ZoneRow = {
  zone: string;
  display_name: string;
  markings: MarkingRow[];
  can_add: boolean;
};

type Data = {
  zones: ZoneRow[];
  has_presets: boolean;
};

const MarkingLine = ({ zone, row, act }: { zone: string; row: MarkingRow; act: BackendAct }) => (
  <Stack align="center" mb={0.3}>
    <Stack.Item>
      <Button
        icon="arrow-up"
        disabled={!row.can_move_up}
        onClick={() => act('marking_move_up', { zone, name: row.name })}
      />
    </Stack.Item>
    <Stack.Item>
      <Button
        icon="arrow-down"
        disabled={!row.can_move_down}
        onClick={() => act('marking_move_down', { zone, name: row.name })}
      />
    </Stack.Item>
    <Stack.Item grow>
      <Button fluid onClick={() => act('change_marking', { zone, name: row.name })}>
        {row.name}
      </Button>
    </Stack.Item>
    <Stack.Item>
      <Box className="CharacterSheet__ColorSwatch" style={{ backgroundColor: `#${row.color}` }} />
    </Stack.Item>
    <Stack.Item>
      <Button icon="undo" onClick={() => act('reset_color', { zone, name: row.name })} />
    </Stack.Item>
    <Stack.Item>
      <Button icon="palette" onClick={() => act('change_color', { zone, name: row.name, color: row.color })} />
    </Stack.Item>
    <Stack.Item>
      <Button icon="trash" onClick={() => act('remove_marking', { zone, name: row.name })} />
    </Stack.Item>
  </Stack>
);

const ZoneCard = ({ row, act }: { row: ZoneRow; act: BackendAct }) => (
  <Section title={row.display_name}>
    {row.markings.map((marking) => (
      <MarkingLine key={marking.name} zone={row.zone} row={marking} act={act} />
    ))}
    {row.can_add && (
      <Button icon="plus" onClick={() => act('add_marking', { zone: row.zone })}>
        Add Marking
      </Button>
    )}
  </Section>
);

export const CharacterMarkings = () => {
  const { act, data } = useBackend<Data>();
  const zones = data.zones || [];

  return (
    <Window width={520} height={680}>
      <Window.Content scrollable>
        <Box className="CharacterSheet">
          <Stack vertical>
            <Stack.Item>
              <Section>
                <Stack>
                  {data.has_presets && (
                    <Stack.Item grow>
                      <Button fluid icon="magic" onClick={() => act('use_preset')}>
                        Use a Preset
                      </Button>
                    </Stack.Item>
                  )}
                  <Stack.Item grow>
                    <Button fluid icon="undo" onClick={() => act('reset_all_colors')}>
                      Reset All Colors
                    </Button>
                  </Stack.Item>
                </Stack>
              </Section>
            </Stack.Item>
            {zones.map((row) => (
              <Stack.Item key={row.zone}>
                <ZoneCard row={row} act={act} />
              </Stack.Item>
            ))}
          </Stack>
        </Box>
      </Window.Content>
    </Window>
  );
};
