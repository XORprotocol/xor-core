// NOTE: Upgrading to solidity-coverage 0.4.x breaks our tests

const libFiles = require('glob').sync('contracts/lib/**/*.sol').map(n => n.replace('contracts/', ''))
const interfaces = []

module.exports = {
    norpc: true,
    compileCommand: '../node_modules/.bin/truffle compile',
    testCommand: 'node --max-old-space-size=8192 ../node_modules/.bin/truffle test --network coverage',
    skipFiles: interfaces.concat(libFiles),
    copyPackages: ['zeppelin-solidity', 'xor-libraries', 'xor-external-contract-examples'],
}