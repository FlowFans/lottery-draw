// LotteryPool.cdc
//
// Welcome to Cadence! 

pub contract LotteryPool {
  // ContractInitialized
  // 
  // The event that is emitted when the contract is created
  pub event ContractInitialized()
  
  // LotteryIDsAdded
  //
  // The event that is emitted when lottery ids are added to the pool
  pub event LotteryIDsAdded(_ keys: [String])

  // LotteryIDsCleared
  //
  // The event that is emitted when lottery ids are cleared
  pub event LotteryIDsCleared()

  // LotteryDraw
  // 
  // The event that is emitted when lottery drawn
  pub event LotteryDrawn(label: String, batch: UInt32, keys:[String])

  // Named paths
  //
  pub let LotteryStoragePath: StoragePath
  pub let LotteryPrivatePath: PrivatePath
  pub let LotteryPublicPath: PublicPath

  /// PoolViewer
  ///
  pub resource interface PoolViewer {
    // query all lottery ids
    // 
    pub fun lotteryIDs(_ page: UInt64?): [String]

    // query last winners' lottery ids
    // 
    pub fun winnerIDs(_ label: String, _ batch: UInt?): [String]
  }

  /// PoolController
  ///
  pub resource interface PoolController {
    // add lottery ids
    // 
    pub fun addLotteryIDs(keys: [String])
    // clear all lottery ids
    // 
    pub fun clearLotteryIDs()
  }

  /// LotteryDrawer
  ///
  pub resource interface LotteryDrawer {
    // do a draw with a label
    // 
    pub fun draw(label: String, amount: UInt)
  }

  // WinnerRecord
  // A struct representing a winner record
  //
  pub struct WinnerRecord {
    // record batch
    pub let batch: UInt32
    // record winners' ids
    pub let ids: [String]

    // initializer
    //
    init(_ batch: UInt32, _ ids: [String]) {
        self.batch = batch
        self.ids = ids
    }
  }

  // Resources for Lottery Pool
  pub resource LotteryBox: PoolViewer, PoolController, LotteryDrawer {
    access(contract) let idsInPool: [String]
    access(contract) let winners: {String: [WinnerRecord]}

    // initialize the balance at resource creation time
    init() {
      self.idsInPool = []
      self.winners = {}
    }

    // add lottery ids
    // 
    pub fun addLotteryIDs(keys: [String]) {
      pre {
        keys.length > 0: "keys length should be not zero"
      }

      for key in keys {
        if !self.idsInPool.contains(key) {
          self.idsInPool.append(key)
        }
      }

      // emit event
      emit LotteryIDsAdded(keys)
    }

    // clear all lottery ids
    // 
    pub fun clearLotteryIDs() {
      while self.idsInPool.length > 0 {
        self.idsInPool.removeLast()
      }

      // emit event
      emit LotteryIDsCleared()
    }

    // do a draw
    // 
    pub fun draw(label: String, amount: UInt) {
      var winnerRecords: [WinnerRecord]? = self.winners[label]

      // force setup
      if winnerRecords == nil {
        winnerRecords = []
      }
      
      // genereate a random number
      let blockHash = getCurrentBlock().id
      let blockHashLen = UInt(blockHash.length)

      fun pow (_ x: UInt, _ y: UInt): UInt64 {
        if y == 0 {
          return UInt64(x)
        }
        return UInt64(x) * pow(x, y - 1)
      }

      fun geneRandNumber (): UInt64 {
        var randInt = unsafeRandom()
        var i: UInt = 0
        while i < 8 {
          let currNum = blockHash[blockHashLen - i - 1]
          randInt = randInt + pow(10, 8 as UInt - i) * UInt64(currNum)
        }
        return randInt
      }

      let totalLength = UInt64(self.idsInPool.length)

      let ids: [String] = []
      var cnt: UInt = 0
      while cnt < amount {
        let rand = geneRandNumber()
        let picked = rand % totalLength
        let pickedId = self.idsInPool[picked]
        if !ids.contains(pickedId) {
          ids.append(pickedId)
          cnt = cnt + 1
        }
      }

      let batch = UInt32(winnerRecords?.length! + 1)
      let newRecord = WinnerRecord(batch, ids)

      self.winners[label] = winnerRecords

      emit LotteryDrawn(label: label, batch: batch, keys: ids)
    }

    pub fun lotteryIDs(_ page: UInt64?): [String] {
      let startPage: UInt64 = page ?? (0 as UInt64)

      let idSlice: [String] = []
      let len = UInt64(self.idsInPool.length)
      let size = 20 as UInt64
      var i = 0 as UInt64
      while i < size {
        let curr = i + startPage * size
        if curr >= len {
          break
        }
        idSlice.append(self.idsInPool[curr])
        i = i + 1
      }
      return idSlice
    }

    pub fun winnerIDs(_ label: String, _ batch: UInt?): [String] {
      pre {
        self.winners[label] != nil : "missing winner label"
        batch == nil || self.winners[label] != nil : "batch is not found in label"
      }

      let batchNum: UInt = batch ?? 0 as UInt
      let record = self.winners[label]!

      assert(batchNum < UInt(record.length) && batchNum >= 0, message: "Winner record does not have specified ID")

      return record[batchNum].ids
    }
  }

  // The init() function is required if the contract contains any fields.
  init() {
    // Set our named paths.
    self.LotteryStoragePath = /storage/LotteryBox1
    self.LotteryPrivatePath = /private/LotteryBox1
    self.LotteryPublicPath = /public/LotteryBox1

    let lottery <- create LotteryBox()
    self.account.save(<-lottery, to: self.LotteryStoragePath)

    self.account.link<&LotteryBox{PoolController, LotteryDrawer}>(
      self.LotteryPrivatePath,
      target: self.LotteryStoragePath
    )
    self.account.link<&LotteryBox{PoolViewer}>(
      self.LotteryPublicPath,
      target: self.LotteryStoragePath
    )

    // Emit event
    emit ContractInitialized()
  }
}