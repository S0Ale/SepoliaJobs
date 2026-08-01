import { network } from "hardhat";

const { ethers, networkName } = await network.create();

const addr = process.env.ADDR;
const eth = ethers.parseEther("5");

const sender = (await ethers.getSigners())[1];

const tx = await sender.sendTransaction({
    to: addr,
    value: eth,
});
await tx.wait();

await ethers.provider.send("hardhat_setBalance", [
    sender.address,
    ethers.toBeHex(eth * 2n),
]);
