// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
//import "./PriceFeed.sol";


contract Crowdsale is Ownable{

    // The token being sold
    ERC20 private token;

    //usdt contract
    IERC20 private usdt= IERC20(address(0x337610d27c682E347C9cD60BD4b3b107C9d34dDd));
    uint usdtDecimal = 18;
    //usdt decimal= 6 for core

    //address usdt on etherium  = 0xdAC17F958D2ee523a2206206994597C13D831ec7

    //adress usdt on core blockchain mainet= 0x900101d06A7426441Ae63e9AB3B9b0F63Be145F1

    //adress susdt on core blockchain testnet = 0x3786495F5d8a83B7bacD78E2A0c61ca20722Cce3

    // address usdt on BNB smart chain mainet = 0x55d398326f99059ff775485246999027b3197955
    // address usdt on BNB smart chain testnet = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd

    // Address where funds are collected
    address payable private wallet;

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.

    //this is for 1 usd = rate Token
    uint256 private rate;

    //this is for 1 usd = rate Token
    uint256 private firstRate;

    //this is for 1 usd = rate Token
    uint256 private secondRate;

    //this is for 1 usd = rate Token
    uint256 private thirdRate;

    // Amount of wei raised
    uint256 private weiRaised;

    // Amount of wei raised
    uint256 private usdtRaised;

    // total fund raised
    uint256 private fundsRaised;

    //limit time for crowdsale
    uint private timeCrowdsale;

    //limit time for crowdsale
    uint private secondTimeCrowdsale;

    //limit time for crowdsale
    uint private thirdTimeCrowdsale;

    //targeted token to be sold to get
    uint256 private investorTargetCap;

    //targeted token to be sold to get on round 2
    uint256 private secondInvestorTargetCap;


    //targeted token to be sold to get on round 2
    uint256 private thirdInvestorTargetCap;

    //token bought
    uint256 private tokenSold;

    //contributor in token
    mapping (address => uint256) public contributions;

    //wei contributor
    mapping (address => uint256) public weiContributions;

    //usdt contributor
    mapping (address => uint256) public usdtContributions;

    //fund by contributor
    mapping (address => uint256) public fundsContributions;



    //list of contributor
    address [] public contributorList;
    //check if contributor is listed
    mapping (address => bool) public contributorExist;

    //vesting
    uint256 vestingRate; 
    mapping (address => uint256) public vestingRound;
    mapping (address => uint256) public vestingTime;

    //Crowdsale Stages
    enum CrowdsaleStage {Ico,PreIco,SecondPreIco,ThirdPreIco,Community}

    //default presale
    CrowdsaleStage public stage = CrowdsaleStage.Community;

    // Modifier to check token allowance
    modifier checkAllowance(uint amount) {
        require(usdt.allowance(msg.sender, address(this)) >= amount, "Error allowance");
        _;
    }

    //modifier to check if he can buy
    //balanceOf(address(this))>=amount
    modifier checkIfEnoughBalance(uint amount) {
        require(token.balanceOf(address(this)) >= amount, "Not enough balance in the contract in the contract");
        _;
    }

    //modifier to check if can buy on presale PreIco,SecondPreIco,ThirdPreIco
    //
    modifier checkIfEnoughBalanceForCurrentStage(uint amount) {
        if( stage == CrowdsaleStage.PreIco){
            require((investorTargetCap-tokenSold) >= amount, "all token is already sold in this stage");
        }
        else if( stage == CrowdsaleStage.SecondPreIco){
            require((secondInvestorTargetCap-tokenSold) >= amount, "all token is already sold in this stage");
        }
        else if( stage == CrowdsaleStage.ThirdPreIco){
            require((secondInvestorTargetCap-tokenSold) >= amount, "all token is already sold in this stage");
        }
        _;
    }

    /**
     * Event for token purchase logging
     * @param purchaser who paid for the tokens
     * @param beneficiary who got the tokens
     * @param value weis paid for purchase
     * @param amount amount of tokens purchased
     */
    event TokensPurchased(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
    
    event TokensPurchasedWithUsdt(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);

    
    /**
     * Event for ctoken claim logging
     * @param purchaser who claim for the tokens
     * @param beneficiary who got the tokens
     * @param amount amount of tokens claimed
     */
    event TokensClaimed(address indexed purchaser, address indexed beneficiary, uint256 amount);
/*
    
     * @param _rate Number of token units a buyer gets per wei
     * @dev The rate is the conversion between wei and the smallest and indivisible
     * token unit. So, if you are using a rate of 1 with a ERC20Detailed token
     * with 3 decimals called TOK, 1 wei will give you 1 unit, or 0.001 TOK.
     * @param _wallet Address where collected funds will be forwarded to
     * @param _token Address of the token being sold
     
    constructor (uint256 _rate,uint256 _cap, address payable _wallet, ERC20 _token) 
    Ownable(_wallet)
    {
        require(_rate > 0, "Crowdsale: rate is 0");
        require(_wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(_token) != address(0), "Crowdsale: token is the zero address");
        
        rate = _rate;
        firstRate= _rate;
        wallet = _wallet;
        token = _token;
        timeCrowdsale= block.timestamp+86400;
        secondTimeCrowdsale=timeCrowdsale + 30 days;
        thirdTimeCrowdsale= secondTimeCrowdsale + 30 days;
        investorTargetCap= _cap*10**18;
    }
*/
    //only constructor for bitjoy
    constructor (address payable _wallet, ERC20 _token) 
    Ownable(_wallet)
    {
        require(_wallet != address(0), "Crowdsale: wallet is the zero address");
        require(address(_token) != address(0), "Crowdsale: token is the zero address");

        rate = 45*10**13;
        firstRate= 45*10**13;
        secondRate= 5*10**14;
        thirdRate = 55*10**13;

        wallet = _wallet;
        token = _token;

        timeCrowdsale= block.timestamp+86400;
        secondTimeCrowdsale=timeCrowdsale + 30 days;
        thirdTimeCrowdsale= secondTimeCrowdsale + 30 days;

        investorTargetCap= 2234400000*10**18;
        secondInvestorTargetCap=2713200000*10**18;
        thirdInvestorTargetCap=3032400000*10**18;

    }

    /**
     * @dev fallback function ***DO NOT OVERRIDE***
     * Note that other contracts will transfer funds with a base gas stipend
     * of 2300, which is not enough to call buyTokens. Consider calling
     * buyTokens directly when purchasing tokens from a contract.
     */
   /* receive() external payable {
        buyTokens(msg.sender);
    }*/

    /**
     * @return the token being sold.
     */
    function getToken() public view returns (ERC20) {
        return token;
    }

    /**
     * @return the address where funds are collected.
     */
    function getWallet() public view returns (address payable) {
        return wallet;
    }

    function setWallet( address payable _wallet) public onlyOwner{
        wallet= _wallet;
    } 

    /**
     * @return the number of token units a buyer gets per wei.
     */
    function getRate() public view returns (uint256) {
        return rate;
    }

    function getFirstRate() public view returns (uint256) {
        return firstRate;
    }

    function getSecondRate() public view returns (uint256) {
        return secondRate;
    }

    function getThirdRate() public view returns (uint256) {
        return thirdRate;
    }


    function setRate(uint256 _rate) public onlyOwner{
        rate=_rate;
    }

    function setStageRate(uint _stage, uint256 _rate) public onlyOwner{
        if( _stage == 1){
            firstRate=_rate;
        }
        else if (_stage == 2){
            secondRate = _rate;
        }
        else if (_stage == 3){
            thirdRate = _rate;
        }
    }

    /**
     * @return the amount of wei raised.
     */
    function getWeiRaised() public view returns (uint256) {
        return weiRaised;
    }

    /**
     * @return the amount of usdt raised.
     */
    function getUsdtRaised() public view returns (uint256) {
        return usdtRaised;
    }
    /**
     * @return the amount of total funds raised in usdt.
     */
    function getFundsRaised() public view returns (uint256) {
        return fundsRaised;
    }
    /**
     * @return the amount of usdt to be collected.
     */
    function getInvestorTargetCap() public view returns (uint256) {
        return investorTargetCap;
    }

    function getSecondInvestorTargetCap() public view returns (uint256) {
        return secondInvestorTargetCap;
    }

    function getThirdInvestorTargetCap() public view returns (uint256) {
        return thirdInvestorTargetCap;
    }

    function setInvestorTargetCap(uint _stage,uint256 _cap) public onlyOwner{
        if(_stage == 1){
            investorTargetCap=_cap;
        }
        else if ( _stage == 2 ){
            secondInvestorTargetCap = _cap;
        }
        else if ( _stage == 3 ) {
            thirdInvestorTargetCap = _cap;
        }
    }

    /**
     * @return the amount of usdt to be collected.
     */
    function getTokenSold() public view returns (uint256) {
        return tokenSold;
    }

    /**
     * @return the amount of usdt to be collected.
     */
    function getTimeCrowdsale() public view returns (uint) {
        return timeCrowdsale;
    }

    function getSecondTimeCrowdsale() public view returns (uint) {
        return secondTimeCrowdsale;
    }

    function getThirdTimeCrowdsale() public view returns (uint) {
        return thirdTimeCrowdsale;
    }

    function setTimeCrowdsale(uint256 _timeCrowdsale, uint256 _stage) public onlyOwner{
        if(_stage == 1){
            timeCrowdsale=_timeCrowdsale;
        }
        else if (_stage == 2){
            secondTimeCrowdsale = _timeCrowdsale;
        }
        else {
            thirdTimeCrowdsale = _timeCrowdsale;
        }
    }

    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokens(address beneficiary, uint256 coreRate) public payable {
        uint256 weiAmount = msg.value;


        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount,coreRate);

        // update state
        weiRaised +=weiAmount;
        uint256 usdtConverted = _convertCoretoUsdt(weiAmount,coreRate);
        fundsRaised += usdtConverted;

        //add as token sold
        tokenSold +=tokens;


        //add contributor on list
        if(!contributorExist[beneficiary]){
            contributorList.push(beneficiary);
            contributorExist[beneficiary] = true;
        }

        contributions[beneficiary]+= tokens;
        weiContributions[beneficiary]+=weiAmount;
        fundsContributions[beneficiary]+=usdtConverted;

        _processPurchase(beneficiary, tokens);
        emit TokensPurchased( msg.sender, beneficiary, weiAmount, tokens);

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }


     /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokensWithUsdt(address beneficiary,uint256 amount) public checkAllowance(amount) {
        uint256 usdtAmount = amount;


        // calculate token amount to be created
        uint256 tokens = _getTokenAmountWithUsdt(usdtAmount);

        // update state
        usdtRaised +=usdtAmount;
        fundsRaised +=usdtAmount;
        

        //add as token sold
        tokenSold +=tokens;

        //prevalidate
        //_preValidatePurchase(beneficiary,tokens)

        //add contributor on list
        if(!contributorExist[beneficiary]){
            contributorList.push(beneficiary);
            contributorExist[beneficiary] = true;
        }


        contributions[beneficiary]+= tokens;
        usdtContributions[beneficiary]+=usdtAmount;
        fundsContributions[beneficiary]+=usdtAmount;

        _deliverTokens(beneficiary, tokens);
        emit TokensPurchasedWithUsdt( msg.sender, beneficiary, amount, tokens);

        _updatePurchasingState(beneficiary, usdtAmount);

        _forwardUsdtFunds(beneficiary,amount);
        _postValidatePurchase(beneficiary, usdtAmount);
    }

   
    /**
     * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met.
     * Use `super` in contracts that inherit from Crowdsale to extend their validations.
     * Example from CappedCrowdsale.sol's _preValidatePurchase method:
     *     super._preValidatePurchase(beneficiary, weiAmount);
     *     require(weiRaised().add(weiAmount) <= cap);
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _preValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }
/* checkIfEnoughBalance(weiAmount)
    function _preValidatePurchaseOnPresale (address beneficiary, uint256 weiAmount) internal view checkIfEnoughBalanceForCurrentStage(weiAmount){
        require(beneficiary != address(0), "Crowdsale: beneficiary is the zero address");
        require(weiAmount != 0, "Crowdsale: weiAmount is 0");
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
    }*/

    /**
     * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid
     * conditions are not met.
     * @param beneficiary Address performing the token purchase
     * @param weiAmount Value in wei involved in the purchase
     */
    function _postValidatePurchase(address beneficiary, uint256 weiAmount) internal view {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends
     * its tokens.
     * @param beneficiary Address performing the token purchase
     * @param tokenAmount Number of tokens to be emitted
     */
    function _deliverTokens(address beneficiary, uint256 tokenAmount) internal {
        //token.allowance(wallet,beneficiary);
        token.approve(address(this),tokenAmount);
        token.transfer(beneficiary, tokenAmount);
        //token.transferFrom(wallet,beneficiary,tokenAmount);
    }


    /**
     * @dev Executed when a purchase has been validated and is ready to be executed. Doesn't necessarily emit/send
     * tokens.
     * @param beneficiary Address receiving the tokens
     * @param tokenAmount Number of tokens to be purchased
     */
    function _processPurchase(address beneficiary, uint256 tokenAmount) internal {
        _deliverTokens(beneficiary, tokenAmount);
    }

    /**
     * @dev Override for extensions that require an internal state to check for validity (current user contributions,
     * etc.)
     * @param beneficiary Address receiving the tokens
     * @param weiAmount Value in wei involved in the purchase
     */
    function _updatePurchasingState(address beneficiary, uint256 weiAmount) internal {
        // solhint-disable-previous-line no-empty-blocks
    }

    /**
     * @dev Override to extend the way in which ether is converted to tokens.
     * @param weiAmount Value in wei to be converted into tokens
     * @return Number of tokens that can be purchased with the specified _weiAmount
     */
    function _getTokenAmount(uint256 weiAmount, uint256 coreRate) internal view returns (uint256) {
        //uint ethRate = getEthRate();
        //return (weiAmount/10**5)*rate*(coreRate/10**13);
        return (weiAmount*rate*coreRate)/(10**36);
    }

    function _getTokenAmountWithUsdt(uint256 weiAmount) internal view returns (uint256) {
        //return (weiAmount*10**(18-usdtDecimal))*rate;
        return ((weiAmount*10**(18-usdtDecimal))*rate)/(10**18);

    }

    function _convertCoretoUsdt(uint256 weiAmount, uint256 coreRate) internal pure returns (uint256) {
        //return (weiAmount/10**(23-usdtDecimal))*(coreRate/10**13);
        return (weiAmount*coreRate)/(10**18);
    }

    /**
     * @dev Determines how ETH is stored/forwarded on purchases.
     */
    function _forwardFunds() internal {
        wallet.transfer(msg.value);
    }

    function _forwardUsdtFunds(address sender, uint256 amount) internal {
        usdt.transferFrom(sender,address(this),amount);
    }
    /**
     * @dev allow admin to update the crowdsale stage
     * @param _stage Crowdsale stage 
     */
    function setCrowdsaleStage(uint _stage) public onlyOwner{
        if(uint(CrowdsaleStage.PreIco) == _stage){
            stage = CrowdsaleStage.PreIco;
            rate = firstRate;
        }
        else if (uint(CrowdsaleStage.Ico)== _stage){
            stage = CrowdsaleStage.Ico;
        }
        else if (uint(CrowdsaleStage.SecondPreIco)== _stage){
            stage = CrowdsaleStage.SecondPreIco;
            rate = secondRate;
        }
        else if (uint(CrowdsaleStage.ThirdPreIco)== _stage){
            stage = CrowdsaleStage.ThirdPreIco;
            rate = thirdRate;
        }
        else if(uint(CrowdsaleStage.Community) == _stage){
            stage = CrowdsaleStage.Community;
        }
    }

    /**
     * @return stage crowdsale stage.
     */
    function getCrowdsaleStage() public view returns (uint256) {
        return uint(stage);
    }

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////Presale//////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////

    /**
     * @dev Returns the amount the contributor buy token on presale
     * @param _beneficiary address of presale buyers 
     * @return User Contribution on presale
     */
    function getUserContribution(address _beneficiary) public view returns (uint256){
        return contributions[_beneficiary];
    }

    function getUserWeiContribution(address _beneficiary) public view returns (uint256){
        return weiContributions[_beneficiary];
    }

    function getUserUsdtContribution(address _beneficiary) public view returns (uint256){
        return usdtContributions[_beneficiary];
    }

    function getUserFundContribution(address _beneficiary) public view returns (uint256){
        return fundsContributions[_beneficiary];
    }

    function getContributors() public view returns(address[] memory){
        return contributorList;
    }

    /**
     * @dev Buy token on presale
     * @param beneficiary Recipient of the token purchase
     * @param coreRate Recipient of the token purchase
     */
    function buyTokenOnPresale(address beneficiary,uint256 coreRate) public payable {
        uint256 weiAmount = msg.value;


        _preValidatePurchase(beneficiary, weiAmount);

        // calculate token amount to be created
        uint256 tokens = _getTokenAmount(weiAmount, coreRate);

        // update state
        weiRaised +=weiAmount;
        uint256 usdtConverted = _convertCoretoUsdt(weiAmount,coreRate);
        fundsRaised += usdtConverted;

        //add as token sold
        tokenSold +=tokens;

        //add contributor on list
        if(!contributorExist[beneficiary]){
            contributorList.push(beneficiary);
            contributorExist[beneficiary] = true;
        }

        contributions[beneficiary]+= tokens;
        weiContributions[beneficiary]+=weiAmount;
        fundsContributions[beneficiary]+=usdtConverted;

        _updatePurchasingState(beneficiary, weiAmount);

        _forwardFunds();
        _postValidatePurchase(beneficiary, weiAmount);
    }

    /**
     * @dev Buy token on presale
     * @param beneficiary Recipient of the token purchase
     */
    function buyTokenWithUsdtOnPresale(address beneficiary, uint256 amount) public checkAllowance(amount){
        uint256 usdtAmount = amount;



        // calculate token amount to be created
        uint256 tokens = _getTokenAmountWithUsdt(usdtAmount);

        // update state
          //add contributor on list
        if(!contributorExist[beneficiary]){
            contributorList.push(beneficiary);
            contributorExist[beneficiary] = true;
        }

        // update state
    
        usdtRaised +=usdtAmount;
        fundsRaised+=usdtAmount;

        //add as token sold
        tokenSold +=tokens;

        
        contributions[beneficiary]+= tokens;
        usdtContributions[beneficiary]+=usdtAmount;
        fundsContributions[beneficiary]+=usdtAmount;

        _updatePurchasingState(beneficiary, usdtAmount);

        _forwardUsdtFunds(beneficiary,amount);

        _postValidatePurchase(beneficiary, usdtAmount);
    }

    //////////////////////////////////////////////////////////////////////////////
    //////////////////////CLAIM///////////////////////////////////////////
    //////////////////////////////////////////////////////////////
    /**
     * @dev low level token purchase ***DO NOT OVERRIDE***
     * This function has a non-reentrancy guard, so it shouldn't be called by
     * another `nonReentrant` function.
     * @param beneficiary Recipient of the token purchase
     */
    function claimTokens(address beneficiary) public {

        uint256 tokens = contributions[beneficiary];
        uint256 tokenToBeClaimed;

        // get token to be claimed
        if(vestingRound[beneficiary] == 3){
            tokenToBeClaimed=tokens;
        }
        else {
            vestingRound[beneficiary] += 1;
            vestingTime[beneficiary] = block.timestamp + 30 days;
            tokenToBeClaimed=getAmountTokenByVestingRate(tokens);
        }
        
        _processPurchase(beneficiary, tokenToBeClaimed);
        emit TokensClaimed( msg.sender, beneficiary, tokenToBeClaimed);
        contributions[beneficiary]= tokens-tokenToBeClaimed;
        //_forwardFunds();
    }

    function getAmountTokenByVestingRate( uint256 _tokens) public view returns (uint256) {
        return (_tokens*vestingRate)/100;
    }


    //////////////////////////////////////////////////////////////////////
    /* get eth  */
   /* function getEthPrice() public view returns (int){
        int eth = getChainlinkDataFeedLatestAnswer();
        return eth;
    } 
    
    function getEthRate() public view returns (uint){
        int eth = getChainlinkDataFeedLatestAnswer();
        return rate*uint(eth/10**8);
    }*/

    function withdrawUsdt() public onlyOwner{
        uint256 amount = usdt.balanceOf(address(this));
        usdt.approve(address(this),amount);
        usdt.transfer(wallet, amount);
    }

    function crowdsaleUsdtBalance() public view returns(uint256){
        return usdt.balanceOf(address(this));
    }

    function crowdsaleTokenBalance() public view returns(uint256){
        return token.balanceOf(address(this));
    }
}