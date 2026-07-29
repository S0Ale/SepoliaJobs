# SepoliaJobs
To install the required dependencies, use `npm install`.

> [!WARNING]
> If **npm** errors out with the `EALLOWGIT` error use `npm config set allow-git "all"` to allow the installation of dependecies from git repositories 

## Testing
Use `npx hardhat test solidity` to execute the contract's unit tests.

## Contract deployment
First start the local blockchain environment using `npx hardhat node`.

### Local node
Using `scripts/deploy.js` script in the **localhost** network with the command:
```bash
npx hardhat run scripts/deploy.js --build-profile production --network localhost
```

### Sepolia
TODO