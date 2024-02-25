import Map "mo:map/Map";
import { nhash; n32hash; thash } "mo:map/Map";
import Nat32 "mo:base/Nat32";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Nat64 "mo:base/Nat64";
import Blob "mo:base/Blob";
import Error "mo:base/Error";
import Proposal "models/Proposal";
import { DAY; HOUR; MINUTE } "mo:time-consts";
import ICRC2 "services/ICRC2";
import Constants "../Constants";
import Source "mo:uuid/async/SourceV4";
import UUID "mo:uuid/UUID";
import { recurringTimer; cancelTimer; setTimer } = "mo:base/Timer";
actor class Dao() = this {

  private type Proposal = Proposal.Proposal;
  private type ProposalRequest = Proposal.ProposalRequest;
  private type ProposalType = Proposal.ProposalType;

  stable var proposalId : Nat32 = 1;
  stable var proposalCost : Nat = 3_000_000_000_000_000;
  //stable var proposalCost : Nat = 10_000;
  stable let proposals = Map.new<Nat32, Proposal>();
  stable let commitment = Map.new<Text, Nat>();

  let duration:Nat = DAY * 3;

  /*public shared ({caller}) func mockProposal(): async Nat32 {
      let currentProposalId = proposalId;
      proposalId := proposalId + 1;
      let now = Time.now();
      let proposal : Proposal = {
        id = currentProposalId;
        proposalType = #poll;
        title = "Farcaster Integration";
        content = "Farcaster is awesome so lets use it :)";
        yay = 0;
        nay = 0;
        ends = now + duration;
        createdAt = now;
        createdBy = Principal.toText(caller);
        accepted = false;
        isActive = true;
      };
      Map.set(proposals, n32hash, currentProposalId, proposal);
      await _startProposalTimer(currentProposalId);
      currentProposalId;
  };*/

  public shared ({ caller }) func commit(amount : Nat) : async [Nat8] {
    let g = Source.Source();
    let blob = await g.new();
    let uuid = UUID.toText(blob);
    Map.set(commitment, thash, uuid, amount);
    blob;
  };

  public shared ({ caller }) func createProposal(request : ProposalRequest, txIndex : Nat) : async {
    #Ok : Nat;
    #Err : Text;
  } {
    await _createProposal(caller, request, txIndex);
  };

  public shared ({ caller }) func vote(id : Nat32, yay : Bool, txIndex : Nat) : async {
    #Ok : Nat;
    #Err : Text;
  } {
    await _vote(caller, id, yay, txIndex);
  };

  public query func fetchProposals() : async [Proposal] {
    _fetchProposals();
  };

  public query func getProposal(id : Nat32) : async { #Ok : Proposal; #Err : Text } {
    _getProposal(id);
  };

  private func _createProposal(caller : Principal, request : ProposalRequest, txIndex : Nat) : async {
    #Ok : Nat;
    #Err : Text;
  } {
    try {
      let amount = await _verifyTransaction(caller, txIndex, ?proposalCost);
      let currentProposalId = proposalId;
      proposalId := proposalId + 1;
      let now = Time.now();
      let proposal : Proposal = {
        id = currentProposalId;
        proposalType = request.proposalType;
        title = request.title;
        content = request.content;
        yay = 0;
        nay = 0;
        ends = now + duration;
        createdAt = now;
        createdBy = Principal.toText(caller);
        accepted = false;
        isActive = true;
      };
      Map.set(proposals, n32hash, currentProposalId, proposal);
      await _startProposalTimer(currentProposalId);
      #Ok(Nat32.toNat(currentProposalId));
    } catch (e) {
      #Err(Error.message(e));
    };
  };

  private func _vote(caller : Principal, id : Nat32, yay : Bool, txIndex : Nat) : async {
    #Ok : Nat;
    #Err : Text;
  } {
    try {
      let amount = await _verifyTransaction(caller, txIndex, null);
      let proposal = _getProposal(id);
      switch (proposal) {
        case (#Ok(proposal)) {
          if (proposal.isActive == false) return #Err("This Proposal Is No Longer Active");
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
          return #Err(value);
        };
      };
      #Ok(Nat32.toNat(id));
    } catch (e) {
      #Err(Error.message(e));
    };
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

  private func _verifyTransaction(caller : Principal, txIndex : Nat, amount : ?Nat) : async Nat {
    var committedAmount = 0;
    let from : ICRC2.Account = { owner = caller; subaccount = null };
    let to : ICRC2.Account = {
      owner = Principal.fromText(Constants.Treasury);
      subaccount = null;
    };
    let transaction : ?ICRC2.Transaction = await ICRC2.service(Constants.Token).get_transaction(txIndex);
    switch (transaction) {
      case (?transaction) {
        switch (transaction.transfer) {
          case (?transfer) {
            switch (transfer.memo) {
              case (?memo) {
                let uuid = UUID.toText(Blob.toArray(memo));
                let _amount = Map.get(commitment, thash, uuid);
                switch (_amount) {
                  case (?_amount) {
                    switch (amount) {
                      case (?amount) {
                        if (transfer.to == to and transfer.from == from and transfer.amount >= amount) {
                          Map.delete(commitment, thash, uuid);
                          committedAmount := _amount;
                        }else{
                          throw(Error.reject("Insuffient Transaction"));
                        }
                      };
                      case (_) {
                        if (transfer.to == to and transfer.from == from and transfer.amount >= _amount) {
                          Map.delete(commitment, thash, uuid);
                          committedAmount := _amount;
                        }else{
                          throw(Error.reject("Insuffient Transaction"));
                        }
                      };
                    };
                  };
                  case (_) {
                    throw (Error.reject("Commitment Not Found"));
                  };
                };
              };
              case (_) {
                throw (Error.reject("Memo Not Found"));
              };
            };
          };
          case (_) {
            throw (Error.reject("Incorrect Transaction Type"));
          };
        };
      };
      case (_) {
        throw (Error.reject("Transaction Not Found"));
      };
    };
    committedAmount
  };

  private func _startProposalTimer(id : Nat32) : async () {
    ignore setTimer(
      #nanoseconds(duration),
      func() : async () {
        let proposal = _getProposal(id);
        switch (proposal) {
          case (#Ok(proposal)) {
            if (proposal.yay > proposal.nay) {
              let _proposal : Proposal = {
                id = proposal.id;
                proposalType = proposal.proposalType;
                title = proposal.title;
                content = proposal.content;
                yay = proposal.yay;
                nay = proposal.nay;
                ends = proposal.ends;
                createdAt = proposal.createdAt;
                createdBy = proposal.createdBy;
                accepted = true;
                isActive = false;
              };
              Map.set(proposals, n32hash, proposal.id, _proposal);
            } else {
              let _proposal : Proposal = {
                id = proposal.id;
                proposalType = proposal.proposalType;
                title = proposal.title;
                content = proposal.content;
                yay = proposal.yay;
                nay = proposal.nay;
                ends = proposal.ends;
                createdAt = proposal.createdAt;
                createdBy = proposal.createdBy;
                accepted = proposal.accepted;
                isActive = false;
              };
              Map.set(proposals, n32hash, proposal.id, _proposal);
            };
          };
          case (#Err(value)) {

          };
        };
      },
    );
  };

};
