pragma solidity ^0.4.24;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {

    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}


contract Switchable is Ownable {

    event On();
    event Off();

    bool public off = false;


    /**
     * @dev Modifier to make a function callable only when the contract is not paused.
     */
    modifier whenOff() {
        require(!off);
        _;
    }

    /**
     * @dev Modifier to make a function callable only when the contract is paused.
     */
    modifier whenOn() {
        require(off);
        _;
    }

    /**
     * @dev called by the owner to on, triggers opened state
     */
    function on() onlyOwner whenOff public {
        off = true;
        emit On();
    }

    /**
     * @dev called by the owner to off, returns to off state
     */
    function off() onlyOwner whenOn public {
        off = false;
        emit Off();
    }
}

contract Erc20Token {
    function balanceOf(address _owner) constant public returns (uint256);

    function transfer(address _to, uint256 _value) public returns (bool);
}

contract AirDropContract is Switchable {

    using SafeMath for uint256;

    Erc20Token public tokenRewardContract;

    uint256 public totalAirDropToken;

    address public collectorAddress;

    mapping(address => uint256) public balanceOf;

    event FundTransfer(address backer, uint256 amount, bool isContribution);
    event Additional(uint amount);

    /**
     * Constructor function
     */
    constructor(
        address _tokenRewardContract,
        address _collectorAddress
    ) public {
        totalAirDropToken = 1e7;
        tokenRewardContract = Erc20Token(_tokenRewardContract);
        collectorAddress = _collectorAddress;
    }

    /**
     * Fallback function
     *
     * The function without name is the default function that is called whenever anyone sends funds to a contract
     */
    function() payable public {
        require(totalAirDropToken > 0);
        require(balanceOf[msg.sender] == 0);
        uint256 amount = getCurrentCandyAmount();
        require(amount > 0);

        totalAirDropToken = totalAirDropToken.sub(amount);
        balanceOf[msg.sender] = amount;

        tokenRewardContract.transfer(msg.sender, amount * 1e18);
        emit FundTransfer(msg.sender, amount, true);
    }

    function getCurrentCandyAmount() private view returns (uint256 amount){
        if (!off) {
            if (totalAirDropToken >= 200) {
                return 200;
            } else {
                return 0;
            }
        } else {
            if (totalAirDropToken >= 7.5e6) {
                return 200;
            } else if (totalAirDropToken >= 5e6) {
                return 150;
            } else if (totalAirDropToken >= 2.5e6) {
                return 100;
            } else if (totalAirDropToken >= 500) {
                return 50;
            } else {
                return 0;
            }
        }
    }

    /**
     *  Add airdrop tokens
     */
    function additional(uint256 amount) public onlyOwner {
        require(amount > 0);

        totalAirDropToken = totalAirDropToken.add(amount);
        emit Additional(amount);
    }

    /**
     *  The owner of the contract modifies the recovery address of the token
     */
    function modifyCollectorAddress(address newCollectorAddress) public onlyOwner returns (bool) {
        collectorAddress = newCollectorAddress;
    }

    /**
     *  Recovery of remaining tokens
     */
    function collectAirDropTokenBack() public onlyOwner {
        require(totalAirDropToken > 0);
        require(collectorAddress != 0x0);

        tokenRewardContract.transfer(collectorAddress, totalAirDropToken * 1e18);
        totalAirDropToken = 0;
    }


    /**
     *  Recovery donated ether
     */
    function collectEtherBack() public onlyOwner {
        uint256 b = address(this).balance;
        require(b > 0);
        require(collectorAddress != 0x0);

        collectorAddress.transfer(b);
    }


    /**
     *  Get the tokenAddress token balance of someone
     */
    function getTokenBalance(address tokenAddress, address who) view public returns (uint){
        Erc20Token t = Erc20Token(tokenAddress);
        return t.balanceOf(who);
    }


    /**
     *  Recycle other ERC20 tokens
     */
    function collectOtherTokens(address tokenContract) onlyOwner public returns (bool) {
        Erc20Token t = Erc20Token(tokenContract);

        uint256 b = t.balanceOf(address(this));
        return t.transfer(collectorAddress, b);
    }

}