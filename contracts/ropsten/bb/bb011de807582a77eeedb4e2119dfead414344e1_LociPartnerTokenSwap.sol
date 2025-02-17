pragma solidity >=0.4.23;

/**
 * @author Dan Emmons at Loci.io
 */  

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn&#39;t hold
    return c;
  }

  /**
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  uint256 totalSupply_;

  /**
  * @dev total number of tokens in existence
  */
  function totalSupply() public view returns (uint256) {
    return totalSupply_;
  }

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public view returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender&#39;s allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {
    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public view returns (uint256) {
    return allowed[_owner][_spender];
  }

  /**
   * @dev Increase the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _addedValue The amount of tokens to increase the allowance by.
   */
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  /**
   * @dev Decrease the amount of tokens that an owner allowed to a spender.
   *
   * approve should be called when allowed[_spender] == 0. To decrement
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   * @param _spender The address which will spend the funds.
   * @param _subtractedValue The amount of tokens to decrease the allowance by.
   */
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}

/**
 * @title Contactable token
 * @dev Basic version of a contactable contract, allowing the owner to provide a string with their
 * contact information.
 */
contract Contactable is Ownable {

  string public contactInformation;

  /**
    * @dev Allows the owner to set a string with their contact information.
    * @param info The contact information to attach to the contract.
    */
  function setContactInformation(string info) onlyOwner public {
    contactInformation = info;
  }
}

contract LOCIcredits is Ownable, Contactable {    
    using SafeMath for uint256;    

    StandardToken token; // LOCIcoin deployed contract
    mapping (address => bool) internal allowedOverrideAddresses;

    mapping (string => LOCIuser) users;    
    string[] userKeys;
    uint256 userCount;        

    // convenience for accounting
    event UserAdded( string id, uint256 time );

    // core usage: increaseCredits, reduceCredits, buyCreditsAndSpend, buyCreditsAndSpendAndRecover
    event CreditsAdjusted( string id, uint8 adjustment, uint256 value, uint8 reason, address register );    

    // special usage: transferCreditsInternally (only required in the event of a user that created multiple accounts)
    event CreditsTransferred( string id, uint256 value, uint8 reason, string beneficiary );

    modifier onlyOwnerOrOverride() {
        // owner or any addresses listed in the overrides
        // can perform token transfers while inactive
        require(msg.sender == owner || allowedOverrideAddresses[msg.sender]);
        _;
    }

    struct LOCIuser {        
        uint256 credits;
        bool registered;
        address wallet;
    }
    
    constructor( address _token, string _contactInformation ) public {
        owner = msg.sender;
        token = StandardToken(_token); // LOCIcoin address
        contactInformation = _contactInformation;        
    }    
    
    function increaseCredits( string _id, uint256 _value, uint8 _reason, address _register ) public onlyOwnerOrOverride returns(uint256) {
                
        LOCIuser storage user = users[_id];

        if( !user.registered ) {
            user.registered = true;
            userKeys.push(_id);
            userCount = userCount.add(1);
            emit UserAdded(_id,now);
        }

        user.credits = user.credits.add(_value);        
        require( token.transferFrom( _register, address(this), _value ) );
        emit CreditsAdjusted(_id, 1, _value, _reason, _register);
        return user.credits;
    }

    function reduceCredits( string _id, uint256 _value, uint8 _reason, address _register ) public onlyOwnerOrOverride returns(uint256) {
             
        LOCIuser storage user = users[_id];     
        require( user.registered );
        // SafeMath.sub will throw if there is not enough balance.
        user.credits = user.credits.sub(_value);        
        require( user.credits >= 0 );        
        require( token.transfer( _register, _value ) );           
        emit CreditsAdjusted(_id, 2, _value, _reason, _register);        
        
        return user.credits;
    }        

    function buyCreditsAndSpend( string _id, uint256 _value, uint8 _reason, address _register, uint256 _spend ) public onlyOwnerOrOverride returns(uint256) {
        increaseCredits(_id, _value, _reason, _register);
        return reduceCredits(_id, _spend, _reason, _register );        
    }        

    function buyCreditsAndSpendAndRecover(string _id, uint256 _value, uint8 _reason, address _register, uint256 _spend, address _recover ) public onlyOwnerOrOverride returns(uint256) {
        buyCreditsAndSpend(_id, _value, _reason, _register, _spend);
        return reduceCredits(_id, getCreditsFor(_id), _reason, _recover);
    }    

    function transferCreditsInternally( string _id, uint256 _value, uint8 _reason, string _beneficiary ) public onlyOwnerOrOverride returns(uint256) {        

        LOCIuser storage user = users[_id];   
        require( user.registered );

        LOCIuser storage beneficiary = users[_beneficiary];
        if( !beneficiary.registered ) {
            beneficiary.registered = true;
            userKeys.push(_beneficiary);
            userCount = userCount.add(1);
            emit UserAdded(_beneficiary,now);
        }

        require(_value <= user.credits);        
        user.credits = user.credits.sub(_value);
        require( user.credits >= 0 );
        
        beneficiary.credits = beneficiary.credits.add(_value);
        require( beneficiary.credits >= _value );

        emit CreditsAdjusted(_id, 2, _value, _reason, 0x0);
        emit CreditsAdjusted(_beneficiary, 1, _value, _reason, 0x0);
        emit CreditsTransferred(_id, _value, _reason, _beneficiary );
        
        return user.credits;
    }   

    function assignUserWallet( string _id, address _wallet ) public onlyOwnerOrOverride returns(uint256) {
        LOCIuser storage user = users[_id];   
        require( user.registered );
        user.wallet = _wallet;
        return user.credits;
    }

    function withdrawUserSpecifiedFunds( string _id, uint256 _value, uint8 _reason ) public returns(uint256) {
        LOCIuser storage user = users[_id];           
        require( user.registered, "user is not registered" );    
        require( user.wallet == msg.sender, "user.wallet is not msg.sender" );
        
        user.credits = user.credits.sub(_value);
        require( user.credits >= 0 );               
        require( token.transfer( user.wallet, _value ), "transfer failed" );                   
        emit CreditsAdjusted(_id, 2, _value, _reason, user.wallet );        
        
        return user.credits;
    }

    function getUserWallet( string _id ) public constant returns(address) {
        return users[_id].wallet;
    }

    function getTotalSupply() public constant returns(uint256) {        
        return token.balanceOf(address(this));
    }

    function getCreditsFor( string _id ) public constant returns(uint256) {
        return users[_id].credits;
    }

    function getUserCount() public constant returns(uint256) {
        return userCount;
    }    

    function getUserKey(uint256 _index) public constant returns(string) {
        require(_index <= userKeys.length-1);
        return userKeys[_index];
    }

    function getCreditsAtIndex(uint256 _index) public constant returns(uint256) {
        return getCreditsFor(getUserKey(_index));
    }

    // non-core functionality 
    function ownerSetOverride(address _address, bool enable) external onlyOwner {
        allowedOverrideAddresses[_address] = enable;
    }

    function isAllowedOverrideAddress(address _addr) external constant returns (bool) {
        return allowedOverrideAddresses[_addr];
    }

    // enable recovery of ether sent to this contract
    function ownerTransferWei(address _beneficiary, uint256 _value) external onlyOwner {
        require(_beneficiary != 0x0);
        require(_beneficiary != address(token));        

        // if zero requested, send the entire amount, otherwise the amount requested
        uint256 _amount = _value > 0 ? _value : address(this).balance;

        _beneficiary.transfer(_amount);
    }

    // enable recovery of LOCIcoin sent to this contract
    function ownerRecoverTokens(address _beneficiary) external onlyOwner {
        require(_beneficiary != 0x0);            
        require(_beneficiary != address(token));        

        uint256 _tokensRemaining = token.balanceOf(address(this));
        if (_tokensRemaining > 0) {
            token.transfer(_beneficiary, _tokensRemaining);
        }
    }

    // enable recovery of any other StandardToken sent to this contract
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return StandardToken(tokenAddress).transfer(owner, tokens);
    }
}

