import { useState } from 'react';
import { Box, Icon, Section, Stack, Tabs } from 'tgui-core/components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type SkillEntry = {
  name: string;
  desc: string;
  level: string;
  level_num: number;
  xp_percent: number;
  capped: boolean;
  legendary: boolean;
  can_advance: boolean;
  can_advance_post: boolean;
  color?: string;
  trait_gated: boolean;
  trait_uncap?: Record<string, number>;
};

type FlawEntry = {
  name: string;
  desc: string;
  sated: boolean | null;
};

type LangEntry = {
  name: string;
  key: string;
};

type TraitEntry = {
  name: string;
  desc: string;
};

type Data = {
  skills: SkillEntry[];
  charflaws: FlawEntry[];
  languages: LangEntry[];
  traits: TraitEntry[];
};

const XP_COLORS: Record<string, string> = {
  low: '#e74c3c',
  mid: '#f39c12',
  high: '#27ae60',
};

const getXPColor = (percent: number): string => {
  if (percent < 33) return XP_COLORS.low;
  if (percent < 66) return XP_COLORS.mid;
  return XP_COLORS.high;
};

const stripHtml = (s: string): string => {
  if (!s) return '';
  return s.replace(/<[^>]*>/g, '');
};

export const SkillsTraits = (_props, context) => {
  const { data } = useBackend<Data>(context);
  const [tab, setTab] = useLocalState<string>(context, 'stab', 'skills');

  return (
    <Window width={520} height={600} theme="azure_green">
      <Window.Content scrollable>
        <Tabs fluid>
          <Tabs.Tab
            icon="fas fa-sword"
            selected={tab === 'skills'}
            onClick={() => setTab('skills')}
          >
            Skills ({data.skills.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="fas fa-mask"
            selected={tab === 'flaws'}
            onClick={() => setTab('flaws')}
          >
            Flaws ({data.charflaws.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="fas fa-language"
            selected={tab === 'languages'}
            onClick={() => setTab('languages')}
          >
            Languages ({data.languages.length})
          </Tabs.Tab>
          <Tabs.Tab
            icon="fas fa-star"
            selected={tab === 'traits'}
            onClick={() => setTab('traits')}
          >
            Traits ({data.traits.length})
          </Tabs.Tab>
        </Tabs>

        {tab === 'skills' && <SkillsTab skills={data.skills} />}
        {tab === 'flaws' && <FlawsTab flaws={data.charflaws} />}
        {tab === 'languages' && <LanguagesTab langs={data.languages} />}
        {tab === 'traits' && <TraitsTab traits={data.traits} />}
      </Window.Content>
    </Window>
  );
};

const SkillsTab = ({ skills }: { skills: SkillEntry[] }) => {
  if (!skills.length) {
    return (
      <Section>
        <Box color="warning" align="center">
          I don't have any skills.
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Skills">
      <Stack vertical>
        {skills.map((skill, i) => (
          <Stack.Item key={i}>
            <Stack align="center">
              <Stack.Item grow basis="50%">
                <Box as="span" style={{ color: skill.color || 'inherit' }} bold>
                  {skill.name}
                </Box>
                {skill.trait_gated && (
                  <Box
                    as="span"
                    ml={1}
                    style={{ fontSize: '9px', opacity: 0.6 }}
                    color="label"
                  >
                    (trait-gated)
                  </Box>
                )}
              </Stack.Item>
              <Stack.Item basis="25%" style={{ whiteSpace: 'nowrap' }}>
                <Box bold>{skill.level}</Box>
                {skill.can_advance_post && (
                  <Box as="span" color="green" style={{ fontSize: '10px' }}>
                    {' ★'}
                  </Box>
                )}
                {skill.can_advance && !skill.can_advance_post && (
                  <Box as="span" color="green" style={{ fontSize: '10px' }}>
                    {' ☆'}
                  </Box>
                )}
              </Stack.Item>
              <Stack.Item basis="25%" style={{ whiteSpace: 'nowrap' }}>
                {skill.legendary ? (
                  <Box color="green" bold>
                    Legendary
                  </Box>
                ) : skill.capped ? (
                  <Box color="red" bold>
                    CAPPED
                  </Box>
                ) : (
                  <Box style={{ color: getXPColor(skill.xp_percent) }}>
                    {skill.xp_percent}%
                  </Box>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        ))}
      </Stack>
      <Box mt={2} color="label" style={{ fontSize: '11px' }}>
        ☆ = ready to advance | ★ = ready for post-cap advance
      </Box>
    </Section>
  );
};

const FlawsTab = ({ flaws }: { flaws: FlawEntry[] }) => {
  if (!flaws.length) {
    return (
      <Section>
        <Box color="label" align="center">
          I have no character flaws.
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Character Flaws">
      <Stack vertical>
        {flaws.map((flaw, i) => (
          <Stack.Item key={i}>
            <Box bold color="danger">
              {flaw.name}
              {flaw.sated === true && (
                <Box as="span" color="purple" ml={1}>
                  {' '}
                  SATED
                </Box>
              )}
            </Box>
            <Box mt={0.5} color="label" style={{ fontSize: '12px' }}>
              {flaw.desc}
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const LanguagesTab = ({ langs }: { langs: LangEntry[] }) => {
  if (!langs.length) {
    return (
      <Section>
        <Box color="warning" align="center">
          I don't know any languages.
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Known Languages">
      <Stack vertical>
        {langs.map((lang, i) => (
          <Stack.Item key={i}>
            <Box>
              <Box as="span" bold color="info">
                {lang.name}
              </Box>
              <Box as="span" color="label" ml={1}>
                — {lang.key}
              </Box>
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const TraitsTab = ({ traits }: { traits: TraitEntry[] }) => {
  if (!traits.length) {
    return (
      <Section>
        <Box color="warning" align="center">
          I have no special traits.
        </Box>
      </Section>
    );
  }

  return (
    <Section title="Special Traits">
      <Stack vertical>
        {traits.map((trait, i) => (
          <Stack.Item key={i}>
            <Box bold>
              <Icon name="star" mr={1} style={{ fontSize: '10px' }} />
              {trait.name}
            </Box>
            <Box mt={0.5} color="label" style={{ fontSize: '12px' }}>
              {stripHtml(trait.desc)}
            </Box>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};
