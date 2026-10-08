# Marlowe datum pieces for the oracle protocol

This spec is based on the normative encoding of the Plutus blueprint tagged on `marlowe-cardano` with `oracle-m1` and located in [marlowe-binaries/blueprints](https://github.com/marlowe-lang/marlowe-cardano/tree/oracle-m1/marlowe-binaries/blueprints). The file quoted below is [`0.3.0-a3929396-d50d5281.plutus.json`](https://github.com/marlowe-lang/marlowe-cardano/blob/oracle-m1/marlowe-binaries/blueprints/0.3.0-a3929396-d50d5281.plutus.json). Type definitions below are quoted from that blueprint.

## Introduction

The Marlowe oracle protocol uses two different readings of the same semantics-validator datum.

An oracle looks at a live continuation for a `Choice` addressed to itself and a `Pay` of its fee. That is a request still to be fulfilled. Another contract looks at choices already made, stored in the state, and needs a reason to trust that history. Those are different pieces of `MarloweData`, so the rest of this note treats them separately.

## Overview of the datum

The entry point is the `MarloweData` type:

```json
{
  "MarloweData": {
    "dataType": "constructor",
    "fields": [
      { "$ref": "#/definitions/MarloweParams" },
      { "$ref": "#/definitions/State" },
      { "$ref": "#/definitions/Contract" }
    ],
    "index": 0
  }
}
```

where

| Field index | Blueprint type  | What an oracle reads                                      |
| ---         | ---             | ---                                                       |
| `0`         | `MarloweParams` | Role-token currency.                                      |
| `1`         | `State`         | Accounts, choice history, bound values, and minimum time. |
| `2`         | `Contract`      | Continuation                                              |

## Choice detection and fee payout


An oracle detects a request in the continuation Contract, field `2` of `MarloweData` (the whole datum). It sits in the continuation `Contract`. That continuation is a constructor sum: each index is one Marlowe term, and the fields of that constructor are the term's arguments, in order. The two terms an oracle inspects are `Pay` (index: `1`) and `When` (index: `3`):

```json
{
  "Contract": {
    "oneOf": [
      { "dataType": "constructor", "fields": [ "...Close..." ], "index": 0 },
      {
        "dataType": "constructor",
        "fields": [
          { "$ref": "#/definitions/Party" },
          { "$ref": "#/definitions/Payee" },
          { "$ref": "#/definitions/Token" },
          { "$ref": "#/definitions/Value<Observation>" },
          { "$ref": "#/definitions/Contract" }
        ],
        "index": 1
      },
      { "dataType": "constructor", "fields": [ "...If..." ], "index": 2 },
      {
        "dataType": "constructor",
        "fields": [
          { "$ref": "#/definitions/List<Case<Contract>>" },
          { "$ref": "#/definitions/POSIXTime" },
          { "$ref": "#/definitions/Contract" }
        ],
        "index": 3
      },
      { "dataType": "constructor", "fields": [ "...Let..." ], "index": 4 },
      { "dataType": "constructor", "fields": [ "...Assert..." ], "index": 5 }
    ]
  }
}
```

| Index | Term   | Fields                                       |
| ---   | ---    | ---                                          |
| 1     | `Pay`  | Account, payee, token, amount, continuation. |
| 3     | `When` | Cases, timeout, timeout continuation.        |

The oracle looks for a `When` whose cases include a `Choice` addressed to itself, and for a `Pay` in that choice's continuation that pays the fee back to the same party. The other constructors are not part of the request; a walk only descends through them to reach these two.

### Identifying the `Choice`

Cases of a `When` are `Case<Contract>`. The action sits in the first field of either constructor:

```json
{
  "Case<Contract>": {
    "oneOf": [
      {
        "dataType": "constructor",
        "fields": [
          { "$ref": "#/definitions/Action" },
          { "$ref": "#/definitions/Contract" }
        ],
        "index": 0
      },
      {
        "dataType": "constructor",
        "fields": [
          { "$ref": "#/definitions/Action" },
          { "$ref": "#/definitions/BuiltinByteString" }
        ],
        "index": 1
      }
    ]
  }
}
```

Index `0` is an inline case: the second field is the continuation contract. Index `1` is a merkleized case: the second field is only the hash of that continuation. Index `1` still exposes the action, so the oracle can see that it is being asked. It does not expose the continuation, so the fee `Pay` cannot be recovered from the datum alone. A paid request therefore needs case index `0`, unless the preimage of index `1` is supplied out of band. In that inline continuation the oracle looks for a `Pay` back to itself, as described under Identifying the `Pay`.

The tagged blueprint's `$ref` on the inline continuation says `Value<Contract>`; the field is a `Contract`, which is what the hash in index `1` stands for.

The action the oracle matches is constructor `1` of `Action` which is a `Choice` with two fields: the `ChoiceId` and a list of inclusive bounds (in esssence, a range of possible integers).

```json
{
  "Action": {
    "oneOf": [
      { "dataType": "constructor", "fields": [ "...Deposit..." ], "index": 0 },
      {
        "dataType": "constructor",
        "fields": [
          { "$ref": "#/definitions/ChoiceId" },
          { "$ref": "#/definitions/List<Bound>" }
        ],
        "index": 1
      },
      { "dataType": "constructor", "fields": [ "...Notify..." ], "index": 2 }
    ]
  }
}
```

`ChoiceId` names the query and the party who may answer it:

```json
{
  "ChoiceId": {
    "dataType": "constructor",
    "fields": [
      { "$ref": "#/definitions/BuiltinByteString" },
      { "$ref": "#/definitions/Party" }
    ],
    "index": 0
  }
}
```

The byte string is the choice name. In this protocol that name is the query; please check the official CIP spec for more details about query encoding. A request matches only if that party is the oracle's own party. Only the address arm of `Party` is relevant here:

```json
{
  "Party": {
    "oneOf": [
      {
        "dataType": "constructor",
        "fields": [
          { "$ref": "#/definitions/Bool" },
          { "$ref": "#/definitions/Address" }
        ],
        "index": 0
      },
      { "dataType": "constructor", "fields": [ "...Role..." ], "index": 1 }
    ]
  }
}
```

Index `0` is a network flag and a Plinth address. The network flag is informative only, and an oracle can ignore it (the script does not check it against the network it is running on). What it matches, and what must sign the choice, is the payment credential inside `Address`. Index `1` is a role name and is not an oracle party in this protocol. `List<Bound>` is the inclusive ranges the chosen integer must lie in; each `Bound` is constructor `0` of two integers.

### Identifying the `Pay`

The fee is contract constructor `1` in the continuation of that inline choice case. Its second field is the payee:

```json
{
  "Payee": {
    "oneOf": [
      { "dataType": "constructor", "fields": [ "...Account..." ], "index": 0 },
      {
        "dataType": "constructor",
        "fields": [ { "$ref": "#/definitions/Party" } ],
        "index": 1
      }
    ]
  }
}
```

Index `0` pays into an internal account. Index `1` pays a party outside the contract. The oracle fee is index `1`, and the party is the same party as in the `ChoiceId`. The third field of the `Pay` is the token (lovelace is the empty currency symbol and the empty token name). The fourth field is the amount. A split fee is more than one such `Pay` before the continuation uses the chosen value.

## Choice read-out by other consumers

A consumer who wants to access the Oracle choice on the chain does not walk the continuation. It reads a choice already made. That value is the `choices` field, the second field of `State`. `State` itself is the second field of `MarloweData`.

```json
{
  "State": {
    "dataType": "constructor",
    "fields": [
      { "$ref": "#/definitions/Map<Tuple2<Party,Token>,Integer>" },
      { "$ref": "#/definitions/Map<ChoiceId,Integer>" },
      { "$ref": "...boundValues..." },
      { "$ref": "...minTime..." }
    ],
    "index": 0
  }
}
```

| Field     | Blueprint type          | What a consumer reads                                 |
| ---       | ---                     | ---                                                   |
| `1`       | `Map<ChoiceId,Integer>` | Query, oracle party, and the integer that was chosen. |

Accounts, bound values, and the minimum time are not part of the publication. The map itself is:

```json
{
  "Map<ChoiceId,Integer>": {
    "dataType": "map",
    "keys": { "$ref": "#/definitions/ChoiceId" },
    "values": { "$ref": "#/definitions/Integer" }
  }
}
```

The key is the same `ChoiceId` as in the request: constructor `0` of the choice-name bytes and the oracle `Party`. The value is the chosen integer. Two oracles can use the same query name; they are different keys, because the party differs. A lookup matches both fields, compared as encoded `Data`.

The map is empty while the request is still open. The semantics validator inserts the entry when the `Choice` is applied. `Pay` and `Close` are not suspension points, so a continuation that pays the fee and closes never leaves that entry on a UTxO. A consumer can read it only while that continuation is still an unspent output, which is what the enforced delay (`When` with no cases until a later timeout) is for.

The map is not self-authenticating. The tagged validator does not enforce a thread token, and `MarloweParams`, the role-token currency, is not one. The datum check is the entry above. Once the validator enforces the token, the UTxO check is that the output sits at the semantics script `a392939637fddb657f5ccd54a13067e6cc55f06c0f8fdaf8969cedd0` and carries the contract's thread token, minted at the start and preserved on every continuation. That mint is also the proof that `choices` started empty, so a later entry was inserted only by a validated choice.
