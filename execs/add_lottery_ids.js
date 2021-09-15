import "./config" // Imports environment variables and configures FCL

import * as fcl from "@onflow/fcl"

async function sendTx() {
  const transaction = fs
    .readFileSync(
      path.join(
        __dirname,
        `../cadence/transactions/lottery_ids_add.cdc`
      ),
      "utf8"
    )

  const txId = await fcl
    .send([
      fcl.proposer(fcl.currentUser().authorization), // current user acting as the nonce
      fcl.authorizations([fcl.currentUser().authorization]), // current user will be first AuthAccount
      fcl.payer(fcl.currentUser().authorization), // current user is responsible for paying for the transaction
      fcl.limit(1000), // set the compute limit
      fcl.transaction`
        ${transaction}
      `
    ])
    .then(fcl.decode)

  return fcl.tx(txId).onceSealed()
}

sendTx()
