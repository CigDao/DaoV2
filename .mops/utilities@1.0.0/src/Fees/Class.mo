import { put = mapPut; get = mapGet; thash } "mo:map/Map";
import S "State";

module {

  public type Return = { #ok: Nat64; #err: Error };

  public type Error = { #fee_not_defined: Text };

  public class Fees(state: S.State) = {

    public func set(k: Text, v: S.Fee) = ignore mapPut<Text, S.Fee>(state.fees, thash, k, v);

    public func get(k: Text): Return {
      switch( mapGet<Text, S.Fee>(state.fees, thash, k) ){
        case null #err( #fee_not_defined(k) );
        case( ?fee ) #ok( fee );
      }
    };

    public func multiply(k: Text, n: Nat64): Return {
      switch( mapGet<Text, S.Fee>(state.fees, thash, k) ){
        case null #err( #fee_not_defined(k) );
        case( ?fee ) #ok( fee * n );
      }
    };

  };

}