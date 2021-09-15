import LotteryPool from "../contracts/LotteryPool.cdc"

transaction(ids: [String]) {
    let lotteryBox: &LotteryPool.LotteryBox{LotteryPool.PoolController}

    prepare(signer: AuthAccount) {
        self.lotteryBox = signer
            .getCapability(LotteryPool.LotteryPrivatePath)
            .borrow<&LotteryPool.LotteryBox{LotteryPool.PoolController}>()
            ?? panic("Signer is not the admin")
    }

    execute {
        self.lotteryBox.addLotteryIDs(keys: ids)
    }
}
