# Orfax discussions

We conducted two meetings with Orfax Team during the Cardano Summit 2025 in Berlin but they were not recorded. The conclusion from those discussion was that the integration with Orcfax protocol will be feasible through a proxy script:

* Orfax delivers signed data points. It also optionally publishes them on the chain in the datum of the UTxO.

* Marlowe requires a choice to be provided by Oracle in order to accept the data point.

* We can create a proxy script dedicated for recognizing the Orfax signed data points.

* There are two further paths for the integration:

  * Either the UTxO locked at the proxy script would hold role token respected by a given Marlowe contract.

  * Or Marlowe validator would be modified to support script addresses and in the case of script address the set of inputs would be checked for an input from that script.

