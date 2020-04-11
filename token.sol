pragma solidity ^0.4.18;
import "browser/IERC20Token.sol";
contract JS {
    string public symbol = "JS";
    string public name = "JS Tunisian Community"
    uint8  public decimals = 18;
    uint256 public _totalSupply = 170000000;
	uint256 _ICOprices = 0;
	uint256 _BUYPrices = 0;
	uint256 _SELLPrices = 0;
	address _fundsReceiverAddress = 0;
	address owner = 0;	
	bool setupDone = false;
	bool isICOrunning = false;
	bool isBUYrunning = false;
	bool isSELLrunning = false;
	
	// Events
	event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
	event Burn(address indexed _owner, uint256 _value);
	
	// Mappings
    mapping  (address => uint256) balances;
    mapping  (address => mapping (address => uint256)) internal allowed;
    
    // Constructor
    function JS(address adr) public {
        owner = adr; 
        _fundsReceiverAddress=owner;
        _totalSupply=_totalSupply*1000000000000000000;
        balances[owner] = _totalSupply;
        Transfer(this, owner, _totalSupply);
    }
    
    // Set ICO Price
     function setIcoPrices(uint256 ICOprices) public {
        if (msg.sender == owner){
           _ICOprices = ICOprices;
        }
        else {
            revert();
        }
     }
     
     // Set buy price 
      function setBUYPrices(uint256 BUYPrices) public {
        if (msg.sender == owner){
            _BUYPrices = BUYPrices;
        }
           else {
            revert();
        }
     }
     
     // Set sell price 
       function setSELLPrices(uint256 SELLPrices) public {
        if (msg.sender == owner){
           _SELLPrices = SELLPrices;
        }
        else {
            revert();
        }
     }
     
     // Payable function, it will be called when the contract receives an amount of ether
     	function() public payable
	{
	   	if (isICOrunning && !isBUYrunning) 
		{
			uint256 _amount = ((msg.value * _ICOprices)/1000000000000000000);
			
			if ((balanceOf(this) < _amount) && _amount > 0) revert();
			
			if(!_fundsReceiverAddress.send(msg.value)) revert();		
			
		   	balances[msg.sender] += _amount;
		   	
		    balances[this] -= _amount;

		   	Transfer(this, msg.sender, _amount);
		}
		
		else if (!isICOrunning && isBUYrunning)
		{
		    
		   uint256 _amount2 = ((msg.value * _BUYPrices)/1000000000000000000);
		    if ((balanceOf(this) < _amount2) && _amount2 > 0) revert();
		    if(!_fundsReceiverAddress.send(msg.value)) revert();	
             balances[msg.sender] += _amount2;
              balances[this] -= _amount2;
		    Transfer(this, msg.sender, _amount2);
		}
	}
	 
    // Sell function
    function sell(uint256 amount) public  payable{
    	    amount = amount*1000000000000000000;
            if((balanceOf(msg.sender)>=amount && isSELLrunning && isICOrunning && isBUYrunning) ||
                (balanceOf(msg.sender)>=amount && isSELLrunning && !isICOrunning && !isBUYrunning)||
                (balanceOf(msg.sender)>=amount && isSELLrunning && !isICOrunning && isBUYrunning)||
                (balanceOf(msg.sender)>=amount && isSELLrunning && isICOrunning && !isBUYrunning))
             {
               balances[this] += amount;            // adds the amount to owner's balance
               balances[msg.sender] -= amount;// subtracts the amount from seller's balance
               require(msg.sender.send((amount * 1000000000000000000) /_SELLPrices));
                  Transfer(msg.sender, this, amount);               // executes an event reflecting on the change
	        }
	        else{
	            revert();
	        }
}

  // sendEtherToOwner Sends ether to owner 
	function sendEtherToOwner(uint256 amount) public  payable{
	    if (msg.sender == owner){
             owner.send(amount);    
	    }
	    else{
	        revert();
	    }
}

  // startICO Starts the ICO 
  	function startICO() public returns (bool success)
    {
        if (msg.sender == owner && !isICOrunning )
        {
			isICOrunning = true;			
        }
		else
		{
			revert();
		}
		return true;
    }
    
    // Start selling the token
    	function StartSELL() public returns (bool success)
    {
        if (msg.sender == owner && !isSELLrunning )
        {
			isSELLrunning = true;			
        }
		else
		{
			revert();
		}
		return true;
    }
    
    // startBUY Starts Buying the token
    function startBUY() public returns (bool success)
    {
        if (msg.sender == owner && !isBUYrunning)
        {
			isBUYrunning = true;			
        }
		else
		{
			revert();
		}
		return true;
    }
    
    // stopICO Stops the ICO
    	function stopICO() public returns (bool success)
      {
        if (msg.sender == owner && isICOrunning)
        {            
			
			isICOrunning = false;	
        }
		else
		{
			revert();
		}
		return true;
    }
    
    // stopSELL Stops selling the token 
    	function stopSELL() public returns (bool success)
      {
        if (msg.sender == owner && isSELLrunning)
        {            
			
			isSELLrunning = false;	
        }
		else
		{
			revert();
		}
		return true;
    }
    
    // stopBUY stops buying the token
	function stopBUY() public returns (bool success)
      {
        if (msg.sender == owner && isBUYrunning)
        {            
			
			isBUYrunning = false;	
        }
		else
		{
			revert();
		}
		return true;
    }
    
    // sendContractTokens Sends tokens from the contract adress to the owner
     function sendContractTokens(uint256 amount)
    {
        if (msg.sender == owner){
            if ((balanceOf(this) < amount) && amount > 0) revert();
		    if(!_fundsReceiverAddress.send(msg.value)) revert();
            balances[this] -= amount;
             balances[msg.sender] += amount;
             Transfer(this, msg.sender, amount);
        }
        else {
            revert();
            }
    }
     
    // mintToken mints a specific amount of the token to a target address
    function mintToken(address target, uint256 mintedAmount)  public {
     if (msg.sender == owner){
        balances[target] += mintedAmount;
        _totalSupply  += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
     }
      else{	revert();}
    }
    
    // _transfer transfers a specific amount of the token from an address to another
    // can only be called by the contract
     function _transfer(address _from, address _to, uint256 _value) internal {
        require(balances[_from] >= _value);
        require(balances[_to] + _value > balances[_to]);
        uint previousBalances = balances[_from] + balances[_to];
        balances[_from] -= _value;
        balances[_to] += _value;
        Transfer(_from, _to, _value);
        assert(balances[_from] + balances[_to] == previousBalances);
    }
    
    // Transfer transfers a specific amount of the token from the contract to an address
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    
    // TransferFrom transfers a specific amount of the token from an address to another
    // returns bool
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowed[_from][msg.sender]);     // Check allowance
        _transfer(_from, _to, _value);
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }
  
     // Approve Allows `_spender` to spend no more than `_value` tokens in your behalf
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    // allowance returns the amount of tokens approved by the owner that can be
    // transferred to the spender's account
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }
    
    // totalSupply returns the totalsupply of the token 
    function totalSupply() public constant returns (uint256 totalSupplyValue) {        
        return _totalSupply;
    }
    
    // ICOprice returns the ICO price
	function ICOprice() public constant returns (uint256 ICOprice) {        
        return _ICOprices;
    }
	
	// BUYprice returns the buy price
	function BUYprice() public constant returns (uint256 BUYprice) {        
        return _BUYPrices;
    }
	
	// SELLprice returns the sell price
		function SELLprice() public constant returns (uint256 SELLprice) {        
        return _SELLPrices;
    }
	
	// FundReceiverAddress funds the receiver address
	function FundReceiverAddress() public constant returns (address FundReceiverAddress) {        
        return _fundsReceiverAddress;
    }
	
    // Owner returns the owner address
	function Owner() public constant returns (address ownerAddress) {        
        return owner;
    }
	
    // IsSELLrunning checks if selling is running 
    // returns bool  
	function IsSELLrunning() public constant returns (bool isSELLrunningFalg) {        
        return isSELLrunning;
    }
    
    // IsICOrunning checks if ICO is running 
    // returns bool 
	function IsICOrunning() public constant returns (bool isICOrunningFalg) {        
        return isICOrunning;
    }
    
    // IsBUYrunning checks if buying is running 
    // returns bool
    function IsBUYrunning() public constant returns (bool isBUYrunningFalg) {        
        return isBUYrunning;
    }

    // balanceOf returns the balance of a given address
    function balanceOf(address _owner) public constant returns (uint256 balance) {
        return balances[_owner];
    }

    // BalanceEther returns the ethereum balance of the contract
    function BalanceEther() public constant returns (uint256 BalanceEther) {        
        return this.balance;
    }
    
}