import { network } from "hardhat";
import { addJobs } from "./interact.js"

const { ethers, networkName } = await network.create();

console.log(`Deploying FreelancePlatform to ${networkName}...`);

const c = await ethers.deployContract("FreelancePlatform");

console.log("Waiting for the deployment tx to confirm");
await c.waitForDeployment();

console.log("Contract address:", await c.getAddress());
console.log("Deployment successful!");

await addJobs(ethers, c)
