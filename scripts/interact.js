async function addJobs(ethers, contract){
	const [deployer] = await ethers.getSigners();
	const now = Math.floor(Date.now() / 1000);

	const jobsToCreate = [
		{ title: "Frontend Dev", description: "Build a landing page in React", deadline: now + 7 * 86400, payment: "0.1" },
		{ title: "Smart Contract Tester", description: "Write Hardhat tests", deadline: now + 14 * 86400, payment: "0.2" },
		{ title: "Logo Design", description: "Design a company logo", deadline: now + 3 * 86400, payment: "0.05" },
	];

	for (const job of jobsToCreate) {
		const tx = await contract.connect(deployer).createJob(
			job.title,
			job.description,
			BigInt(job.deadline),
			{ value: ethers.parseEther(job.payment) }
		);
		await tx.wait();
		console.log(`Created job: ${job.title}`);
	}
}

export { addJobs }
