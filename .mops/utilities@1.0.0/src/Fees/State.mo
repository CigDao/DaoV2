import { fromIter; thash } "mo:map/Map";
import MT "mo:map/Map/types";

module {

  public type Fee = Nat64;

  public type State = { var fees : MT.Map<Text, Fee> };

  public func init(arr: [(Text, Fee)]): State = { var fees = fromIter<Text, Fee>(arr.vals(), thash) };

}