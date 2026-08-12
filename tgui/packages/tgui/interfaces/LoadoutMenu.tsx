// Grid/icon layout ported from Twilight-Axis's tgui/packages/tgui/interfaces/LoadoutPanel.tsx
// (PR "New loadout menu"). All player-facing text translated from
// Russian into English. Kept this repo's own backend contract (color/detail/altdetail tweaking,
// custom name/desc, triumph-discount math via loadout_menu.dm) rather than adopting Twilight
// Axis's simpler data shape - the visual grid was the actual improvement worth porting.
import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Input,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  TextArea,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type LoadoutItem = {
  name: string;
  desc: string;
  category: string;
  cost: number;
  triumph_cost: number | null;
  color_channels: string[];
  icon: string | null;
  icon_state: string | null;
  is_donator_item: boolean;
  required_tier: number | null;
};

type SelectedItem = {
  name: string;
  color: string | null;
  detail_color: string | null;
  altdetail_color: string | null;
  custom_name: string | null;
  custom_desc: string | null;
};

type Data = {
  // Static
  categories: string[];
  items: LoadoutItem[];
  max_points: number;
  is_donator: boolean;
  triumph_discount: number;
  donator_bonus: number;
  // Dynamic
  selected: SelectedItem[];
  total_cost: number;
  total_triumph_cost: number;
  effective_triumph_cost: number;
  player_triumphs: number;
};

export const LoadoutMenu = () => {
  const { data } = useBackend<Data>();

  if (!data.categories || !data.items) {
    return (
      <Window width={1100} height={700}>
        <Window.Content>
          <Stack align="center" justify="center" fill>
            <Stack.Item fontSize={1.5}>Loading loadout data...</Stack.Item>
          </Stack>
        </Window.Content>
      </Window>
    );
  }

  return (
    <Window width={1100} height={700} title="Loadout">
      <Window.Content>
        <LoadoutDisplay />
      </Window.Content>
    </Window>
  );
};

/** Small inline color swatch */
const ColorSwatch = (props: {
  color: string;
  size?: number;
  onClick?: () => void;
}) => (
  <Box
    inline
    style={{
      width: `${(props.size || 0.9) * 12}px`,
      height: `${(props.size || 0.9) * 12}px`,
      marginLeft: '3px',
      backgroundColor: props.color,
      display: 'inline-block',
      border: '1px solid rgba(255,255,255,0.3)',
      borderRadius: '2px',
      verticalAlign: 'middle',
      cursor: props.onClick ? 'pointer' : undefined,
    }}
    onClick={props.onClick}
  />
);

/** Clickable color link: swatch + label, clicking opens the color picker modal */
const ColorLink = (props: {
  label: string;
  currentColor: string | null;
  action: string;
  itemName: string;
}) => {
  const { act } = useBackend<Data>();
  const { label, currentColor, action, itemName } = props;

  return (
    <Box inline mr={1.5}>
      <Box
        inline
        style={{ cursor: 'pointer' }}
        onClick={(e: React.MouseEvent) => {
          e.stopPropagation();
          act(action, { name: itemName });
        }}
      >
        <Box inline color="label" mr={0.5}>
          {label}:
        </Box>
        {currentColor ? (
          <ColorSwatch color={currentColor} size={1} />
        ) : (
          <Box inline color="average" fontSize={0.85}>
            None
          </Box>
        )}
      </Box>
      {currentColor && (
        <Box
          inline
          color="bad"
          ml={0.5}
          fontSize={0.8}
          style={{ cursor: 'pointer' }}
          onClick={(e: React.MouseEvent) => {
            e.stopPropagation();
            act(action, { name: itemName, clear: true });
          }}
        >
          &#x2715;
        </Box>
      )}
    </Box>
  );
};

