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

  /// PoolViewer
  ///
  pub resource interface PoolViewer {
    // query all lottery ids
    // 
    pub fun lotteryIDs(_ page: UInt64?): [String]

    // query last winners' lottery ids
    // 
    pub fun winnerIDs(_ label: String, _ batch: Int?): [String]
  }

  /// PoolController
  ///
  pub resource interface PoolController {
    // add lottery ids
    // 
    access(account) fun addLotteryIDs(keys: [String])
    // clear all lottery ids
    // 
    access(account) fun clearLotteryIDs()
  }

  /// LotteryDrawer
  ///
  pub resource interface LotteryDrawer {
    // do a draw with a label
    // 
    access(account) fun draw(label: String)
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
    init(batch: UInt32, ids: [String]) {
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
    access(account) fun addLotteryIDs(keys: [String]) {
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
    access(account) fun clearLotteryIDs() {
      while self.idsInPool.length > 0 {
        self.idsInPool.removeLast()
      }

      // emit event
      emit LotteryIDsCleared()
    }

    // do a draw
    // 
    access(account) fun draw(label: String) {
      // var winnerRecords: [WinnerRecord]
      // TODO
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

    pub fun winnerIDs(_ label: String, _ batch: Int?): [String] {
      pre {
        self.winners[label] != nil : "missing winner label"
        batch == nil || self.winners[label] != nil : "batch is not found in label"
      }

      let batchNum = batch ?? 0
      let record = self.winners[label]!

      assert(batchNum < record.length && batchNum >= 0, message: "Winner record does not have specified ID")

      return record[batchNum].ids
    }
  }

  // The init() function is required if the contract contains any fields.
  init() {
    // Set our named paths.
    self.LotteryStoragePath = /storage/LotteryBox
    self.LotteryPrivatePath = /private/LotteryBox

    let lottery <- create LotteryBox()
    self.account.save(<-lottery, to: self.LotteryStoragePath)

    // Emit event
    emit ContractInitialized()
  }
}