# Wolfram Marlowe Oracle discussion 16-09-2025

The meeting will be recorded and a transcript produced. The Marlowe team agreed to produce a summary of the discussion, which constitutes this document. The notes are roughly chronological, but some items have been moved to group them with others, for example.

The Wolfram team wants to discuss the proposed Marlowe oracle model and in particular how to identify what data the contract requests, how the results are used in Marlowe, and how data is made available for other Cardano smart contracts (which could open a much wider use cases for the Wolfram oracle). Finally, how to identify particular instances of \[oracle\] data inside and outside Marlowe, and what kind of security protocol the oracle protocol supports.

## Background

The Marlowe team confirmed that they were looking for comments on the proposed protocol, and particularly the core aspects of this, and to identify aspects that might be missing, erroneous, or contradictory. The team also stated that the core proposal aims to be a minimal viable proposition, containing the essential elements of the idea, deliberately making other aspects addition or desirable: this would include, for example, leaving undecided who might take responsibility for encoding end user queries, or translate the results of complex queries into the integers required by the Marlowe Choice construct.

The Marlowe project is no longer supported by IOG, but it is supported by the Marlowe Language CIC, a UK non-profit organisation. This received some initial funding from IOG that will support the organisation and its IT infrastructure until at least the end of 2027\.

## Queries

There was discussion of the format of the query as a CSV string as part of a Marlowe choice construct, and the restrictions that there would be on this because of the constraints of the \[Cardano\] blockchain . The team confirmed that the string could (would) indeed contain references to immutable off-chain storage, and so the limits could be circumvented by storing large queries off the blockchain. It was also agreed that the result of the query itself would be stored on-chain as part of the datum, but that this would not impose size constraints.

In general there are constraints on Marlowe contracts imposed by the limitations of the blockchain, and these constraints can be checked for users and contract authors by static analysis before contracts are executed.

There was discussion about the responsibility for creating or encoding the query; while it is possible for any end user to encode and store a query (e.g. as a URL) in IPFS, this might be seen as an obstacle for the end user, and so this could be done e.g. by an oracle service.

## Resolution

The Marlowe team confirmed that the initial proposal expects the Oracle provider to perform the “resolution” of complex query results into integers. There was also some discussion of the reason that the Choice construct takes integer bounds: the Marlowe team responded that this generalises the Boolean option (of 0 or 1, say) but retains the finiteness of the choice. 

The Wolfram team also mentioned the choices used in the widely-used escrow example, which uses a “choose 1 of 1” style choice. This results in an ACTION for the Marlowe team: should there be any constraints on the Marlowe contracts that use oracle choices.

## Timeout and failure

The Marlowe team described that all Marlowe choice constructs would be contained in a When, that would have a timeout continuation to be invoked in the case that no response is forthcoming, making it the responsibility of the contract author to deal sensibly with this possibility. Typically this would be dealt with using a contract Close that restores funds held by the contract to the holders of accounts in the particular contract instance. 

This responsibility would carry over to authors of contracts that use Oracle values too, so that they need to be aware of and take account of the possibility that values might not be available, and that this should be dealt with (in a way that does not present a potential attack vector to a hostile party).

It would also be the case that the Oracle service would have no responsibility to respond to ill-formed or nonsensical queries, the expected action from the Oracle would be no response. It would also bear no responsibility for the way in which data is used by any Marlowe contract.

Finally, there was discussion about the time at which the Oracle service is required to deliver results. The Oracle would be expected to deliver timestamped data, and the contract could e.g. delay until a particular time point for issuing a request, but beyond this the model underlying the service is soft real-time at best. 

## Marlowe language extensions

The Marlowe team is actively seeking further Catalyst funding for a language review and update, and as a part of this it will examine potential changes that will support the Oracle protocol including

* Recognition and Verification of particular Oracle providers (such as Wolfram) by the Marlowe on-chain tooling;  
* A “conjunction” that will support collecting results of multiple choices in a single construct;  
* Supporting choice provision and payment in a single construct.  
* Provision of Oracle choice resolution (translation of Oracle results into integers for use by a Marlowe contract).

## Aiken language bindings

The Marlowe team confirmed that it will supply (as Milestone 3 of its Catalyst Fund 13 project) an API that will allow Aiken contracts to use the Marlowe Oracle mechanism, thus demonstrating how information provided within a Marlowe contract can be used by other smart contracts on the Cardano blockchain.
