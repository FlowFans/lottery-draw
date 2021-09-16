import LotteryPool from "../contracts/LotteryPool.cdc"

pub fun main(address: Address, page: UInt64): [String] {
  let account = getAccount(address)

  let ref = account.getCapability(LotteryPool.LotteryPublicPath)!.borrow<&LotteryPool.LotteryBox{LotteryPool.PoolViewer}>()
    ?? panic("Could not borrow lottery box reference")

  return ref.lotteryIDs(page)
}
 