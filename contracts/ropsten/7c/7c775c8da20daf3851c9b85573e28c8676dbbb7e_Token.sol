pragma solidity ^0.5.1;

contract Token{
    
    // ERC20 Token, with the addition of symbol, name and decimals and a
    // fixed supply
    
    string public constant symbol = &#39;ZAR-TIG&#39;;
    string public constant name = &#39;ZAR Tigereum&#39;;
    uint8 public constant decimals = 2;
    uint public constant _totalSupply = 100000000 * 10**uint(decimals);
    address public owner;
    string public website;
    
    // Balances for each account
    mapping(address => uint256) balances;
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping(address => uint256)) allowed;
    
    constructor() public {
        balances[msg.sender] = _totalSupply;
        owner = msg.sender;
        website = "http://tigereum.io";
    }
    
    function totalSupply() public pure returns (uint) {
        return _totalSupply;
    }
    
    // Get the token balance for account { tokenOwner }
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }
    
    // Transfer the balance from owner&#39;s account to another account
    function transfer(address to, uint tokens) public returns (bool success) {
        require( balances[msg.sender] >= tokens && tokens > 0 && tokens < 1e60);
        balances[msg.sender] -= tokens;
        balances[to] += tokens;
        emit Sent(msg.sender, to, tokens);
        return true;
    }
    
    // Send {tokens} amount of tokens from address {from} to address {to}
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        require( allowed[from][msg.sender] >= tokens && balances[from] >= tokens && tokens > 0 && tokens < 1e60 );
        balances[from] -= tokens;
        allowed[from][msg.sender] -= tokens;
        balances[to] += tokens;
        emit Sent(from, to, tokens);
        return true;
    }
    
    // Allow {spender} to withdraw from your account, multiple times, up to the {tokens} amount.
    function approve(address sender, uint256 tokens) public returns (bool success) {
        allowed[msg.sender][sender] = tokens;
        emit Approval(msg.sender, sender, tokens);
        return true;
    }
    
    // Returns the amount of tokens approved by the owner that can be
    // transferred to the spender&#39;s account
    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }
    
    
    event Sent(address _from, address _to, uint256 _amount);
    event Approval(address _owner, address _to, uint256 _amount);
}