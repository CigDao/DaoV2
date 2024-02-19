import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface Dao {
  'commit' : ActorMethod<[bigint], Uint8Array | number[]>,
  'createProposal' : ActorMethod<
    [ProposalRequest, bigint],
    { 'Ok' : bigint } |
      { 'Err' : string }
  >,
  'fetchProposals' : ActorMethod<[], Array<Proposal>>,
  'getProposal' : ActorMethod<
    [number],
    { 'Ok' : Proposal } |
      { 'Err' : string }
  >,
  'mockProposal' : ActorMethod<[], number>,
  'vote' : ActorMethod<
    [number, boolean, bigint],
    { 'Ok' : bigint } |
      { 'Err' : string }
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
  'proposalType' : ProposalType,
}
export type ProposalType = { 'poll' : null };
export interface _SERVICE extends Dao {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: ({ IDL }: { IDL: IDL }) => IDL.Type[];
