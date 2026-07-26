// Native TGUI rebuild of the classic Customizers popup. Renders every
// customizer row (hair, eyes, horns, wings, tails, genitals, etc.)
// generically off the data shape built by
// modular_dreamvalley/campaign/character_sheet_customizers_ui.dm — most
// customizer types need nothing but the accessory dropdown + color swatches,
// a handful add a few extra scalar fields (extra_fields), rendered switching
// on `kind` rather than needing one React component per customizer type.
// Styled to match CharacterSheet.tsx / TATBuild.tsx's parchment/carved-inlay
// look so all three read as one continuous sheet.
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Dropdown, Section, Stack } from 'tgui-core/components';

type BackendAct = (action: string, payload?: Record<string, unknown>) => void;

type OptionMap = Record<string, string>;

type ExtraField = {
  key: string;
  label: string;
  kind: 'toggle' | 'color' | 'select' | 'button';
  value: string | boolean | null;
  options?: OptionMap;
};

type ColorRow = {
  index: number;
  label: string;
  color: string;
};

type CustomizerRow = {
  customizer_type: string;
  name: string;
  disabled: boolean;
  allows_disabling: boolean;
  choice_name: string;
  choice_options: OptionMap;
  accessory_name: string | null;
  accessory_options: OptionMap;
  allows_accessory_color_customization: boolean;
  color_rows: ColorRow[];
  extra_fields: ExtraField[];
};

type Data = {
  customizers: CustomizerRow[];
};

const FieldRow = ({ label, children }: { label: string; children: React.ReactNode }) => (
  <Stack align="center" mb={0.4}>
    <Stack.Item width="9.5em" className="CharacterSheet__FieldLabel">
      {label}
    </Stack.Item>
    <Stack.Item grow>{children}</Stack.Item>
  </Stack>
);

const ExtraFieldRow = ({
  field,
  customizerType,
  act,
}: {
  field: ExtraField;
  customizerType: string;
  act: BackendAct;
}) => {
  switch (field.kind) {
    case 'toggle':
      return (
        <FieldRow label={field.label}>
          <Button
            icon={field.value ? 'toggle-on' : 'toggle-off'}
            selected={!!field.value}
            onClick={() => act('set_extra_toggle', { customizer_type: customizerType, key: field.key })}
          >
            {field.value ? 'Yes' : 'No'}
          </Button>
        </FieldRow>
      );
    case 'color':
      return (
        <FieldRow label={field.label}>
          <Stack align="center">
            <Stack.Item>
              <Box className="CharacterSheet__ColorSwatch" style={{ backgroundColor: `#${field.value}` }} />
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() =>
                  act('set_extra_color', { customizer_type: customizerType, key: field.key, color: field.value })
                }
              >
                Change Color
              </Button>
            </Stack.Item>
          </Stack>
        </FieldRow>
      );
    case 'select':
      return (
        <FieldRow label={field.label}>
          <Dropdown
            fluid
            selected={(field.value as string) || undefined}
            options={Object.keys(field.options || {})}
            onSelected={(picked) => act('set_extra_select', { customizer_type: customizerType, key: field.key, value: picked })}
          />
        </FieldRow>
      );
    case 'button':
      return (
        <FieldRow label={field.label}>
          <Button onClick={() => act('set_extra_button', { customizer_type: customizerType, key: field.key })}>
            Open
          </Button>
        </FieldRow>
      );
    default:
      return null;
  }
};

const CustomizerCard = ({ row, act }: { row: CustomizerRow; act: BackendAct }) => (
  <Section title={row.name}>
    {row.allows_disabling && (
      <FieldRow label="Present">
        <Button
          icon={row.disabled ? 'toggle-off' : 'toggle-on'}
          selected={!row.disabled}
          onClick={() => act('toggle_missing', { customizer_type: row.customizer_type })}
        >
          {row.disabled ? 'No' : 'Yes'}
        </Button>
      </FieldRow>
    )}
    {!row.disabled && (
      <>
        {Object.keys(row.choice_options).length > 1 && (
          <FieldRow label="Type">
            <Dropdown
              fluid
              selected={row.choice_name}
              options={Object.keys(row.choice_options)}
              onSelected={(picked) => act('set_choice', { customizer_type: row.customizer_type, value: picked })}
            />
          </FieldRow>
        )}
        {Object.keys(row.accessory_options).length > 1 && (
          <FieldRow label="Appearance">
            <Dropdown
              fluid
              selected={row.accessory_name || undefined}
              options={Object.keys(row.accessory_options)}
              onSelected={(picked) => act('set_accessory', { customizer_type: row.customizer_type, value: picked })}
            />
          </FieldRow>
        )}
        {row.allows_accessory_color_customization && row.color_rows.length > 0 && (
          <>
            {row.color_rows.map((color_row) => (
              <FieldRow key={color_row.index} label={color_row.label}>
                <Stack align="center">
                  <Stack.Item>
                    <Box
                      className="CharacterSheet__ColorSwatch"
                      style={{ backgroundColor: `#${color_row.color}` }}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      onClick={() =>
                        act('set_accessory_color', {
                          customizer_type: row.customizer_type,
                          index: color_row.index,
                          color: color_row.color,
                        })
                      }
                    >
                      Change Color
                    </Button>
                  </Stack.Item>
                </Stack>
              </FieldRow>
            ))}
            <FieldRow label=" ">
              <Button icon="undo" onClick={() => act('reset_colors', { customizer_type: row.customizer_type })}>
                Reset Colors
              </Button>
            </FieldRow>
          </>
        )}
        {row.extra_fields.map((field) => (
          <ExtraFieldRow key={field.key} field={field} customizerType={row.customizer_type} act={act} />
        ))}
      </>
    )}
  </Section>
);

export const CharacterCustomizers = () => {
  const { act, data } = useBackend<Data>();
  const customizers = data.customizers || [];

  return (
    <Window width={480} height={640}>
      <Window.Content scrollable>
        <Box className="CharacterSheet">
          <Stack vertical>
            {customizers.map((row) => (
              <Stack.Item key={row.customizer_type}>
                <CustomizerCard row={row} act={act} />
              </Stack.Item>
            ))}
          </Stack>
        </Box>
      </Window.Content>
    </Window>
  );
};
