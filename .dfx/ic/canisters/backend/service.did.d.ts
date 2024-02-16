import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Dao {
  'createProposal' : ActorMethod<
    [ProposalRequest],
    { 'Ok' : bigint } |
      { 'Err' : TransferFromError }
  >,
  'fetchProposals' : ActorMethod<[], Array<Proposal>>,
  'getProposal' : ActorMethod<
    [number],
    { 'Ok' : Proposal } |
      { 'Err' : string }
  >,
  'vote' : ActorMethod<
    [bigint, number, boolean],
    { 'Ok' : bigint } |
      { 'Err' : TransferFromError }
  >,
}
export interface Proposal {
  'id' : number,
  'nay' : bigint,
  'yay' : bigint,
  'title' : string,
  'content' : string,
  'ends' : bigint,
  'createdAt' : bigint,
  'createdBy' : string,
  'isActive' : boolean,
  'proposalType' : ProposalType,
  'accepted' : boolean,
}
export interface ProposalRequest {
  'title' : string,
  'content' : string,
  'ends' : bigint,
  'proposalType' : ProposalType,
}
export type ProposalType = { 'poll' : null };
export type TransferFromError = {
    'GenericError' : { 'message' : string, 'error_code' : bigint }
  } |
  { 'TemporarilyUnavailable' : null } |
  { 'InsufficientAllowance' : { 'allowance' : bigint } } |
  { 'BadBurn' : { 'min_burn_amount' : bigint } } |
  { 'Duplicate' : { 'duplicate_of' : bigint } } |
  { 'BadFee' : { 'expected_fee' : bigint } } |
  { 'CreatedInFuture' : { 'ledger_time' : bigint } } |
  { 'TooOld' : null } |
  { 'InsufficientFunds' : { 'balance' : bigint } };
export interface _SERVICE extends Dao {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: ({ IDL }: { IDL: IDL }) => IDL.Type[];
