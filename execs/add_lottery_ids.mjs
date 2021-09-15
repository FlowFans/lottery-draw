import fs from 'fs'
import path from 'path'
import env from "dotenv"
import expandEnv from "dotenv-expand"
import fcl from "@onflow/fcl"
import t from "@onflow/types"

import FlowService from './flow.mjs'

const config = env.config({
  path: ".env"
});
expandEnv(config);
const envVars = config.parsed;

fcl.config()
  .put("grpc.metadata", {"api_key": envVars.FLOW_ALCHEMY_API_KEY})
  .put("accessNode.api", envVars.FLOW_ACCESS_NODE) // Configure FCL's Alchemy Access Node
  .put("decoder.Type", val => val.staticType)

async function sendTx ({
  transaction,
  args,
  proposer,
  authorizations,
  payer,
}) {
  const response = await fcl.send([
    fcl.transaction`
      ${transaction}
    `,
    fcl.args(args),
    fcl.proposer(proposer),
    fcl.authorizations(authorizations),
    fcl.payer(payer),
    fcl.limit(9999),
  ]);
  return await fcl.tx(response).onceSealed();
}

const flowService = new FlowService(
  envVars.FLOW_ADDRESS,
  envVars.FLOW_PRIVATE_KEY,
  0
)

async function run() {
  const transaction = fs
    .readFileSync(
      path.join(
        process.cwd(),
        'cadence/transactions/lottery_ids_add.cdc'
      ),
      "utf8"
    )
  const authorization = flowService.authorizeMinter()
  await sendTx({
    transaction,
    args: [
      fcl.arg(['test'], t.Array(t.String)),
    ],
    proposer: authorization,
    authorizations: [authorization],
    payer: authorization
  })
}

run()
