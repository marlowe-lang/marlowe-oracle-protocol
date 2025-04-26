## Data Availability

Let's build up first some minimal Marlowe contract request structure which makes it useful from the data sharing perspective. We will then move to the security aspect of the data sharing and later on we will dive into the specifics of the datum and the contract state which should be used by the external on-chain data consumers.
Some elements of this scheme require slight extensions to the Marlowe validator and it's tooling. We will indicate those elements in the spec.

### Marlowe Oracle Request

#### Minimal Marlowe Request

As already discussed a minimal protocol request consists of a choice and payout. This structure gives oracle harvester the ability to easily detect requests on the chain together with guarantee of the reward.

  <img src="./diagrams/marlowe-request.svg" alt="Minimal Marlowe Request" width="30%" margin="0 auto" />

On its own this contract structure is not a reliable from the other data consumers point of view. Marlowe validator enforces removal of the contract UTxOs thread together with its the state and choices from the blockchain. For example if we consider the above contract alone data point will disappear from the chain together with transaction in which it is provided because we reach `Close` in that step so validator requires us to not output any Marlowe UTxO.

#### Marlowe Oracle Request with Enforced Delay

Marlowe provides ways to enforce suspension of the contract execution in a predictable way. The ability to delay contract execution can be used to provide guarantees for the consumers that the state information will be present on the chain for a certain amount of time.

  <img src="./diagrams/marlowe-request-delay.svg" alt="Marlowe Request With Delay" style="width: 35%; margin: 4em 0"/>

We propose to use this extra separate step as a basis for reliable data sharing. This step can follow the choice directly or be used as a further step in the contract following for example other choices and payouts. What is important is that the delay is unconditionally present on all the future execution paths.

  <img src="./diagrams/marlowe-request-thread-delay.svg" alt="Marlowe Contract With a Delay Before Close" style="width: 100%;margin: 4em 0"/>

If use this protocol steps we can introduce a data point to a larger self contained Marlowe contract making it also useful for some other data consumers.

### UTxO Level Publishing

#### Reference Inputs And Oracle Data Sharing

* Cardano provides a way to reference UTxO without consuming by including it in reference inputs set of the transaction. Through this mechanism cross smart contract communication and data sharing is possible.

* Referenced inputs are part of the transaction which can be inspected by the transaction validators. Smart contract can inspect referenced UTxO - read its datum, value or check the output address without consuming the other contract input.

* This mechanism is used by existing oracle provides on Cardano and enables access to a published data point. Data points are usually approved directly using an oracle signature under a data point structure.

* The published value can be accessed up until the oracle UTxO is consumed. Accessibility of the value can be critical to dependent on it contracts and this aspect can be resolved on the extra layer of logic possibly implemented by validator which resides on a specific UTxO. There seem to be no standard which is respected across different oracles which can be used for that aspect.

* The publishing strategy does not directly provide a way to enforce payment in exchange for the access to the information. In many cases publishing is driven by an off-chain protocols and payments specific to an oracle.

![Data Publishing](./diagrams/oracle-publishing.svg)

* UTxO data publishing and usage through reference inputs.
  
  <img src="./diagrams/utxo-data-publishing.svg" alt="Data Publishing Using Reference Inputs" style="width: 70%; margin: 4em 0" />

* UTxO level overview of the Marlowe data publishing. This scheme extends the above with the preliminary data point request with subsequent guaranteed fee payout and with visible enforced delay on the contract level to make the data available.
  
  <img src="./diagrams/utxo-marlowe-data-publishing.svg" alt="Data Publishing Using Reference Inputs" style="width: 80%; margin: 4em 0" />
  
#### Authenticity Of The Data

* On the UTxO level Marlowe validator ensures that the transaction which delivers the choice value was signed by a key corresponding to the party from the contract. After that step in the Marlowe UTxO that choice together with the party information and value is kept in a map. This map can accessed by other contracts.
  
  <img src="./diagrams/utxo-marlowe-choice-verification.svg" alt="On-Chain Marlowe Choice Verification" style="width: 60%; margin: 4em 0" />

* On the UTxO it is possible to create an arbitrary output. Malicious actor Eve could fake previously presented output because the choice itself which is stored in the state is not signed by the oracle so she can actually "provide" an arbitrary data point.
  
  <img src="./diagrams/utxo-marlowe-choice-fake.svg" alt="Eve Is Publishing Fake Marlowe Choice" style="width: 55%; margin: 4em 10%" />

