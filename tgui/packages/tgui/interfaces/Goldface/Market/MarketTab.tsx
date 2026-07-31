import { cardStyle, INK_SOFT, pageStyle } from '../../common/parchment';
import { MarketView } from '../../Noticeboard/AvisaSections/MarketSection';
import type { HarborData } from '../types';

export const MarketTab = (props: {
  harbor?: HarborData;
  factionName?: string;
}) => {
  const { harbor, factionName } = props;
  if (!harbor) {
    return (
      <div style={pageStyle}>
        <div style={{ ...cardStyle, textAlign: 'center', color: INK_SOFT }}>
          The market ledgers are not yet drawn up.
        </div>
      </div>
    );
  }
  return (
    <div style={pageStyle}>
      <MarketView market={harbor.market_data} factionName={factionName} />
    </div>
  );
};
