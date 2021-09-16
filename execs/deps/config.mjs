import fcl from "@onflow/fcl";

import env from "dotenv";
import expandEnv from "dotenv-expand";

const config = env.config({
  path: ".env"
});
expandEnv(config);
const envVars = config.parsed;

fcl.config()
  .put("grpc.metadata", {"api_key": envVars.FLOW_ALCHEMY_API_KEY})
  .put("accessNode.api", envVars.FLOW_ACCESS_NODE) // Configure FCL's Alchemy Access Node
  .put("decoder.Type", val => val.staticType)

export default envVars
