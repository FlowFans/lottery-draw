import fcl from "@onflow/fcl";
import {send as grpcSend} from "@onflow/transport-grpc"

import env from "dotenv";
import expandEnv from "dotenv-expand";

const config = env.config({
  path: ".env"
});
expandEnv(config);
const envVars = config.parsed;

fcl.config()
  .put('flow.network', 'testnet')
  .put('fcl.limit', 9999)
  .put("grpc.metadata", {"api_key": envVars.FLOW_ALCHEMY_API_KEY})
  .put("accessNode.api", envVars.FLOW_ACCESS_NODE)
  .put("sdk.transport", grpcSend)

export default envVars
