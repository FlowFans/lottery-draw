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
        'cadence/transactions/do_lottery_draw.cdc'
      ),
      "utf8"
    )
    .replace(contractPath, fcl.withPrefix(flowService.minterFlowAddress))
  const authorization = flowService.authorizeMinter()
  await flowService.sendTx({
    transaction,
    args: [
      fcl.arg('test', t.String),
      fcl.arg(1, t.UInt)
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  })
}

run()
