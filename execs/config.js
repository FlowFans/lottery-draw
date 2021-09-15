// File: ./execs/config.js
import * as fcl from "@onflow/fcl"

fcl.config()
  .put("grpc.metadata", {"api_key": process.env.FLOW_ALCHEMY_API_KEY})
  .put("accessNode.api", process.env.FLOW_ACCESS_NODE) // Configure FCL's Alchemy Access Node
  .put("challenge.handshake", process.env.FLOW_WALLET_DISCOVERY) // Configure FCL's Wallet Discovery mechanism
  .put("0xProfile", process.env.FLOW_ADDRESS) // Will let us use `0xProfile` in our Cadence