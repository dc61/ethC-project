pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./SafeMath.sol";

contract InflationToken is IERC20 {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    uint256 private constant INITIAL_SUPPLY = 0;
    uint256 private constant INFLATION_PERCENT = 2;
    uint256 private constant INFLATION_START_BLOCK = 100000000;
    uint256 private constant BLOCKS_PER_YEAR = 2102400;

    constructor() {
        name = "Inflation Token";
        symbol = "INF";
        decimals = 18;
        totalSupply = INITIAL_SUPPLY;
    }

    function mintTokens() private {
        uint256 inflationAmount = 0;
        uint256 currentBlock = block.number;

        if (currentBlock < INFLATION_START_BLOCK) {
            inflationAmount = 10833330000000000000; // 10.83333 tokens * 10^18
        } else {
            uint256 blocksSinceStart = currentBlock.sub(INFLATION_START_BLOCK);
            uint256 yearsSinceStart = blocksSinceStart.div(BLOCKS_PER_YEAR);
            uint256 inflationFactor = yearsSinceStart.mul(INFLATION_PERCENT).add(100);

            inflationAmount = totalSupply.mul(inflationFactor).div(100).sub(totalSupply);
        }

        totalSupply = totalSupply.add(inflationAmount);
        balances[msg.sender] = balances[msg.sender].add(inflationAmount);
        emit Transfer(address(0), msg.sender, inflationAmount);
    }

    function mintTokensForBlock(uint256 blockNumber) public {
        require(blockNumber <= block.number, "Invalid block number");

        address[] memory addresses = getAddressesFromBlock(blockNumber);
        for (uint256 i = 0; i < addresses.length; i++) {
            address recipient = addresses[i];
            uint256 amount = getInflationAmountForBlock(blockNumber, recipient);
            balances[recipient] = balances[recipient].add(amount);
            emit Transfer(address(0), recipient, amount);
        }
    }

    function getAddressesFromBlock(uint256 blockNumber) private view returns (address[] memory) {
        uint256 size;
        assembly {
            size := extcodesize(blockNumber)
        }

        address[] memory addresses = new address[](size);
        for (uint256 i = 0; i < size; i++) {
            addresses[i] = address(i);
        }

        return addresses;
    }

    function getInflationAmountForBlock(uint256 blockNumber, address recipient) private view returns (uint256) {
        if (blockNumber < INFLATION_START_BLOCK) {
            return 0;
        } else {
            uint256 blocksSinceStart = blockNumber.sub(INFLATION_START_BLOCK);
            uint256 yearsSinceStart = blocksSinceStart.div(BLOCKS_PER_YEAR);
            uint256 inflationFactor = yearsSinceStart.mul(INFLATION_PERCENT).add(100);
            uint256 recipientBalance = balances[recipient];

            return recipientBalance.mul(inflationFactor).div(100).sub(recipientBalance);
        }
    }

    function balanceOf(address account) external view override returns (uint256) {
        return balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        require(amount <= balances[msg.sender], "Insufficient balance");
        require(recipient != address(0), "Invalid recipient");

        balances[msg.sender] = balances[msg.sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        require(amount <= balances[sender], "Insufficient balance");
        require(amount <= allowances[sender][msg.sender], "Insufficient allowance");
        require(recipient != address(0), "Invalid recipient");

        balances[sender] = balances[sender].sub(amount);
        balances[recipient] = balances[recipient].add(amount);
        allowances[sender][msg.sender] = allowances[sender][msg.sender].sub(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return allowances[owner][spender];
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
