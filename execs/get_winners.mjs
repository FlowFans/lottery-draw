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
  const script = fs
    .readFileSync(
      path.join(
        process.cwd(),
        'cadence/scripts/get_winners.cdc'
      ),
      "utf8"
    )
    .replace(contractPath, fcl.withPrefix(flowService.minterFlowAddress))
  await flowService.executeScript({
    script,
    args: [
      fcl.arg(flowService.minterFlowAddress, t.Address),
      fcl.arg('winner', t.String),
      fcl.arg(0, t.UInt)
    ]
  })
}

run()