* Cardano ledger guarantees that tokens of a specific asset class value can be minted only by a script which hash equals to that class value. In other words token existence is a proof that a specific script was successfully executed. We can use this property and extend Marlowe validator so it can be used for preliminary minting - the minting policy will check if the choices map is initially empty.
  Marlowe spending validator will take care of the token so it never leaks the "execution thread" meaning that it is passed to the transaction output which is a continuation output of the Marlowe contract or it is burned if there is no continuation output.
  Given those assumptions we can conclude that tokens of "Marlowe asset class" will be only present as part of the correct Marlowe execution thread.
  <img src="./diagrams/utxo-marlowe-thread-token.svg" alt="Thread Token Lifecycle" style="width: 45%; margin: 4em 0" />


* Our proposal can Marlowe stores choices and possibly derived values in the state of the contract which is kept in the datum.

* Internally Marlowe itself can express more complex oracle(s) interactions (multi-response averaging, `n of m` checks etc.) to fulfil a specific contract's needs but even in such cases the original oracle choices are present in the state of the contract.

In this spec we describe basic data point sharing which is Marlowe contract logic agnostic. This scheme gives opportunity to use the oracle data in other contracts in a fully trustless way.


---

## Notes and TODO

## How results are made available on-chain to other Cardano smart contracts, including information about the data source, format and rendering.

### Trustless data sharing

* Marlowe does not support signed data requests in the current version. This protocol version proposes to use standard Marlowe approach to data authenticity verification. Marlowe checks signature under the transaction which delivers a particular choice.

* Marlowe provide a way to authorize a steps like choice using token witness scheme but usage of that approach is outside of the scope of this spec.

* When a choice is delivered Marlowe keeps it in the map which associates particular public key and choice name with the value. This piece of data can be easily accessed by other contracts.

* Because the data themselves are not signed, other contracts can not directly verify the authenticity of the data.

* As mentioned above Marlowe validator performs verification on its own but UTxO at validator address with correct datum is not a proper proof of execution.


On the other hand during proper can be used as already validated if we can prove that the validation step was actually performed.
It is possible to artificially create arbitrary UTxO on the chain


![Choice Authenticity](./diagrams/choice-authenticity.svg)
![Choice Fake](./diagrams/choice-fake.svg)
![Thread Token](./diagrams/thread-token.svg)

More advanced data sharing with specific 

`data ChoiceId   = ChoiceId ChoiceName Party`  



## How the results of particular instances of data requests are identified, both within and outside running Marlowe contracts.

## The security model assumed by the oracle protocol.

Brainstorm:

* Marlowe is an interpreted language on the chain. Given a Marlowe contract with some state and assets plus the Marlowe interpreter, it is safe to assume (Plutus implmentation of the interpreter was audited) that the Marlowe contract will be executed as specified by the language semantics and the state and assets will be updated correctly.

* On the chain the above elements are tight to a UTxO:
  * address should point to an official Marlowe interpreter script,
  * datum should contain Marlowe contract and state
  * assets locked in the UTxO should be the assets used in the Marlowe contract (plus minimum ADA).

* Marlowe is expressed using different formats:
  * On the blockchain level the `Contract` and the state by necessity is represented as Plutus core `data` values (https://plutus.cardano.intersectmbo.org/resources/plutus-core-spec.pdf # section 4.3.1.1).
  * On the cross language API level and tooling level we use `Json` or `Yaml` interchangeably. We try to keep that format human readable and easy to use.
  * There is a Haskell derived DSL syntax which is used in some tools (e.g. Marlowe Playground) and in specs. We don't want to discard this case because we expect that this format will be replaced by a proper language in the future versions.

* We provide a set of tools and APIs which translate those formats. The `data` format is the lowest level format and the precise spec for it

* Beside the lower level spec of the format we will provide for TypeScript and Haskell reference implementations:
  * decoders into a JSON format of the Datum
  * libraries which will provide functions which allow indentification of possible oracle requests (Idea: maybe on chain we should require at least some prefix before the hash that suggest that a given choice is possibly an oracle request.)

## Marlowe Plutus `data` Encoding

## TODO:
  * **UTxO level diagram**:
    * Clean up the data point usage script and redeemer - unify it with the above diagram?
    * Make the Tx headers human friendly - drop the tx ids and use readable names
    * Drop margins from the UTxO level diagrams.
  * Drop tx funding utxos?