/** Detail/tweak panel for the currently-selected (clicked) item in the grid - colors, custom name/desc */
const ItemDetailPanel = (props: {
  item: LoadoutItem;
  meta: SelectedItem | undefined;
  isSelected: boolean;
}) => {
  const { item, meta, isSelected } = props;
  const { act } = useBackend<Data>();

  const [localName, setLocalName] = useState(meta?.custom_name || '');
  const [localDesc, setLocalDesc] = useState(meta?.custom_desc || '');

  return (
    <Section title={item.name} fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <Box
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: '12px',
            }}
          >
            <DmIcon
              icon={item.icon ?? ''}
              icon_state={item.icon_state ?? ''}
              width={4}
              height={4}
              fallback={
                <Box
                  width={4}
                  height={4}
                  align="center"
                  verticalAlign="middle"
                  fontSize={0.8}
                  color="label"
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    justifyContent: 'center',
                    overflow: 'hidden',
                    textAlign: 'center',
                  }}
                >
                  {item.name.slice(0, 10)}
                </Box>
              }
            />
            <Box>
              <Box bold fontSize={1.1}>
                {item.name}
              </Box>
              <Box color="label" fontSize={0.9}>
                {item.cost}pt
                {item.triumph_cost ? ` + ${item.triumph_cost} triumphs` : ''}
              </Box>
              {item.is_donator_item && (
                <Box color="gold" bold fontSize={0.85}>
                  Donator tier {item.required_tier || 1}
                </Box>
              )}
            </Box>
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box color="label" fontSize={0.9}>
            {item.desc}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Button
            fluid
            icon={isSelected ? 'times' : 'check'}
            color={isSelected ? 'bad' : 'good'}
            onClick={() => act('toggle_item', { name: item.name })}
          >
            {isSelected ? 'Remove from loadout' : 'Add to loadout'}
          </Button>
        </Stack.Item>

        {isSelected && (
          <>
            <Stack.Item>
              <Box color="label" mb={0.3}>
                Colors:
              </Box>
              <ColorLink
                label="Color"
                currentColor={meta?.color || null}
                action="set_color"
                itemName={item.name}
              />
              {item.color_channels.includes('detail') && (
                <ColorLink
                  label="Detail"
                  currentColor={meta?.detail_color || null}
                  action="set_detail_color"
                  itemName={item.name}
                />
              )}
              {item.color_channels.includes('altdetail') && (
                <ColorLink
                  label="Alt"
                  currentColor={meta?.altdetail_color || null}
                  action="set_altdetail_color"
                  itemName={item.name}
                />
              )}
            </Stack.Item>
            <Stack.Item>
              <Box color="label" mb={0.3}>
                Custom name:
              </Box>
              <Input
                fluid
                maxLength={42}
                placeholder="Custom name..."
                value={localName}
                onChange={(val) => setLocalName(val)}
                onEnter={(val) =>
                  act('set_custom_name', { name: item.name, custom_name: val })
                }
                onBlur={(val) =>
                  act('set_custom_name', { name: item.name, custom_name: val })
                }
              />
            </Stack.Item>
            <Stack.Item grow>
              <Box color="label" mb={0.3}>
                Custom description (max 1024 chars):
              </Box>
              <TextArea
                fluid
                maxLength={1024}
                height="90px"
                placeholder="Custom description..."
                value={localDesc}
                onChange={(val) => setLocalDesc(val)}
                onBlur={(val) =>
                  act('set_custom_desc', { name: item.name, custom_desc: val })
                }
                dontUseTabForIndent
              />
            </Stack.Item>
          </>
        )}
      </Stack>
    </Section>
  );
};

/** Clear All button with inline "Are you sure?" confirmation for 4+ items */
const ClearAllButton = (props: { selectedCount: number }) => {
  const { act } = useBackend<Data>();
  const [confirming, setConfirming] = useState(false);
  const needsConfirm = props.selectedCount > 3;

  if (props.selectedCount === 0) {
    return null;
  }

  if (confirming) {
    return (
      <Box>
        <Box color="bad" bold mb={0.5}>
          Are you sure?
        </Box>
        <Button
          fluid
          icon="trash"
          color="bad"
          onClick={() => {
            act('clear_all');
            setConfirming(false);
          }}
        >
          Yes, clear all
        </Button>
        <Button fluid mt={0.5} onClick={() => setConfirming(false)}>
          Cancel
        </Button>
      </Box>
    );
  }

  return (
    <Button
      fluid
      icon="trash"
      color="bad"
      onClick={() => {
        if (needsConfirm) {
          setConfirming(true);
        } else {
          act('clear_all');
        }
      }}
    >
      Clear All ({props.selectedCount})
    </Button>
  );
};

