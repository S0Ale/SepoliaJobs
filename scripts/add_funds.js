import { network } from "hardhat";

const { ethers, networkName } = await network.create();

const accounts = await ethers.provider.send("eth_accounts");

const tenEth = "0x8AC7230489E80000"; // 10 ETH in wei

for (const account of accounts) {
    await ethers.provider.send("hardhat_setBalance", [
        account,
        tenEth,
    ]);

    console.log(`Funded ${account} with 10 ETH`);
}
