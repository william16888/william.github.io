 pragma solidity ^0.5.13;

contract ETHFeast {
	
	uint256 stcPerior = 1 days;
	uint256 poltime = 72 hours;
	uint256 zeroPerior = 7 days;
	
	using SafeMath for *;
  
  constructor() public {}
 function getFixResAndTdy4(uint256 _pID)
    private
    view
    returns(uint256)
  {
    uint256 _res = players[_pID].fixResCount.add(players[_pID].tdy);
    if(_res >= 2)
    {
      _res = _res - 2;
    }
    return _res;
  }
	
  function caldays(uint256 _pIndex, uint256 _now_)
    private
    view
    returns(uint256)
  {
    uint256 _res;
    if(players[_pIndex].lastFixResTime > 1)
      _res = (_now_.sub(players[_pIndex].lastFixResTime).div(stcPerior));
    return _res;
  }

  function calcEarn(address _pAddress, uint256 _pIndex, uint256 _day, uint256 _fixResRate0000)
    private
    view
    returns(uint256)
  {
    uint256 _res;
    uint256 _canIncome = calcCanIncomeUn(_pIndex);
    if(_canIncome > 0 && _day > 0)
    {

      _res = calc(_pAddress, _pIndex, _canIncome, _day, _fixResRate0000);
    }
    return _res;
  }

  function calcEarnNoDays(address _pAddress, uint256 _pIndex, uint256 _fixResRate0000)
    private
    view
    returns(uint256)
  {
    if(players[_pIndex].lastFixResTime <= 1)return 0;

    uint256 _now = now;
    uint256 _day = caldays(_pIndex, _now);

    uint256 _tmpPerior = zeroPerior.div(stcPerior);
    _day = _day > _tmpPerior ? _tmpPerior : _day;
    if(_day <= 0)return 0;

    return calcEarn(_pAddress, _pIndex, _day, _fixResRate0000);
  }
  
  function calc(address _pAddress, uint256 _pIndex, uint256 _canIncome, uint256 _day, uint256 _fixResRate0000)
    private
    view
    returns(uint256)
  {
    uint256 _teth = players[_pIndex].curjoin;
    if(_teth <= 1)
    {
      return (0);
    }
    uint256 _rndrate;
    if(_fixResRate0000 != 0)
        _rndrate = _fixResRate0000;
    else 
        _rndrate = getFixRetWRand(_pAddress);

    uint256 _income = _teth.mul(_rndrate).mul(_day).div(10000);
    uint256 _ret;
    if(_canIncome < _income){
        _ret = _canIncome;
    }else{
        _ret = _income;
    }
    return (_ret);
  }
	
  function calcCanIncomeUn(uint256 _pIndex)
    private
    view
    returns(uint256)
  {
    
    uint256 _mlimit = players[_pIndex].incomeLimit;
    //uint256 _dystcts = player[_pAddress_].fixResCount.add(player[_pAddress_].tdy);
    uint256 _dystcts = getFixResAndTdy4(_pIndex);
    //* todo list
    uint256 _res;
    if(_mlimit > _dystcts){
        _res = (_mlimit.sub(_dystcts));
    }
    return _res;
  }
}
library SafeMath {
    
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    function div(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256) 
    {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    //10000×(1-5%)^180≈0.98
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}