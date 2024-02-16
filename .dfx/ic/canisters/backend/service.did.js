export const idlFactory = ({ IDL }) => {
  const ProposalType = IDL.Variant({ 'poll' : IDL.Null });
  const ProposalRequest = IDL.Record({
    'title' : IDL.Text,
    'content' : IDL.Text,
    'ends' : IDL.Int,
    'proposalType' : ProposalType,
  });
  const TransferFromError = IDL.Variant({
    'GenericError' : IDL.Record({
      'message' : IDL.Text,
      'error_code' : IDL.Nat,
    }),
    'TemporarilyUnavailable' : IDL.Null,
    'InsufficientAllowance' : IDL.Record({ 'allowance' : IDL.Nat }),
    'BadBurn' : IDL.Record({ 'min_burn_amount' : IDL.Nat }),
    'Duplicate' : IDL.Record({ 'duplicate_of' : IDL.Nat }),
    'BadFee' : IDL.Record({ 'expected_fee' : IDL.Nat }),
    'CreatedInFuture' : IDL.Record({ 'ledger_time' : IDL.Nat64 }),
    'TooOld' : IDL.Null,
    'InsufficientFunds' : IDL.Record({ 'balance' : IDL.Nat }),
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat32,
    'nay' : IDL.Nat,
    'yay' : IDL.Nat,
    'title' : IDL.Text,
    'content' : IDL.Text,
    'ends' : IDL.Int,
    'createdAt' : IDL.Int,
    'createdBy' : IDL.Text,
    'isActive' : IDL.Bool,
    'proposalType' : ProposalType,
    'accepted' : IDL.Bool,
  });
  const Dao = IDL.Service({
    'createProposal' : IDL.Func(
        [ProposalRequest],
        [IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : TransferFromError })],
        [],
      ),
    'fetchProposals' : IDL.Func([], [IDL.Vec(Proposal)], []),
    'getProposal' : IDL.Func(
        [IDL.Nat32],
        [IDL.Variant({ 'Ok' : Proposal, 'Err' : IDL.Text })],
        [],
      ),
    'vote' : IDL.Func(
        [IDL.Nat, IDL.Nat32, IDL.Bool],
        [IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : TransferFromError })],
        [],
      ),
  });
  return Dao;
};
export const init = ({ IDL }) => { return []; };
