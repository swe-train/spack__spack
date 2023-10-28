% Variant propagation is forwarded to dependencies
attr("variant_propagation_candidate", PackageNode, Variant, Value, Source) :-
  attr("node", PackageNode),
  depends_on(ParentNode, PackageNode),
  attr("variant_value", node(_, Source), Variant, Value),
  attr("variant_propagation_candidate", ParentNode, Variant, _, Source).

% If the node is a candidate, and it has the variant and value,
% then those variant and value should be propagated
attr("variant_propagate", node(ID, Package), Variant, Value, Source) :-
  attr("variant_propagation_candidate", node(ID, Package), Variant, Value, Source),
  node_has_variant(node(ID, Package), Variant, _),
  variant_possible_value(node(ID, Package), Variant, Value),
  not attr("variant_set", node(ID, Package), Variant).

% Propagate the value, if there is the corresponding attribute
attr("variant_value", PackageNode, Variant, Value) :-
  attr("variant_propagate", PackageNode, Variant, Value, _).

% If a variant is propagated, we cannot have extraneous values (this is for multi valued variants)
variant_is_propagated(PackageNode, Variant) :-
  attr("variant_propagate", PackageNode, Variant, _, _).

:- variant_is_propagated(PackageNode, Variant),
   attr("variant_value", PackageNode, Variant, Value),
   not attr("variant_propagate", PackageNode, Variant, Value, _).

% Cannot receive different values from different sources on the same variant
error(100, "{0} and {1} cannot both propagate variant '{2}' to package {3} with values '{4}' and '{5}'", Source1, Source2, Variant, Package, Value1, Value2) :-
  attr("variant_propagate", node(X, Package), Variant, Value1, Source1),
  attr("variant_propagate", node(X, Package), Variant, Value2, Source2),
  node_has_variant(node(X, Package), Variant, _),
  Value1 < Value2, Source1 < Source2.
