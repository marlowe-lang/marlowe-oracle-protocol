# Example contract execution

This document is based on a tagged version of `marlowe-cardano` with `oracle-m1`.

## Test scenario

The integration test which was used can be found here:

  * The contract construction is located in [marlowe-integration/**/contracts/bet.ts](https://github.com/marlowe-lang/marlowe-cardano/tree/oracle-m1/marlowe-integration/app/src/testing/contracts/bet.ts).

  * The actual test scenario is located in [marlowe-integration/**/e2e/]( https://github.com/marlowe-lang/marlowe-cardano/tree/oracle-m1/marlowe-integration/app/src/testing/e2e/selectiveStoredBetWithEnforcedDelay.ts).

The contract is a simple bet between two parties, with an oracle providing the outcome of the bet.

* The contract uses simplified query format assuming that all the parties including Oracle can uniquely identify the choice by that name "team-1-vs-team-2".

* The contract is "selectively" merkleized, meaning that the oracle's choice is not merkleized.

* The thread token is in use and can be located from the beginning till the end of the execution in the Marlowe output of the transaction.


## Execution log

### Wallets (created at test time, funded by the faucet)

| Role   | Address                                                    | Note                                                  |
|---     |---                                                         |---                                                    |
| faucet | `addr_test1qp9aye45y…su603vgfzjqdqg3gl`                    | `wallets-preprod/wallet-1` (1312 ADA at start of run) |
| party1 | `addr_test1vz97dydae…twpp3cjem4u5`                         | freshly created, 20 ADA funded by faucet              |
| party2 | `addr_test1vqn9sl3em…99qu2cg89`                            | freshly created, 20 ADA funded by faucet              |
| oracle | `addr_test1vqf65039n…gmpzkghn2lnkych4cuhd7t4da8fv4qug3yr9` | freshly created, 20 ADA funded by faucet              |

### Transactions on chain (Preprod, all via the local cardano-node socket)

| Index | Phase                                                      | Tx hash                                                                                                                                                                           | Notes                                                   |
|---    |---                                                         |---                                                                                                                                                                                |---                                                      |
| `0`   | Init contract from source id                               | [`ad1f65ccf74f81b6de011aa511a732015e3671082e971f57749b295f06c5b66c`](https://preprod.cardanoscan.io/transaction/ad1f65ccf74f81b6de011aa511a732015e3671082e971f57749b295f06c5b66c) | Marlowe output is #1 and locks the thread token.        |
| `1`   | Party1 deposit (5.05 ADA = 5 ADA stake + 50k lovelace fee) | [`608e38912f237a7ac47432f5b5a119b20fa86e1b77033ed589aa6fb4bf42400d`](https://preprod.cardanoscan.io/transaction/608e38912f237a7ac47432f5b5a119b20fa86e1b77033ed589aa6fb4bf42400d) |                                                         |
| `2`   | Party2 deposit (5.05 ADA)                                  | [`c3e5562dde79ee61de00165bf3daa8d1afb7fc0b96150001579d0b1776312a2c`](https://preprod.cardanoscan.io/transaction/c3e5562dde79ee61de00165bf3daa8d1afb7fc0b96150001579d0b1776312a2c) | Contract reduces to **not merkleized** oracle `Choice`. |
| `3`   | Oracle choice (no-winners = 0)                             | [`ea2912b7679f51aaaf7fc58378bc0087c46e6f0bbb1e806be0d000f3c3dc4239`](https://preprod.cardanoscan.io/transaction/ea2912b7679f51aaaf7fc58378bc0087c46e6f0bbb1e806be0d000f3c3dc4239) | Contract reduces to the merkleized continuation.        |
| `4`   | **Notify** (the on-chain delay step — the new action)      | [`7519fe91b862ca5f9875f559deced3e6b5416c769b2658d72f64d23ae1986674`](https://preprod.cardanoscan.io/transaction/7519fe91b862ca5f9875f559deced3e6b5416c769b2658d72f64d23ae1986674) | `Notify` input closes the delayed contract.             |


## Runtime log 

The below is a summary obtained from the marlowe runtime API and provides a detailed overview on the same set of transactions. We combined the results from the endpoint


```json
[
  {
    "index": 0,
    "transactionId": "7519fe91b862ca5f9875f559deced3e6b5416c769b2658d72f64d23ae1986674",
    "block": {
      "blockHeaderHash": "c6cb7ddeddab7ab4bb33da260fd2c6d49f1f41df8ecdca09cc3cde5633262631",
      "blockNo": 5268152,
      "slotNo": 135775645
    },
    "consumingTx": null,
    "status": "confirmed",
    "invalidBefore": "2026-10-08T11:26:46Z",
    "invalidHereafter": "2026-10-08T17:24:45Z",
    "inputs": [
      "input_notify"
    ],
    "interval": {
      "from": 1791458806000,
      "to": 1791480284999
    },
    "outputContract": "close",
    "payments": [
      {
        "amount": 1301620,
        "payment_from": {
          "address": "addr_test1qp9aye45yg6lds7gfqxnkm7et7yyzc9nc99wsnv5269n4ktyx6qgluxy66y8sv0mh4ng0aeq6yxpxlh9ysu603vgfzjqdqg3gl"
        },
        "to": {
          "party": {
            "address": "addr_test1qp9aye45yg6lds7gfqxnkm7et7yyzc9nc99wsnv5269n4ktyx6qgluxy66y8sv0mh4ng0aeq6yxpxlh9ysu603vgfzjqdqg3gl"
          }
        },
        "token": {
          "currency_symbol": "",
          "token_name": ""
        }
      },
      {
        "amount": 5000000,
        "payment_from": {
          "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
        },
        "to": {
          "party": {
            "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
          }
        },
        "token": {
          "currency_symbol": "",
          "token_name": ""
        }
      },
      {
        "amount": 5000000,
        "payment_from": {
          "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
        },
        "to": {
          "party": {
            "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
          }
        },
        "token": {
          "currency_symbol": "",
          "token_name": ""
        }
      }
    ],
    "payouts": []
  },
  {
    "index": 1,
    "transactionId": "ea2912b7679f51aaaf7fc58378bc0087c46e6f0bbb1e806be0d000f3c3dc4239",
    "block": {
      "blockHeaderHash": "d87a066466270c6623bbfcfc889d0e3dc15aae5be8d1be1adfe8e388dc063c09",
      "blockNo": 5268151,
      "slotNo": 135775606
    },
    "consumingTx": "7519fe91b862ca5f9875f559deced3e6b5416c769b2658d72f64d23ae1986674",
    "status": "confirmed",
    "invalidBefore": "2026-10-08T11:26:34Z",
    "invalidHereafter": "2026-10-08T17:24:45Z",
    "inputs": [
      {
        "for_choice_id": {
          "choice_name": "team-1-vs-team-2",
          "choice_owner": {
            "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
          }
        },
        "input_that_chooses_num": 0
      }
    ],
    "interval": {
      "from": 1791458794000,
      "to": 1791480284999
    },
    "outputContract": {
      "timeout": 1791480285778,
      "timeout_continuation": "close",
      "when": [
        {
          "case": {
            "notify_if": true
          },
          "then": "close"
        }
      ]
    },
    "payments": [
      {
        "amount": 50000,
        "payment_from": {
          "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
        },
        "to": {
          "party": {
            "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
          }
        },
        "token": {
          "currency_symbol": "",
          "token_name": ""
        }
      },
      {
        "amount": 50000,
        "payment_from": {
          "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
        },
        "to": {
          "party": {
            "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
          }
        },
        "token": {
          "currency_symbol": "",
          "token_name": ""
        }
      }
    ],
    "payouts": []
  },
  {
    "index": 2,
    "transactionId": "c3e5562dde79ee61de00165bf3daa8d1afb7fc0b96150001579d0b1776312a2c",
    "block": {
      "blockHeaderHash": "716dc7b0bf9d385db87027d05192e6e6c7098fb18d4c8e464060c84d4d64ba91",
      "blockNo": 5268150,
      "slotNo": 135775594
    },
    "consumingTx": "ea2912b7679f51aaaf7fc58378bc0087c46e6f0bbb1e806be0d000f3c3dc4239",
    "status": "confirmed",
    "invalidBefore": "2026-10-08T11:26:00Z",
    "invalidHereafter": "2026-10-08T17:24:45Z",
    "inputs": [
      {
        "continuation_hash": "7e67f52c12df296be5db094da9f2e876560af7160784abddc4195fe86ad3b272",
        "input_from_party": {
          "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
        },
        "into_account": {
          "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
        },
        "merkleized_continuation": {
          "timeout": 1791480285778,
          "timeout_continuation": "close",
          "when": [
            {
              "case": {
                "choose_between": [
                  {
                    "from": 0,
                    "to": 2
                  }
                ],
                "for_choice": {
                  "choice_name": "team-1-vs-team-2",
                  "choice_owner": {
                    "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                  }
                }
              },
              "then": {
                "from_account": {
                  "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
                },
                "pay": 50000,
                "then": {
                  "from_account": {
                    "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
                  },
                  "pay": 50000,
                  "then": {
                    "else": {
                      "else": {
                        "timeout": 1791480285778,
                        "timeout_continuation": "close",
                        "when": [
                          {
                            "case": {
                              "notify_if": true
                            },
                            "then": "close"
                          }
                        ]
                      },
                      "if": {
                        "equal_to": 2,
                        "value": {
                          "value_of_choice": {
                            "choice_name": "team-1-vs-team-2",
                            "choice_owner": {
                              "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                            }
                          }
                        }
                      },
                      "then": {
                        "from_account": {
                          "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
                        },
                        "pay": 5000000,
                        "then": {
                          "timeout": 1791480285778,
                          "timeout_continuation": "close",
                          "when": [
                            {
                              "case": {
                                "notify_if": true
                              },
                              "then": "close"
                            }
                          ]
                        },
                        "to": {
                          "party": {
                            "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
                          }
                        },
                        "token": {
                          "currency_symbol": "",
                          "token_name": ""
                        }
                      }
                    },
                    "if": {
                      "equal_to": 1,
                      "value": {
                        "value_of_choice": {
                          "choice_name": "team-1-vs-team-2",
                          "choice_owner": {
                            "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                          }
                        }
                      }
                    },
                    "then": {
                      "from_account": {
                        "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
                      },
                      "pay": 5000000,
                      "then": {
                        "timeout": 1791480285778,
                        "timeout_continuation": "close",
                        "when": [
                          {
                            "case": {
                              "notify_if": true
                            },
                            "then": "close"
                          }
                        ]
                      },
                      "to": {
                        "party": {
                          "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
                        }
                      },
                      "token": {
                        "currency_symbol": "",
                        "token_name": ""
                      }
                    }
                  },
                  "to": {
                    "party": {
                      "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                    }
                  },
                  "token": {
                    "currency_symbol": "",
                    "token_name": ""
                  }
                },
                "to": {
                  "party": {
                    "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                  }
                },
                "token": {
                  "currency_symbol": "",
                  "token_name": ""
                }
              }
            }
          ]
        },
        "of_token": {
          "currency_symbol": "",
          "token_name": ""
        },
        "that_deposits": 5050000
      }
    ],
    "interval": {
      "from": 1791458760000,
      "to": 1791480284999
    },
    "outputContract": {
      "timeout": 1791480285778,
      "timeout_continuation": "close",
      "when": [
        {
          "case": {
            "choose_between": [
              {
                "from": 0,
                "to": 2
              }
            ],
            "for_choice": {
              "choice_name": "team-1-vs-team-2",
              "choice_owner": {
                "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
              }
            }
          },
          "then": {
            "from_account": {
              "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
            },
            "pay": 50000,
            "then": {
              "from_account": {
                "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
              },
              "pay": 50000,
              "then": {
                "else": {
                  "else": {
                    "timeout": 1791480285778,
                    "timeout_continuation": "close",
                    "when": [
                      {
                        "case": {
                          "notify_if": true
                        },
                        "then": "close"
                      }
                    ]
                  },
                  "if": {
                    "equal_to": 2,
                    "value": {
                      "value_of_choice": {
                        "choice_name": "team-1-vs-team-2",
                        "choice_owner": {
                          "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                        }
                      }
                    }
                  },
                  "then": {
                    "from_account": {
                      "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
                    },
                    "pay": 5000000,
                    "then": {
                      "timeout": 1791480285778,
                      "timeout_continuation": "close",
                      "when": [
                        {
                          "case": {
                            "notify_if": true
                          },
                          "then": "close"
                        }
                      ]
                    },
                    "to": {
                      "party": {
                        "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
                      }
                    },
                    "token": {
                      "currency_symbol": "",
                      "token_name": ""
                    }
                  }
                },
                "if": {
                  "equal_to": 1,
                  "value": {
                    "value_of_choice": {
                      "choice_name": "team-1-vs-team-2",
                      "choice_owner": {
                        "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                      }
                    }
                  }
                },
                "then": {
                  "from_account": {
                    "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
                  },
                  "pay": 5000000,
                  "then": {
                    "timeout": 1791480285778,
                    "timeout_continuation": "close",
                    "when": [
                      {
                        "case": {
                          "notify_if": true
                        },
                        "then": "close"
                      }
                    ]
                  },
                  "to": {
                    "party": {
                      "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
                    }
                  },
                  "token": {
                    "currency_symbol": "",
                    "token_name": ""
                  }
                }
              },
              "to": {
                "party": {
                  "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
                }
              },
              "token": {
                "currency_symbol": "",
                "token_name": ""
              }
            },
            "to": {
              "party": {
                "address": "addr_test1vqf65039n6xylsqgv8mpzkghn2lnkych4cuhd7t4da8fv4qug3yr9"
              }
            },
            "token": {
              "currency_symbol": "",
              "token_name": ""
            }
          }
        }
      ]
    },
    "payments": [],
    "payouts": []
  },
  {
    "index": 3,
    "transactionId": "608e38912f237a7ac47432f5b5a119b20fa86e1b77033ed589aa6fb4bf42400d",
    "block": {
      "blockHeaderHash": "5eb8f1c0cf002f27fd768ccda9731a949694be725ef6b80b75248336f7e47c01",
      "blockNo": 5268149,
      "slotNo": 135775560
    },
    "consumingTx": "c3e5562dde79ee61de00165bf3daa8d1afb7fc0b96150001579d0b1776312a2c",
    "status": "confirmed",
    "invalidBefore": "2026-10-08T11:25:09Z",
    "invalidHereafter": "2026-10-08T17:24:45Z",
    "inputs": [
      {
        "continuation_hash": "67c7447effec4129bee5278594d2802579da4669f91b016b7936493d54f8e2cb",
        "input_from_party": {
          "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
        },
        "into_account": {
          "address": "addr_test1vz97dydaewdgvwasux3t2fnjr6vla6ag5kgxdhwydtwpp3cjem4u5"
        },
        "merkleized_continuation": {
          "timeout": 1791480285778,
          "timeout_continuation": "close",
          "when": [
            {
              "case": {
                "deposits": 5050000,
                "into_account": {
                  "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
                },
                "of_token": {
                  "currency_symbol": "",
                  "token_name": ""
                },
                "party": {
                  "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
                }
              },
              "merkleized_then": "7e67f52c12df296be5db094da9f2e876560af7160784abddc4195fe86ad3b272"
            }
          ]
        },
        "of_token": {
          "currency_symbol": "",
          "token_name": ""
        },
        "that_deposits": 5050000
      }
    ],
    "interval": {
      "from": 1791458709000,
      "to": 1791480284999
    },
    "outputContract": {
      "timeout": 1791480285778,
      "timeout_continuation": "close",
      "when": [
        {
          "case": {
            "deposits": 5050000,
            "into_account": {
              "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
            },
            "of_token": {
              "currency_symbol": "",
              "token_name": ""
            },
            "party": {
              "address": "addr_test1vqn9sl3emuswdl9063ykdxja0fjcdnr3fdkw0xjsd3ue99qu2cg89"
            }
          },
          "merkleized_then": "7e67f52c12df296be5db094da9f2e876560af7160784abddc4195fe86ad3b272"
        }
      ]
    },
    "payments": [],
    "payouts": []
  }
]
```
