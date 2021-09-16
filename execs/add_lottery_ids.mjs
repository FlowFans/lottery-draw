import fs from 'fs'
import path from 'path'
import fcl from "@onflow/fcl"
import t from "@onflow/types"

import FlowService from './services/flow.mjs'
import config from './deps/config.mjs'

const flowService = new FlowService(
  config.FLOW_ADDRESS,
  config.FLOW_PRIVATE_KEY,
  0
)

const contractPath = '"../contracts/LotteryPool.cdc"';

async function run() {
  const transaction = fs
    .readFileSync(
      path.join(
        process.cwd(),
        'cadence/transactions/lottery_ids_add.cdc'
      ),
      "utf8"
    )
    .replace(contractPath, fcl.withPrefix(flowService.minterFlowAddress))
  
  const idsList = JSON.parse(fs.readFileSync(
    path.join(
      process.cwd(),
      config.DATA_ID_LIST_FILE
    ),
    "utf8"
  ))
  const authorization = flowService.authorizeMinter()

  const len = idsList.length
  const cap = 100
  let i = 0
  while (i * cap < len) {
    const from = i * cap
    const ids = idsList.slice(from, from + cap)
    // send tx
    await flowService.sendTx({
      transaction,
      args: [
        fcl.arg(ids, t.Array(t.String)),
      ],
      proposer: authorization,
      authorizations: [authorization],
      payer: authorization
    })
    i++
  } // end while
}

run()
