export const idlFactory = ({ IDL }) => {
  const ProposalType = IDL.Variant({ 'poll' : IDL.Null });
  const ProposalRequest = IDL.Record({
    'title' : IDL.Text,
    'content' : IDL.Text,
    'ends' : IDL.Int,
    'proposalType' : ProposalType,
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
    'commit' : IDL.Func([IDL.Nat], [IDL.Text], []),
    'createProposal' : IDL.Func(
        [ProposalRequest, IDL.Nat],
        [IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : IDL.Text })],
        [],
      ),
    'fetchProposals' : IDL.Func([], [IDL.Vec(Proposal)], []),
    'getProposal' : IDL.Func(
        [IDL.Nat32],
        [IDL.Variant({ 'Ok' : Proposal, 'Err' : IDL.Text })],
        [],
      ),
    'vote' : IDL.Func(
        [IDL.Nat, IDL.Nat32, IDL.Bool, IDL.Nat],
        [IDL.Variant({ 'Ok' : IDL.Nat, 'Err' : IDL.Text })],
        [],
      ),
  });
  return Dao;
};
export const init = ({ IDL }) => { return []; };
