# Response to Cardano Oracle CIP Review

### On the Oracle request identification

* Explain how to build the ChoiceName.
* If the contract ask for unknown data (that should be included in query\_result and therefore in resolution) how would the contract designer declare that in the choiceName?
* `query_result` is an schema and not the actual result.
* `query_result` removed completely: the type of the result can be deduced from the API.
* If resolution is a number and it’s expected to be embedded in the ChoiceName, what kind of information would be passed through ChosenNum?
* `resolution` is a process and not the answer.
* `resolution` is the process which is used to convert the result of the query into an Integer; it could be provided by the data or provider, or by the user.
* Should the ChoiceName be interpreted inside the execution of the Marlowe Validator?
* No really by the validator but by the off-chain tooling.
* But it would be possible to use the resolution process to present the data and indeed the contract to end user in a more readable way. This is not part of the CIP; we will mention this in an appendix.
* In the example of the Minimal Marlowe Request, the assumption is that the payment to the oracle is stated in the contract. \[Would\] this payment be satisfied immediately or the oracle will have to wait \[for\] the contract closure?
* Yes, executing the transaction produces a TxOut to the Oracle address.
* It would be possible to extend this process to pay for a number of values in a single payment.
* Document restructured to move content on this earlier, immediately after discussion of Marlowe constructs. **ACTION: Tomasz to check.**
* How do we include our payment design here?
* The proposal is build around Marlowe. Integrations with the Wolfram Oracle are out of the scope.
* No comment

### On the data delivery

* We understand that so far your focus has been only how the request should be performed and not how it should be answered. How should \[it\] be answered by the oracle?
* The Oracle should answer the choice with an integer. The integer is the result of passing the oracle response to the resolution process.
* No comment
* What kind of tools will the Marlowe Validator make available to the users in order to interact with the oracle response.
* This is a work in progress but Marlowe should be able to facilitate the usage of data (going from an integer to the actual data and use it naturally).
* As noted above, in the case of more complex resolution, it could be possible to integrate the resolution process with Marlowe contract execution for an improved user experience, but this is not part of the core CIP.

### On how other users interact with data

* Using Marlowe to publish data through delayed contract wouldn’t be equivalent to create a “Push” model oracles?
* Not really, because the data can be made unavailable after consuming the holder contract.
* No comment
* What’s the users/contract expected behaviour when interacting with a delayed contract?
* The tooling to interpret the ChosenNum should be available for other contracts.
* The ChoiceName contains all the information required to interpret the ChosenNum.
* The delay is made by the Marlowe `When` clause?
* Yes, with `When` and `Notify` input.
* The document diagrams use Marlowe pseudocode to make them more compact; this will be noted in the CIP.

### On the on-chain identification of responses.

* The ChoiceName \+ Oracle Public Key uniquely identifies the choice.

### On security protocols

* In the section thread token, you mention the possibility of implementing an script that validates mints, spends and burn based on the CIP-0069. Does this means migrate the contract version to PlutusV3? or the Plutus Version will remain unaltered?
* Yes, the Plutus version will change at the end of the project.
* No comment
