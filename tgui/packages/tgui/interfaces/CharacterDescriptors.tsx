// Native TGUI rebuild of the classic Descriptors popup. Two uniform shapes:
// a dropdown per species descriptor_choice, and a fixed-size list of custom
// descriptor slots (optional prefix dropdown + free-text content). See
// character_sheet_descriptors_ui.dm.
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Dropdown, Section, Stack, TextArea } from 'tgui-core/components';

type BackendAct = (action: string, payload?: Record<string, unknown>) => void;

type DescriptorChoice = {
  choice_type: string;
  name: string;
  current: string;
  options: Record<string, string>;
};

type CustomDescriptor = {
  index: number;
  name: string;
  has_prefix: boolean;
  prefix_display: string | null;
  prefix_options: Record<string, number>;
  content_text: string;
};

type Data = {
  choices: DescriptorChoice[];
  custom_descriptors: CustomDescriptor[];
};

const FieldRow = ({ label, children }: { label: string; children: React.ReactNode }) => (
  <Stack align="center" mb={0.4}>
    <Stack.Item width="11em" className="CharacterSheet__FieldLabel">
      {label}
    </Stack.Item>
    <Stack.Item grow>{children}</Stack.Item>
  </Stack>
);

const CustomDescriptorRow = ({ row, act }: { row: CustomDescriptor; act: BackendAct }) => {
  const [draft, setDraft] = useState(row.content_text);
  return (
    <FieldRow label={row.name}>
      <Stack align="center">
        {row.has_prefix && (
          <Stack.Item>
            <Dropdown
              selected={row.prefix_display || undefined}
              options={Object.keys(row.prefix_options)}
              onSelected={(picked) => act('set_custom_prefix', { index: row.index, value: picked })}
            />
          </Stack.Item>
        )}
        <Stack.Item grow>
          <TextArea
            value={draft}
            height="2.2em"
            onChange={(value) => setDraft(value)}
            onBlur={() => act('set_custom_content', { index: row.index, value: draft })}
          />
        </Stack.Item>
      </Stack>
    </FieldRow>
  );
};

export const CharacterDescriptors = () => {
  const { act, data } = useBackend<Data>();
  const choices = data.choices || [];
  const customDescriptors = data.custom_descriptors || [];

  return (
    <Window width={460} height={560}>
      <Window.Content scrollable>
        <Box className="CharacterSheet">
          <Stack vertical>
            <Stack.Item>
              <Section title="Descriptors">
                {choices.map((choice) => (
                  <FieldRow key={choice.choice_type} label={choice.name}>
                    <Dropdown
                      fluid
                      selected={choice.current}
                      options={Object.keys(choice.options)}
                      onSelected={(picked) => act('set_descriptor', { choice_type: choice.choice_type, value: picked })}
                    />
                  </FieldRow>
                ))}
              </Section>
            </Stack.Item>
            {customDescriptors.length > 0 && (
              <Stack.Item>
                <Section title="Custom Descriptors">
                  {customDescriptors.map((row) => (
                    <CustomDescriptorRow key={row.index} row={row} act={act} />
                  ))}
                  <Stack.Item color="label" mt={0.5}>
                    No proper nouns. No immersion-breaking words. No overtly sexual descriptors. Capitalization is
                    handled automatically.
                  </Stack.Item>
                </Section>
              </Stack.Item>
            )}
            <Stack.Item>
              <Button fluid icon="comment" onClick={() => act('print_descriptor_setup')}>
                Print Descriptor Setup to Chat
              </Button>
            </Stack.Item>
          </Stack>
        </Box>
      </Window.Content>
    </Window>
  );
};
