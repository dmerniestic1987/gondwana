const HDWalletProvider = require("truffle-hdwallet-provider");
const infuraKey = "a973f72655dc4760bfc81012fec47c86";
const mnemonic =
  "fantasy when hunt absent tide false kiwi combine strike brain setup anxiety";
module.exports = {
  compilers: {
    solc: {
      version: "0.5.10",
      settings: {
        optimizer: {
          enabled: true,
          runs: 1
        }
      }
    }
  },
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   * 
   * ID de las redes: 
   * 0: Olympic, Ethereum public pre-release testnet
    1: Frontier, Homestead, Metropolis, the Ethereum public main network
    1: Classic, the (un)forked public Ethereum Classic main network, chain ID 61
    1: Expanse, an alternative Ethereum implementation, chain ID 2
    2: Morden, the public Ethereum testnet, now Ethereum Classic testnet
    3: Ropsten, the public cross-client Ethereum testnet
    4: Rinkeby, the public Geth PoA testnet
    8: Ubiq, the public Gubiq main network with flux difficulty chain ID 8
    42: Kovan, the public Parity PoA testnet
    77: Sokol, the public POA Network testnet
    99: Core, the public POA Network main network
    100: xDai, the public MakerDAO/POA Network main network
    401697: Tobalaba, the public Energy Web Foundation testnet
    7762959: Musicoin, the music blockchain
    61717561: Aquachain, ASIC resistant chain
   */

  networks: {
    development: {
      host: "127.0.0.1", // Localhost (default: none)
      port: 8545, // Standard Ethereum port (default: none)
      network_id: "*" // Any network (default: none)
    },
    kovan: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          "https://kovan.infura.io/${infuraKey}",
          0
        ),
      network_id: 42, // kovan's id
      gas: 5500000, // kovan has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true // Skip dry run before migrations? (default: false for public nets )
    },
    ropsten: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          "https://ropsten.infura.io/${infuraKey}",
          0
        ),
      network_id: 3, // Ropsten's id
      gas: 5500000, // Ropsten has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true // Skip dry run before migrations? (default: false for public nets )
    },
    rinkeby: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          "https://rinkeby.infura.io/${infuraKey}",
          0
        ),
      network_id: 4, // rinkeby's id
      gas: 5500000, // rinkeby has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true // Skip dry run before migrations? (default: false for public nets )
    },
    poaSokolTestnet: {
      provider: function() {
        return new HDWalletProvider(mnemonic, "https://sokol.poa.network");
      },
      network_id: 77,
      gas: 500000,
      gasPrice: 1000000000
    },
    mainnet: {
      provider: () =>
        new HDWalletProvider(
          mnemonic,
          "https://mainnet.infura.io/${infuraKey}",
          0
        ),
      network_id: 1, // rinkeby's id
      gas: 5500000, // rinkeby has a lower block limit than mainnet
      confirmations: 2, // # of confs to wait between deployments. (default: 0)
      timeoutBlocks: 200, // # of blocks before a deployment times out  (minimum/default: 50)
      skipDryRun: true // Skip dry run before migrations? (default: false for public nets )
    },
    rskTestnet: {
      network_id: 31,
      host: "http://50.116.28.95:4444",
      provider: new HDWalletProvider(mnemonic, "http://50.116.28.95:4444"),
      network_id: "*",
      gasPrice: 60000000
    }
  },
  mocha: {
    useColors: true
  }
};
