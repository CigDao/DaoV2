import Map "mo:map/Map";
import { nhash; n32hash } "mo:map/Map";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Proposal "models/Proposal";
import { DAY; HOUR } "mo:time-consts";
import ICRC2 "services/ICRC2";
import Constants "../Constants";

actor class Dao() = this {

  private type Proposal = Proposal.Proposal;
  private type ProposalRequest = Proposal.ProposalRequest;
  private type ProposalType = Proposal.ProposalType;

  stable var proposalId : Nat32 = 1;
  stable var proposalCost : Nat = 3_000_000_000_000_000;
  stable let proposals = Map.new<Nat32, Proposal>();

  public shared ({ caller }) func createProposal(request : ProposalRequest) : async {
    #Ok : Nat;
    #Err : ICRC2.TransferFromError;
  } {
    await _createProposal(caller, request);
  };

  public shared ({caller}) func vote(amount : Nat, id : Nat32, yay : Bool): async {
    #Ok : Nat;
    #Err : ICRC2.TransferFromError;
  } {
     await _vote(caller, amount, id, yay);
  };

  public func fetchProposals() : async [Proposal] {
    _fetchProposals();
  };

  public func getProposal(id:Nat32): async { #Ok : Proposal; #Err : Text } {
    await getProposal(id);
  };

  private func _createProposal(caller : Principal, request : ProposalRequest) : async {
    #Ok : Nat;
    #Err : ICRC2.TransferFromError;
  } {
    let args : ICRC2.TransferFromArgs = {
      spender_subaccount = null;
      from = { owner = caller; subaccount = null };
      to = { owner = Principal.fromText(Constants.Treasury); subaccount = null };
      amount = proposalCost;
      fee = ?1000000;
      memo = null;
      created_at_time = ?Nat64.fromIntWrap(Time.now());
    };
    let result = await ICRC2.service(Constants.Token).icrc2_transfer_from(args);
    switch (result) {
      case (#Ok(value)) {
        let currentProposalId = proposalId;
        let now = Time.now();
        let proposal : Proposal = {
          id = currentProposalId;
          proposalType = request.proposalType;
          title = request.title;
          content = request.content;
          yay = 0;
          nay = 0;
          ends = now + (DAY * 3);
          createdAt = now;
          createdBy = Principal.toText(caller);
          accepted = false;
          isActive = true;
        };

        Map.set(proposals, n32hash, currentProposalId, proposal);
        proposalId := proposalId + 1;
      };
      case (#Err(value)) {

      };
    };
    result;
  };

  private func _vote(caller : Principal, amount : Nat, id : Nat32, yay : Bool) : async {
    #Ok : Nat;
    #Err : ICRC2.TransferFromError;
  } {
    let args : ICRC2.TransferFromArgs = {
      spender_subaccount = null;
      from = { owner = caller; subaccount = null };
      to = { owner = Principal.fromText(Constants.Treasury); subaccount = null };
      amount = amount;
      fee = ?1000000;
      memo = null;
      created_at_time = ?Nat64.fromIntWrap(Time.now());
    };
    let result = await ICRC2.service(Constants.Token).icrc2_transfer_from(args);
    switch (result) {
      case (#Ok(value)) {
        let proposal = _getProposal(id);
        switch (proposal) {
          case (#Ok(proposal)) {
            if (yay) {
              let _proposal : Proposal = {
                id = proposal.id;
                proposalType = proposal.proposalType;
                title = proposal.title;
                content = proposal.content;
                yay = proposal.yay + amount;
                nay = proposal.nay;
                ends = proposal.ends;
                createdAt = proposal.createdAt;
                createdBy = proposal.createdBy;
                accepted = proposal.accepted;
                isActive = proposal.isActive;
              };
              Map.set(proposals, n32hash, proposal.id, _proposal);
            } else {
              let _proposal : Proposal = {
                id = proposal.id;
                proposalType = proposal.proposalType;
                title = proposal.title;
                content = proposal.content;
                yay = proposal.yay;
                nay = proposal.nay + amount;
                ends = proposal.ends;
                createdAt = proposal.createdAt;
                createdBy = proposal.createdBy;
                accepted = proposal.accepted;
                isActive = proposal.isActive;
              };
              Map.set(proposals, n32hash, proposal.id, _proposal);
            };
          };
          case (#Err(value)) {

          };
        };
        //credit vote
      };
      case (#Err(value)) {

      };
    };
    result;
  };

  private func _fetchProposals() : [Proposal] {
    let _proposals : Buffer.Buffer<Proposal> = Buffer.fromArray([]);
    for ((id, proposal) in Map.toArray(proposals).vals()) {
      _proposals.add(proposal);
    };

    Buffer.toArray(_proposals);
  };

  private func _getProposal(id : Nat32) : { #Ok : Proposal; #Err : Text } {
    let exist = Map.get(proposals, n32hash, id);
    switch (exist) {
      case (?exist) #Ok(exist);
      case (_) #Err("Proposal Not Found");
    };
  };

};
