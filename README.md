# W3CXII Smart Contract

A Solidity smart contract that implements a deposit and withdrawal system with a special "dosed" state that triggers when the contract balance reaches or exceeds 20 ETH.

## Features

- Deposit functionality with balance tracking
- Withdrawal functionality with balance verification
- Special "dosed" state that triggers at 20 ETH balance
- Emergency withdrawal function for the owner
- Direct ether transfer support (owner only)
- Comprehensive test coverage

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Node.js](https://nodejs.org/) (for development tools)

## Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd w3cxii
```

2. Install dependencies:
```bash
forge install
```

## Testing

Run the test suite:
```bash
forge test
```

For verbose output:
```bash
forge test -vv
```

## Deployment

1. Create a `.env` file in the root directory with your private key:
```
PRIVATE_KEY=your_private_key_here
```

2. Deploy to a network:
```bash
# For local network
forge script script/Deploy.s.sol --rpc-url http://localhost:8545 --broadcast

# For testnet (e.g., Sepolia)
forge script script/Deploy.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify

# For mainnet
forge script script/Deploy.s.sol --rpc-url $MAINNET_RPC_URL --broadcast --verify
```

## Contract Functions

### Core Functions

- `deposit()`: Allows users to deposit ETH into the contract
- `withdraw()`: Allows users to withdraw their deposited ETH
- `dest()`: Emergency function to withdraw all contract balance to owner
- `receive()`: Allows direct ETH transfers (owner only)

### State Variables

- `owner`: Contract owner address
- `dosed`: Boolean indicating if contract is in dosed state
- `balances`: Mapping of user addresses to their deposit amounts

## Security Features

- Owner-only emergency withdrawal
- Balance verification before withdrawals
- Dosed state protection
- Direct transfer restrictions

## License

MIT

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Acknowledgments

- [Foundry](https://book.getfoundry.sh/)
- [OpenZeppelin](https://openzeppelin.com/)
