import LotteryPool from "../contracts/LotteryPool.cdc"

transaction(label: String, amount: UInt) {
    let lotteryBox: &LotteryPool.LotteryBox{LotteryPool.LotteryDrawer}

    prepare(signer: AuthAccount) {
        self.lotteryBox = signer
            .getCapability(LotteryPool.LotteryPrivatePath)
            .borrow<&LotteryPool.LotteryBox{LotteryPool.LotteryDrawer}>()
            ?? panic("Signer is not the admin")
    }

    execute {
        self.lotteryBox.draw(label: label, amount: amount)
    }
}
 