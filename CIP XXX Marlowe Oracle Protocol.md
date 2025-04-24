\---  
CIP: XXX  
Title: Marlowe Oracle Protocol  
Status: Proposed  
Category: ???  
Authors:  
    \- Tomasz Rybarczyk \<tomasz.rybarczyk@marlowe-lang.org\>  
    \- Simon Thompson \<simon.thompson@marlowe-lang.org\>  
    \- Nicolas Henin \<nicolas.henin@marlowe-lang.org\>  
Implementors: N/A  
Discussions: ???  
Created: 2025-04-03  
License: CC-BY-4.0  
—

## Abstract	

A short (\~200 word) description of the proposed solution and the technical issue being addressed.

Smart contracts running on Cardano require access to external data of various kinds from Oracle providers: exchange rates between crypto- and fiat currencies; “real world” data, such as weather information; information of significance for betting and gaming apps, including details of play from sporting events; and, not least, reliable and secure sources of randomness. Current Cardano Oracles primarily push a fixed repertoire of data on-chain, critically limiting their ability to provide the range and depth of data outlined above. 

This CIP describes a more flexible, transparent and composable Oracle solution for Cardano, based on the Marlowe smart contract language, using the Choice construct in Marlowe to deliver the oracle value within a running smart contract, as well as making that value available to other Cardano other smart contacts, whether written in Marlowe, Aiken, Plutus or other languages.

`fish`  
\[134 words\]

## Motivation: why is this CIP necessary?	

A clear explanation that introduces a proposal's purpose, use cases, and stakeholders. If the CIP changes an established design, it must outline design issues that motivate a rework. For complex proposals, authors must write a Cardano Problem Statement (CPS) as defined in CIP-9999 and link to it as the Motivation.

External data is used within the vast majority of smart contracts running on blockchain, and provision of this data by Oracle providers is essential to these contracts running effectively and securely. The “push” model of data provides an 80:20 solution: 80% of needs are satisfied by a limited set of data feeds, particularly those based on DeFi information of various kinds; it is, however, unable to service the “long tail” of potential demands for data of a more specialized kind, and to do this in practice a “pull” model of data provision is required. 

The mechanism outlined delivers data through the Choice construct in the Marlowe smart contract language. Executing an instance of this construct in a running contract delivers an external integer value that can be directly accessed within the contact, and also be made available for use by other smart contracts on Cardano. 

For this approach to work in practice, this CIP needs to address the following high-level questions:

* How to identify what data is requested, and from which source (including an access mechanism for the source?).  
* How results of oracle requests are rendered for use within Marlowe.  
* How results are made available on-chain to other Cardano smart contracts, including information about the data source, format and rendering.  
* How the results of particular instances of data requests are identified, both within and outside running Marlowe contracts.  
* The security model assumed by the oracle protocol.

These high-level questions are answered in the next section, together with a discussion of implementation-related issues such as timeouts and error handling, and potential extensions of the protocol, such as access mechanisms.

## Specification	

The technical specification should describe the proposed improvement in sufficient technical detail. In particular, it should provide enough information that an implementation can be performed solely based on the design outlined in the CIP. A complete and unambiguous design is necessary to facilitate multiple interoperable implementations.

This section must address the Versioning requirement unless this is addressed in an optional Versioning section.

If a proposal defines structure of on-chain data it must include a CDDL schema.

This section described the Marlowe Oracle Protocol in detail. Assumptions made in the description are listed here, before the specification itself.

### Assumptions 

* No distinction is made between the data source and the oracle provider. In future versions of this protocol, this distinction may be possible.  
* IPFS is used as a standard for content-addressable off-chain data here; other equivalent mechanisms may be used.  
* We take a pragmatic approach to trust, assuming that users of the system are able to identify trustworthy oracles for themselves.

The Marlowe Oracle protocol is based on using the choice mechanism in Marlowe, by which choices “external” to a contract are made available to the contract. The Marlowe construct that handles external actions is `When`, which selects between a number of `Case`s. Each `Case` is triggered an `Action`: in this case the `Choice` action. On that action happening, the continuation contract is initiated; if no action is made before the timeout, the fallback contract is initiated: we assume that in this case it is `Close`, which closes contract operation, refunding any funds in the contract to the participants. The relevant Marlowe syntax constructs are (eliding irrelevant constructors):

