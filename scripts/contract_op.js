import { abi } from "../artifacts/contracts/FreelancePlatform.sol/FreelancePlatform.json"
import config from "../contract-address.json" with { type: "json" }
import { network } from "hardhat";

const { ethers, networkName } = await network.create();

const operation = process.env.OP;

const sender = (await ethers.getSigners())[0];
const write_contract = new ethers.Contract(config.address, abi, sender);

const tx = await (async () => {
    const job = process.env.ID;

    switch (operation) {
        case "Apply":
            return await write_contract.applyToJob(job);
        case "ApproveFreelancer":
            const addr = process.env.ADDR;
            return await write_contract.approveFreelancer(job, addr);
        case "Submit":
            return await write_contract.submitWork(job);
        case "ApprovePayment":
            return await write_contract.approvePayment(job);
    }
})();
const receipt = await tx.wait();

// console.log(receipt)
console.log(`Operation ${operation} completed`);
