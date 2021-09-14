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

  /// PoolViewer
  ///
  pub resource interface PoolViewer {
    // query all lottery ids
    // 
    pub fun lotteryIDs(_ page: UInt64?): [String]

    // query last winners' lottery ids
    // 
    pub fun winnerIDs(_ label: String?, _ batch: UInt32?): [String]
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
  pub resource EntityPool: PoolViewer, PoolController, LotteryDrawer {
    access(contract) let idsInPool: [String]
    access(contract) let winners: {String: WinnerRecord}

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

    pub fun winnerIDs(_ label: String?, _ batch: UInt32?): [String] {
      // TODO
      return []
    }
  }

  // The init() function is required if the contract contains any fields.
  init() {
      // self.greeting = "Hello, World!"
  }
}