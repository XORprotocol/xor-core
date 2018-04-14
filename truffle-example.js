var HDWalletProvider = require("truffle-hdwallet-provider");
var mnemonic = "";

module.exports = {
    networks: {
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 6612388
        },
        ropsten: {
            provider: function() {
                return new HDWalletProvider(mnemonic, "https://ropsten.infura.io")
            },
            network_id: 3,
            gas: 4690000
        }
    }
};

