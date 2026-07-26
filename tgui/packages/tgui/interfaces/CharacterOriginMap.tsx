import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Window } from 'tgui/layouts';
import { Box, Button, Section, Stack } from 'tgui-core/components';

type RegionData = {
  path: string;
  key: string;
  name: string;
  desc: string;
  origin_desc: string;
  selected: boolean;
};

type Data = {
  current_origin: string | null;
  regions: RegionData[];
};

// Hand-placed hotspot layout mirroring the world map's actual geography:
// Vergenmark crowns the north, Auxentia is the central heartland, Ognica and
// Kamenrad sit west/southwest across the strait, Via Medulla is the
// free-city corridor between them, and Ostrovia scatters to the southeast.
// "Elsewhere" gets no fixed spot - it's a floating "none of the above" pin.
const HOTSPOTS: Record<string, { x: number; y: number; w: number; h: number }> = {
  Vergenmark: { x: 200, y: 30, w: 140, h: 70 },
  Auxentia: { x: 170, y: 120, w: 200, h: 150 },
  Ognica: { x: 30, y: 140, w: 100, h: 80 },
  Kamenrad: { x: 40, y: 230, w: 100, h: 90 },
  'Via Medulla': { x: 130, y: 190, w: 60, h: 90 },
  Ostrovia: { x: 340, y: 260, w: 130, h: 90 },
  Elsewhere: { x: 400, y: 30, w: 70, h: 50 },
};

const VIEW_W = 500;
const VIEW_H = 360;

export const CharacterOriginMap = () => {
  const { act, data } = useBackend<Data>();
  const [hovered, setHovered] = useState<string | null>(null);
  const [picked, setPicked] = useState<string | null>(null);

  const activeKey =
    hovered ||
    picked ||
    data.regions.find((r) => r.selected)?.key ||
    data.regions[0]?.key ||
    null;
  const activeRegion = data.regions.find((r) => r.key === activeKey);

  return (
    <Window title="Where Do You Hail From?" width={980} height={640}>
      <Window.Content>
        <Box className="CharacterOriginMap">
          <Stack fill>
            <Stack.Item grow={3} basis={0}>
              <Section fill title="Vaeltis" className="CharacterOriginMap__mapSection">
                <svg
                  viewBox={`0 0 ${VIEW_W} ${VIEW_H}`}
                  className="CharacterOriginMap__svg"
                  preserveAspectRatio="xMidYMid meet"
                >
                  <rect x={0} y={0} width={VIEW_W} height={VIEW_H} className="CharacterOriginMap__sea" />

                  {/* Rough landmasses, purely decorative context for the hotspots */}
                  <path
                    d="M150,10 L360,10 L380,120 L340,260 L180,300 L120,220 L100,90 Z"
                    className="CharacterOriginMap__land CharacterOriginMap__land--main"
                  />
                  <path
                    d="M10,120 L120,110 L140,190 L90,240 L20,200 Z"
                    className="CharacterOriginMap__land CharacterOriginMap__land--west"
                  />
                  <path
                    d="M20,210 L110,220 L150,280 L110,335 L30,320 Z"
                    className="CharacterOriginMap__land CharacterOriginMap__land--south"
                  />
                  <circle cx={355} cy={275} r={18} className="CharacterOriginMap__land CharacterOriginMap__land--isle" />
                  <circle cx={410} cy={300} r={14} className="CharacterOriginMap__land CharacterOriginMap__land--isle" />
                  <circle cx={440} cy={260} r={16} className="CharacterOriginMap__land CharacterOriginMap__land--isle" />
                  <circle cx={430} cy={40} r={20} className="CharacterOriginMap__land CharacterOriginMap__land--isle" />

                  {data.regions.map((region) => {
                    const spot = HOTSPOTS[region.key];
                    if (!spot) return null;
                    const isActive = activeKey === region.key;
                    const isSelected = region.selected;
                    return (
                      <g
                        key={region.path}
                        className={
                          'CharacterOriginMap__hotspot' +
                          (isActive ? ' CharacterOriginMap__hotspot--active' : '') +
                          (isSelected ? ' CharacterOriginMap__hotspot--selected' : '')
                        }
                        onMouseEnter={() => setHovered(region.key)}
                        onMouseLeave={() => setHovered(null)}
                        onClick={() => setPicked(region.key)}
                      >
                        <rect
                          x={spot.x}
                          y={spot.y}
                          width={spot.w}
                          height={spot.h}
                          rx={8}
                          className="CharacterOriginMap__hotspotRect"
                        />
                        <text
                          x={spot.x + spot.w / 2}
                          y={spot.y + spot.h / 2}
                          textAnchor="middle"
                          dominantBaseline="middle"
                          className="CharacterOriginMap__hotspotLabel"
                        >
                          {region.key}
                        </text>
                        {isSelected && (
                          <text
                            x={spot.x + spot.w / 2}
                            y={spot.y + spot.h / 2 + 16}
                            textAnchor="middle"
                            className="CharacterOriginMap__hotspotCheck"
                          >
                            ✓ current
                          </text>
                        )}
                      </g>
                    );
                  })}
                </svg>
              </Section>
            </Stack.Item>

            <Stack.Item grow={2} basis={0}>
              <Section fill scrollable title={activeRegion?.name || 'Select a Region'}>
                {activeRegion ? (
                  <>
                    <Box color="label" italic mb={1}>
                      {activeRegion.desc}
                    </Box>
                    <Box mb={1.5} dangerouslySetInnerHTML={{ __html: activeRegion.origin_desc }} />
                    <Button
                      fluid
                      bold
                      icon="check"
                      disabled={activeRegion.selected}
                      onClick={() => act('choose_origin', { path: activeRegion.path })}
                    >
                      {activeRegion.selected ? 'This Is Your Origin' : `Choose ${activeRegion.name}`}
                    </Button>
                  </>
                ) : (
                  <Box color="label">Click a region on the map to read its history.</Box>
                )}
              </Section>
            </Stack.Item>
          </Stack>
        </Box>
      </Window.Content>
    </Window>
  );
};

export default CharacterOriginMap;
