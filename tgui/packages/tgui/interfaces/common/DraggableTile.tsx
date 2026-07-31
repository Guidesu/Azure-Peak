import { type ReactNode, useEffect, useRef, useState } from 'react';

type Rect = { x: number; y: number; w: number; h: number };

const MIN_W = 200;
const MIN_H = 120;

/**
 * A free-form, drag-by-header + resize-by-corner tile. Position/size are
 * owned by the parent (CharacterSheet) and persisted DM-side in the
 * player's preferences - browser localStorage was tried first but isn't
 * reliably durable across sessions in the BYOND client webview, so the
 * parent now passes down the last-known rect and a save callback instead of
 * this component reading/writing storage itself. Parent container must be
 * `position: relative`.
 */
export const DraggableTile = (props: {
  storageKey: string;
  title: string;
  defaultRect: Rect;
  savedRect?: Rect;
  onRectChange: (storageKey: string, rect: Rect) => void;
  className?: string;
  children: ReactNode;
}) => {
  const { storageKey, title, defaultRect, savedRect, onRectChange, className, children } = props;
  const [rect, setRect] = useState<Rect>(savedRect || defaultRect);
  const dragRef = useRef<{ startX: number; startY: number; origX: number; origY: number } | null>(null);
  const resizeRef = useRef<{ startX: number; startY: number; origW: number; origH: number } | null>(null);

  // The backend's saved layout can arrive after first render (ui_data is
  // async) - adopt it once it shows up, but only if the player hasn't
  // already started dragging/resizing this tile this session.
  const adoptedSavedRect = useRef(false);
  useEffect(() => {
    if (savedRect && !adoptedSavedRect.current) {
      adoptedSavedRect.current = true;
      setRect(savedRect);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [savedRect]);

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
          onRectChange(storageKey, prev);
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
  }, [storageKey, onRectChange]);

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
