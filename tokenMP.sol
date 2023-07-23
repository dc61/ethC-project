pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token is ERC20, Ownable {
    uint256 public constant INCREASE_AMOUNT_PER_CYCLE = 1000000; // 1 million blocks
    uint256 public constant INCREASE_AMOUNT = 1000; // 0.10% in basis points (0.10 * 10**4)
    uint256 public constant MAX_INCREASE_CYCLES = 30;

    uint256 public lastIncreaseBlock;
    uint256 public currentIncreaseCycle;

    constructor() ERC20("Token", "TOK") {
        lastIncreaseBlock = block.number;
        _mint(owner(), 0); // Mint 0 tokens initially
    }

    function _calculateSupplyIncrease() internal view returns (uint256) {
        if (currentIncreaseCycle >= MAX_INCREASE_CYCLES) {
            return 0;
        }

        uint256 blocksSinceLastIncrease = block.number - lastIncreaseBlock;
        uint256 cycles = blocksSinceLastIncrease / INCREASE_AMOUNT_PER_CYCLE;

        uint256 increaseAmount = cycles * INCREASE_AMOUNT;
        return (totalSupply() * increaseAmount) / 10000; // Convert basis points to decimals
    }

    function increaseSupply() external onlyOwner {
        uint256 supplyIncrease = _calculateSupplyIncrease();
        if (supplyIncrease > 0) {
            _mint(owner(), supplyIncrease);
            currentIncreaseCycle++;
            lastIncreaseBlock = block.number;
        }
    }
}
