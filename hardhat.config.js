require("hardhat-deploy");
require("dotenv").config();
require("@nomiclabs/hardhat-waffle");



/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.PRIVATE_KEY],
      chainId: 4,
      saveDeployments : true,
    },
  },
  namedAccounts:{ 
    deployer: {
      default: 0,
    },
  },
  solidity: "0.8.7",
};
// module.exports = {
//   defaultNetwork: "sepolia",
//   networks: {
//     hardhat: {},
//     sepolia: {
//       url: process.env.SEPOLIA_RPC_URL= "https://sepolia.infura.io/v3/5dcdbb0a8c98492591de24545659796d",
//       accounts: [process.env.PRIVATE_KEY = "d3f44e39c816782b8010ca902bb6115815f04f7bc55a04f5f2124b6fbf2d4015"],
//     }
//   },
//   solidity: {
//     version: "0.8.7",
//     settings: {
//       optimizer: {
//         enabled: true,
//         runs: 200
//       }
//     }
//   }
// };