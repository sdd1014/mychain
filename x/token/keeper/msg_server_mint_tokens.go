package keeper

import (
	"context"

	"mychain/x/token/types"

	errorsmod "cosmossdk.io/errors"
)

func (k msgServer) MintTokens(ctx context.Context, msg *types.MsgMintTokens) (*types.MsgMintTokensResponse, error) {
	if _, err := k.addressCodec.StringToBytes(msg.Creator); err != nil {
		return nil, errorsmod.Wrap(err, "invalid authority address")
	}

	// TODO: Handle the message

	return &types.MsgMintTokensResponse{}, nil
}