`data Contract = … | When [Case] Timeout Contract | …`  
`data Case     = Case Action Contract`  
`data Action   = … | Choice ChoiceId [Bound] | …`

Choices are identified by a `ChoiceId`, which combines a `ChoiceName` – a `ByteString` – with a `Party` to the contract. On forming the action, a set of `Bound`s are given that constrain the `Integer` value to be chosen.

`data ChoiceId   = ChoiceId ChoiceName Party`  
`type ChoiceName = ByteString`  
`data Bound      = Bound Integer Integer`

The `ChoiceId` construct is used to describe an oracle value: 

* The `Party` is `PubKey pkh`, where `pkh` is the hash of a public key for the oracle that is the source of the data.  
* The `ChoiceName` ByteString is used to identify the data requested, and the specific request itself. We discuss this in detail now.

The `ChoiceName` byte string is used to describe a collection of data: 

| layout | data\_source | API | data\_query | query\_result | resolution | … |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |

* The first 32 bytes describe the **layout** of the remainder of the byte string, namely its length, and the names and lengths of the remaining fields.   
* Any fields may be present, but the fields **data\_source**, **API**, **data\_query**, **query\_result** and **resolution** must be included.

A running example, based on oracle data from Wolfram Blockchain Labs, as documented [here](https://docs-ccdb.waexservices.com/), is used to illustrate the remainder of the description.

The **data\_source** should be the root URL for the oracle service whose public key is in the `Party` component of the `ChoiceId` of which this `ChoiceName` is the other component.  
In the running example of services provided by Wolfram Blockchain Labs this field would be [https://access.ccdb.waexservices.com](https://access.ccdb.waexservices.com).

The **API** should point to a description of the API for the data provider. This can take a number of forms, including.

* The root URL for the web page which can reliably and safely translate a given \`data\_query\` (which could be a hash or machine readable version of the query) to a human readable form.   
* The root URL for the API documentation for the interface for the data provider. In the running example this would be [https://docs-ccdb.waexservices.com](https://docs-ccdb.waexservices.com).   
* In the case that there is no published interface, an anchor that points to a file in IPFS containing a sufficient description to understand the particular data\_query, query\_result and resolution for this particular choice.

The **data\_query** should contain a query to the data\_source that conforms to the API. 

* In the case of the running example this will be a URL making a GET request to the endpoint for the service, defined according to the standard in the API.    
* Instead of a query, the field may contain the anchor for an IPFS file containing the query.  
* The query encoding can be also encoded using a custom format not suitable for human consumption which should be resolved and explained by the API. 

The **result** should contain an anchor for an IPFS file that contains the result of the query, and a description of how an Integer is extracted from the result, which is called the *resolution* of the query. 

* In the case of the running example, results are returned in JSON format, and the resolution will typically involve  
  * Selecting a field or fields  
  * Converting those fields to numbers  
  * Aggregating those numbers into a single Integer.

The **resolution** should contain an Integer, constructed according to the description in the **result**. 

**// How results are made available on-chain to other Cardano smart contracts, including information about the data source, format and rendering.**

* **I did a breakdown of the Marlowe datum format here:** 

## Rationale: how does this CIP achieve its goals?	

The rationale fleshes out the specification by describing what motivated the design and what led to particular design decisions. It should describe alternate designs considered and related work. The rationale should provide evidence of consensus within the community and discuss significant objections or concerns raised during the discussion.

It must also explain how the proposal affects the backward compatibility of existing solutions when applicable. If the proposal responds to a CPS, the 'Rationale' section should explain how it addresses the CPS and answer any questions that the CPS poses for potential solutions.

TO DO

## Path to Active	

Organised in two sub-sections (see Path to Active for detail):

* Acceptance Criteria  
  Describes what are the acceptance criteria whereby a proposal becomes 'Active'.  
* Implementation Plan  
  Either a plan to meet those criteria or N/A if not applicable.

TO DO

## Optional Sections	

May appear in any order, or with custom titles, at author and editor discretion:

* Versioning: if Versioning is not addressed in Specification  
* References  
* Appendices  
* Acknowledgements

TO DO

## Copyright	

The CIP must be explicitly licensed under acceptable copyright terms (see below).

TO DO