contract LociPartnerTokenSwap is Ownable, Contactable {    
    using SafeMath for uint256;    
    
    LOCIcredits lociCredits;

    mapping (address => bool) internal whitelistedTokens;    

    function setWhitelisted(address _address, bool enable) external onlyOwnerOrOverride {
        whitelistedTokens[_address] = enable;
    }

    constructor( address _lociCredits, string _contactInformation ) public {
        owner = msg.sender;        
        contactInformation = _contactInformation;       
        lociCredits = LOCIcredits(_lociCredits);
    }    
    
    function swapTokenValueForCredits( 
                    address _partnerTokenAddress, address _depositorWallet, uint256 _partnerTokenValue, address _transferTo,
                    string _id, uint256 _value, uint8 _reason, address _register ) public onlyOwnerOrOverride returns(uint256) {

        require( whitelistedTokens[_partnerTokenAddress], "token address has not been whitelisted" );
            
        StandardToken partnerToken = StandardToken(_partnerTokenAddress);            
        
        require( partnerToken.transferFrom( _depositorWallet, _transferTo, _partnerTokenValue ), "transferFrom failed" );
        
        return lociCredits.increaseCredits( _id, _value, _reason, _register );
    }

    // necessary for allowing other contracts we create to act as owners
    mapping (address => bool) internal allowedOverrideAddresses;    
    
    modifier onlyOwnerOrOverride() {
        // owner or any addresses listed in the overrides        
        require(msg.sender == owner || allowedOverrideAddresses[msg.sender]);
        _;
    }
    
    // non-core functionality 
    function ownerSetOverride(address _address, bool enable) external onlyOwner {
        allowedOverrideAddresses[_address] = enable;
    }

    function isAllowedOverrideAddress(address _addr) external constant returns (bool) {
        return allowedOverrideAddresses[_addr];
    }

    // enable recovery of ether sent to this contract
    function ownerTransferWei(address _beneficiary, uint256 _value) external onlyOwner {
        require(_beneficiary != 0x0);

        // if zero requested, send the entire amount, otherwise the amount requested
        uint256 _amount = _value > 0 ? _value : address(this).balance;

        _beneficiary.transfer(_amount);
    }

    // enable recovery of LOCIcoin sent to this contract
    function ownerRecoverTokens(address tokenAddress, address _beneficiary) external onlyOwner {
        require(_beneficiary != 0x0);            
        require(_beneficiary != tokenAddress);        

        uint256 _tokensRemaining = StandardToken(tokenAddress).balanceOf(address(this));
        if (_tokensRemaining > 0) {
            StandardToken(tokenAddress).transfer(_beneficiary, _tokensRemaining);
        }
    }

    // enable recovery of any other StandardToken sent to this contract
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return StandardToken(tokenAddress).transfer(owner, tokens);
    }

    // enable recovery of any other StandardToken sent to this contract
    function transferAnyERC20TokenToBeneficiary(address tokenAddress, address beneficiary, uint tokens) public onlyOwner returns (bool success) {
        return StandardToken(tokenAddress).transfer(beneficiary, tokens);
    }
}