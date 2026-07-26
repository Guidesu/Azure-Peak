import { type ReactNode, useEffect, useRef, useState } from 'react';

type Rect = { x: number; y: number; w: number; h: number };

const STORAGE_PREFIX = 'dreamvalley_tile_layout_';

const loadRect = (storageKey: string, fallback: Rect): Rect => {
  try {
    const raw = window.localStorage.getItem(STORAGE_PREFIX + storageKey);
    if (!raw) return fallback;
    const parsed = JSON.parse(raw);
    if (
      typeof parsed?.x === 'number' &&
      typeof parsed?.y === 'number' &&
      typeof parsed?.w === 'number' &&
      typeof parsed?.h === 'number'
    ) {
      return parsed;
    }
  } catch {
    // ignore malformed/missing storage, fall through to default
  }
  return fallback;
};

const saveRect = (storageKey: string, rect: Rect): void => {
  try {
    window.localStorage.setItem(STORAGE_PREFIX + storageKey, JSON.stringify(rect));
  } catch {
    // localStorage unavailable (e.g. private mode) - positions just won't persist
  }
};

const MIN_W = 200;
const MIN_H = 120;

/**
 * A free-form, drag-by-header + resize-by-corner tile. Position/size persist
 * to localStorage per `storageKey` so a player's layout survives reopening
 * the sheet. Parent container must be `position: relative`.
 */
export const DraggableTile = (props: {
  storageKey: string;
  title: string;
  defaultRect: Rect;
  className?: string;
  children: ReactNode;
}) => {
  const { storageKey, title, defaultRect, className, children } = props;
  const [rect, setRect] = useState<Rect>(() => loadRect(storageKey, defaultRect));
  const dragRef = useRef<{ startX: number; startY: number; origX: number; origY: number } | null>(null);
  const resizeRef = useRef<{ startX: number; startY: number; origW: number; origH: number } | null>(null);

  useEffect(() => {
    const onMouseMove = (evt: MouseEvent) => {
      if (dragRef.current) {
        const { startX, startY, origX, origY } = dragRef.current;
        setRect((prev) => ({
          ...prev,
          x: Math.max(0, origX + (evt.clientX - startX)),
          y: Math.max(0, origY + (evt.clientY - startY)),
        }));
      } else if (resizeRef.current) {
        const { startX, startY, origW, origH } = resizeRef.current;
        setRect((prev) => ({
          ...prev,
          w: Math.max(MIN_W, origW + (evt.clientX - startX)),
          h: Math.max(MIN_H, origH + (evt.clientY - startY)),
        }));
      }
    };

    const onMouseUp = () => {
      if (dragRef.current || resizeRef.current) {
        dragRef.current = null;
        resizeRef.current = null;
        setRect((prev) => {
          saveRect(storageKey, prev);
          return prev;
        });
      }
    };

    window.addEventListener('mousemove', onMouseMove);
    window.addEventListener('mouseup', onMouseUp);
    return () => {
      window.removeEventListener('mousemove', onMouseMove);
      window.removeEventListener('mouseup', onMouseUp);
    };
  }, [storageKey]);

  const startDrag = (evt: React.MouseEvent) => {
    evt.preventDefault();
    dragRef.current = { startX: evt.clientX, startY: evt.clientY, origX: rect.x, origY: rect.y };
  };

  const startResize = (evt: React.MouseEvent) => {
    evt.preventDefault();
    evt.stopPropagation();
    resizeRef.current = { startX: evt.clientX, startY: evt.clientY, origW: rect.w, origH: rect.h };
  };

  return (
    <div
      className={`CharacterSheet__Tile CharacterSheet__Tile--floating${className ? ` ${className}` : ''}`}
      style={{
        position: 'absolute',
        left: rect.x,
        top: rect.y,
        width: rect.w,
        height: rect.h,
      }}
    >
      <div className="CharacterSheet__TileHeader CharacterSheet__TileHeader--draggable" onMouseDown={startDrag}>
        {title}
      </div>
      <div className="CharacterSheet__TileBody CharacterSheet__TileBody--floating">{children}</div>
      <div className="CharacterSheet__TileResizeHandle" onMouseDown={startResize} />
    </div>
  );
};

export default DraggableTile;
