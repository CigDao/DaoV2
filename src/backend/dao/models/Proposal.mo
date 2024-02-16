module {
    public type ProposalType = {
        #poll
    };

    public type Proposal = {
        id:Nat32;
        proposalType:ProposalType;
        title:Text;
        content:Text;
        yay:Nat;
        nay:Nat;
        ends:Int;
        createdAt:Int;
        createdBy:Text;
        accepted:Bool;
        isActive:Bool;
    };

    public type ProposalRequest = {
        proposalType:ProposalType;
        title:Text;
        content:Text;
        ends:Int;
    };
}