const LoadoutDisplay = () => {
  const [search, setSearch] = useState('');
  const [activeCategory, setActiveCategory] = useState('');
  const [detailItem, setDetailItem] = useState<string | null>(null);

  const { act, data } = useBackend<Data>();
  const {
    categories,
    items,
    selected,
    total_cost,
    max_points,
    total_triumph_cost,
    effective_triumph_cost,
    player_triumphs,
    is_donator,
    triumph_discount,
    donator_bonus,
  } = data;

  const currentCategory = activeCategory || categories[0] || '';

  const selectedNames = new Set(selected.map((s) => s.name));
  const selectedMap = new Map(selected.map((s) => [s.name, s]));

  // Count selected items per category
  const categoryCounts: Record<string, number> = {};
  for (const item of items) {
    if (selectedNames.has(item.name)) {
      categoryCounts[item.category] = (categoryCounts[item.category] || 0) + 1;
    }
  }

  const filteredItems = items
    .filter((item) => {
      if (search) {
        return item.name.toLowerCase().includes(search.toLowerCase());
      }
      return item.category === currentCategory;
    })
    .sort((a, b) => a.name.localeCompare(b.name));

  const detailLoadoutItem = detailItem
    ? items.find((i) => i.name === detailItem)
    : null;

  return (
    <Stack fill>
      {/* Left sidebar: budget, triumphs, selected items list */}
      <Stack.Item width="260px">
        <Stack vertical fill>
          <Stack.Item>
            <Section title="Budget">
              <Box mb={0.5}>
                Slots: {total_cost}/{max_points}
              </Box>
              <ProgressBar
                ranges={{
                  bad: [0.9, Infinity],
                  average: [0.6, 0.9],
                  good: [-Infinity, 0.6],
                }}
                value={max_points ? total_cost / max_points : 0}
              />
              <Box mt={0.5}>
                Triumphs:{' '}
                {is_donator &&
                triumph_discount > 0 &&
                total_triumph_cost > 0 ? (
                  <>
                    {total_triumph_cost}
                    <Box inline color="green" ml={0.5}>
                      (-{Math.min(triumph_discount, total_triumph_cost)} free)
                    </Box>
                    {' = '}
                    {effective_triumph_cost}/{player_triumphs}
                  </>
                ) : (
                  <>
                    {effective_triumph_cost}/{player_triumphs}
                  </>
                )}
              </Box>
              {!!is_donator && (
                <Box color="gold" bold fontSize={0.85} mt={0.5}>
                  &#9733; Donator - +{donator_bonus} budget, {triumph_discount}{' '}
                  free triumphs
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section title="Selected Items" fill scrollable>
              {selected.length === 0 ? (
                <Box color="label" textAlign="center" mt={1}>
                  Nothing selected yet.
                </Box>
              ) : (
                <Stack vertical>
                  {selected.map((sel) => (
                    <Stack.Item key={sel.name}>
                      <Box
                        style={{
                          display: 'flex',
                          justifyContent: 'space-between',
                          alignItems: 'center',
                          gap: '4px',
                          cursor: 'pointer',
                        }}
                        onClick={() => setDetailItem(sel.name)}
                      >
                        <Box
                          style={{
                            overflow: 'hidden',
                            textOverflow: 'ellipsis',
                            whiteSpace: 'nowrap',
                          }}
                          fontSize={0.9}
                        >
                          {sel.name}
                        </Box>
                        <Button
                          icon="times"
                          color="bad"
                          onClick={(e: React.MouseEvent) => {
                            e.stopPropagation();
                            act('toggle_item', { name: sel.name });
                          }}
                        />
                      </Box>
                    </Stack.Item>
                  ))}
                </Stack>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <ClearAllButton selectedCount={selected.length} />
          </Stack.Item>
          <Stack.Item>
            <Button
              fluid
              icon="check"
              color="good"
              fontSize={1.1}
              onClick={() => act('confirm')}
            >
              Confirm
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Box color="label" fontSize={0.8}>
              Free loadout items cannot be sold, smelted, or salvaged. Triumph
              items are exempt.
            </Box>
          </Stack.Item>
        </Stack>
      </Stack.Item>

      {/* Right side: tabs, search, item grid (or detail panel if an item is focused) */}
      <Stack.Item grow>
        <Stack vertical fill>
          <Stack.Item>
            <Tabs>
              {categories.map((cat) => {
                const count = categoryCounts[cat] || 0;
                return (
                  <Tabs.Tab
                    key={cat}
                    selected={!search && currentCategory === cat}
                    onClick={() => {
                      setSearch('');
                      setActiveCategory(cat);
                      setDetailItem(null);
                    }}
                  >
                    {cat}
                    {count > 0 && ` (${count})`}
                  </Tabs.Tab>
                );
              })}
            </Tabs>
          </Stack.Item>
          <Stack.Item>
            <Input
              fluid
              placeholder="Search items..."
              value={search}
              onChange={(val) => {
                setSearch(val);
                setDetailItem(null);
              }}
            />
          </Stack.Item>
          <Stack.Item grow>
            {detailLoadoutItem ? (
              <Stack vertical fill>
                <Stack.Item>
                  <Button icon="arrow-left" onClick={() => setDetailItem(null)}>
                    Back to grid
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <ItemDetailPanel
                    item={detailLoadoutItem}
                    meta={selectedMap.get(detailLoadoutItem.name)}
                    isSelected={selectedNames.has(detailLoadoutItem.name)}
                  />
                </Stack.Item>
              </Stack>
            ) : (
              <Section fill scrollable>
                {filteredItems.length === 0 ? (
                  <Box color="label" textAlign="center" mt={2}>
                    No items found.
                  </Box>
                ) : (
                  <Box
                    style={{
                      display: 'grid',
                      gridTemplateColumns:
                        'repeat(auto-fill, minmax(110px, 1fr))',
                      gap: '8px',
                    }}
                  >
                    {filteredItems.map((item) => {
                      const isSelected = selectedNames.has(item.name);
                      const meta = selectedMap.get(item.name);
                      return (
                        <Box
                          key={item.name}
                          style={{
                            display: 'flex',
                            flexDirection: 'column',
                            alignItems: 'center',
                            padding: '8px',
                            cursor: 'pointer',
                            borderRadius: '6px',
                            border: `2px solid ${
                              isSelected
                                ? 'rgba(80,200,120,0.8)'
                                : 'rgba(255,255,255,0.12)'
                            }`,
                            background: isSelected
                              ? 'rgba(80,200,120,0.08)'
                              : 'rgba(0,0,0,0.15)',
                          }}
                          onClick={() => setDetailItem(item.name)}
                        >
                          <DmIcon
                            icon={item.icon ?? ''}
                            icon_state={item.icon_state ?? ''}
                            width={3}
                            height={3}
                            fallback={
                              <Box
                                width={3}
                                height={3}
                                align="center"
                                verticalAlign="middle"
                                fontSize={0.7}
                                color="label"
                                style={{
                                  display: 'flex',
                                  alignItems: 'center',
                                  justifyContent: 'center',
                                  overflow: 'hidden',
                                  textAlign: 'center',
                                }}
                              >
                                {item.name.slice(0, 8)}
                              </Box>
                            }
                          />
                          {(meta?.color ||
                            meta?.detail_color ||
                            meta?.altdetail_color) && (
                            <Box mt={0.2}>
                              {meta?.color && (
                                <ColorSwatch color={meta.color} />
                              )}
                              {meta?.detail_color && (
                                <ColorSwatch color={meta.detail_color} />
                              )}
                              {meta?.altdetail_color && (
                                <ColorSwatch color={meta.altdetail_color} />
                              )}
                            </Box>
                          )}
                          <Box
                            textAlign="center"
                            fontSize={0.8}
                            bold={isSelected}
                            mt={0.3}
                            style={{
                              overflow: 'hidden',
                              textOverflow: 'ellipsis',
                              display: '-webkit-box',
                              WebkitLineClamp: 2,
                              WebkitBoxOrient: 'vertical',
                            }}
                          >
                            {item.name}
                          </Box>
                          <Box color="label" fontSize={0.75}>
                            {item.cost}pt
                          </Box>
                          {item.triumph_cost ? (
                            <Box color="gold" bold fontSize={0.75}>
                              {item.triumph_cost} tri
                            </Box>
                          ) : null}
                          {item.is_donator_item && (
                            <Box color="gold" fontSize={0.7}>
                              Donator {item.required_tier || 1}
                            </Box>
                          )}
                        </Box>
                      );
                    })}
                  </Box>
                )}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
