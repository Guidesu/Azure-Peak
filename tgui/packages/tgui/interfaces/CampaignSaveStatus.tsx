import { Box, Button, LabeledList, NoticeBox, Section, Table } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type ParkedCharacterRow = {
  record_key: string;
  owner_ckey: string;
  real_name: string;
  state: string;
  complete: BooleanLike;
};

type WorldSave = {
  checkpoint_generation: number;
  last_checkpoint_at: number | null;
  last_checkpoint_ago_text: string;
  save_file_bytes: number;
};

type PendingState = {
  dirty_turf_count: number;
  pending_parking_count: number;
  pending_resume_count: number;
};

type DungeonHealth = {
  setup_done: BooleanLike;
  generation_complete: BooleanLike;
  markers_remaining: number;
  failed_markers_remaining: number;
  rooms_placed: number;
};

type EconomyHealth = {
  last_processed_day: number;
  roundstart_events_fired: BooleanLike;
};

type SubsystemHealth = {
  dungeon: DungeonHealth;
  economy: EconomyHealth;
};

type Data = {
  is_admin: BooleanLike;
  enabled: BooleanLike;
  world_save: WorldSave;
  parked_characters: ParkedCharacterRow[];
  pending_state?: PendingState;
  subsystem_health?: SubsystemHealth;
};

const formatBytes = (bytes: number): string => {
  if (!bytes) {
    return '0 B';
  }
  if (bytes < 1024) {
    return `${bytes} B`;
  }
  if (bytes < 1024 * 1024) {
    return `${(bytes / 1024).toFixed(1)} KB`;
  }
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
};

const STATE_LABELS: Record<string, string> = {
  parked: 'Saved',
  parking: 'Saving…',
  resuming: 'Restoring…',
  draft: 'Draft (not yet parked)',
};

export const CampaignSaveStatus = () => {
  const { act, data } = useBackend<Data>();
  const {
    is_admin,
    enabled,
    world_save,
    parked_characters,
    pending_state,
    subsystem_health,
  } = data;

  return (
    <Window
      title={is_admin ? 'Campaign Save Status (Admin)' : 'My Campaign Save Status'}
      width={620}
      height={is_admin ? 700 : 320}>
      <Window.Content scrollable>
        {!enabled && (
          <NoticeBox color="bad">
            The DreamValley campaign save system is not currently active on
            this server.
          </NoticeBox>
        )}
        <Section
          title="World Save"
          buttons={
            !!is_admin && (
              <Button
                icon="save"
                content="Force Checkpoint Now"
                onClick={() => act('force_checkpoint')}
              />
            )
          }>
          <LabeledList>
            <LabeledList.Item label="Last saved">
              {world_save.last_checkpoint_ago_text}
            </LabeledList.Item>
            {!!is_admin && (
              <LabeledList.Item label="Checkpoint generation">
                {world_save.checkpoint_generation}
              </LabeledList.Item>
            )}
            {!!is_admin && (
              <LabeledList.Item label="Save file size">
                {formatBytes(world_save.save_file_bytes)}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>

        {!!is_admin && !!pending_state && (
          <Section title="Pending / Unsaved State">
            <LabeledList>
              <LabeledList.Item label="Dirty turfs (unsaved)">
                {pending_state.dirty_turf_count}
              </LabeledList.Item>
              <LabeledList.Item label="Parking transactions in flight">
                {pending_state.pending_parking_count}
              </LabeledList.Item>
              <LabeledList.Item label="Resume transactions in flight">
                {pending_state.pending_resume_count}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}

        {!!is_admin && !!subsystem_health && (
          <Section title="Subsystem Health">
            <LabeledList>
              <LabeledList.Item label="Dungeon generator">
                {subsystem_health.dungeon.generation_complete
                  ? `Complete (${subsystem_health.dungeon.rooms_placed} rooms placed)`
                  : subsystem_health.dungeon.setup_done
                    ? `In progress (${subsystem_health.dungeon.markers_remaining} markers, ${subsystem_health.dungeon.failed_markers_remaining} failed queued)`
                    : 'Not started'}
              </LabeledList.Item>
              <LabeledList.Item label="Economy - last processed day">
                {subsystem_health.economy.last_processed_day || 'Never'}
              </LabeledList.Item>
              <LabeledList.Item label="Economy - roundstart events">
                {subsystem_health.economy.roundstart_events_fired ? 'Fired' : 'Pending'}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}

        <Section
          title={is_admin ? 'Parked Characters (All Players)' : 'My Parked Characters'}>
          {!parked_characters.length ? (
            <Box color="label" italic>
              {is_admin
                ? 'No characters are currently parked.'
                : "You don't have a parked character right now."}
            </Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Character</Table.Cell>
                {!!is_admin && <Table.Cell>Ckey</Table.Cell>}
                <Table.Cell>Status</Table.Cell>
                {!!is_admin && <Table.Cell>Actions</Table.Cell>}
              </Table.Row>
              {parked_characters.map((row) => (
                <Table.Row key={row.record_key}>
                  <Table.Cell>{row.real_name}</Table.Cell>
                  {!!is_admin && <Table.Cell>{row.owner_ckey}</Table.Cell>}
                  <Table.Cell>
                    {STATE_LABELS[row.state] || row.state}
                    {!row.complete && ' (incomplete)'}
                  </Table.Cell>
                  {!!is_admin && (
                    <Table.Cell>
                      {row.state === 'parking' && (
                        <Button
                          icon="undo"
                          content="Cancel Save"
                          color="caution"
                          onClick={() =>
                            act('cancel_pending_parking', { record_key: row.record_key })
                          }
                        />
                      )}
                      {row.state === 'resuming' && (
                        <Button
                          icon="undo"
                          content="Cancel Resume"
                          color="caution"
                          onClick={() =>
                            act('cancel_pending_resume', { record_key: row.record_key })
                          }
                        />
                      )}
                      <Button
                        icon="trash"
                        content="Delete"
                        color="bad"
                        onClick={() =>
                          act('delete_parked_record', { record_key: row.record_key })
                        }
                      />
                    </Table.Cell>
                  )}
                </Table.Row>
              ))}
            </Table>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
