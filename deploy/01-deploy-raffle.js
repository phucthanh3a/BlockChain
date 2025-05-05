// const { ethers } = require("hardhat");
const ENTRANCE_FEE = ethers.utils.parseEther("0.1");

module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()

    const args = [ENTRANCE_FEE, "300", "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625", "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c", "18030452121057988787878409022796833613933984162594994830725170592281025309960", "500000",
    ]
    const raffle = await deploy("Raffle", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: 6,
    })
}