import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Map "mo:base/HashMap";
import Hash "mo:base/Hash";
import Iter "mo:base/Iter";

actor Assistant{
  type ToDo = {
    description: Text;
    completed: Bool;
  };

  func natHash(n: Nat) : Hash.Hash {
      Text.hash(Nat.toText(n))
  };
  
  var todos = Map.HashMap<Nat, ToDo>(0, Nat.equal, natHash);
  var nextID : Nat = 0;

  public query func getToDo() : async [ToDo] {
    Iter.toArray(todos.vals());
  };

  public query func addToDo(description : Text) : async Nat {
    let ID = nextID;
    todos.put(ID, {description = description; completed = false});
    nextID += 1;
    ID
  };

  public func completeToDo(ID: Nat): async (){
    ignore do ? {
      let description = todos.get(ID)!.description;
      todos.put(ID, {description; completed=true});
    }
  };

  public query func showToDo() : async Text {
    var output : Text = "\n TO-DO \n";
    for(todo : ToDo in todos.vals()){
      output #= "\n" # todo.description;
      if(todo.completed) {output #= "OK";};
    };
    output # "\n"
  };

  public func clearCompleted() : async () {
    todos := Map.mapFilter<Nat, ToDo, ToDo>(todos, Nat.equal, natHash,
    func(_,todo){if (todo.completed) null else ?todo});
  };
}
