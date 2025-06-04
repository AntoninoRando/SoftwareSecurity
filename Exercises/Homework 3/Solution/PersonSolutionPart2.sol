pragma solidity ^0.8.22;
// SPDX-License-Identifier: UNLICENSED

contract Person {

    uint age; 
    bool isMarried; 
    
    /* Reference to spouse if person is married, address(0) otherwise */
    address spouse; 
    
    address mother; 
    address father; 
    
    uint constant DEFAULT_SUBSIDY = 500;
    uint constant ELDERLY_SUBSIDY = 600;
    uint constant RETIREMENT_AGE = 65;
    
    /* welfare subsidy */
    uint state_subsidy;

    function initPerson(address ma, address fa) public {
        age = 0;
        isMarried = false;
        mother = ma;
        father = fa;
        spouse = address(0);
        updateSubsidy();
    } 

    function marry(address new_spouse) public {
        require(new_spouse != address(0), "New spouse cannot be zero address");
        require(new_spouse != address(this), "Cannot marry self");
        require(new_spouse != spouse, "Already married to this address");

        if (isMarried)
            divorce();

        spouse = new_spouse;
        isMarried = true;

        Person marriedPerson = Person(new_spouse);
        if (marriedPerson.getSpouse() != address(0)) {
            if (marriedPerson.getSpouse() == address(this)) return;
            marriedPerson.divorce();
        }
        marriedPerson.marry(address(this));
    }

    
    function divorce() public {
        require(isMarried, "Not married");
        require(spouse != address(0), "Spouse is zero address");

        Person oldSpouse = Person(address(spouse));
        
        spouse = address(0);
        isMarried = false;

        if (oldSpouse.getSpouse() == address(this))
            oldSpouse.divorce();
    }

    function haveBirthday() public {
        age++;
        updateSubsidy(); // Update subsidy when age changes
    }

        function setSpouse(address sp) public {
        require(sp != address(this), "Spouse cannot be self");
        if (isMarried)
            require(sp != address(0), "If married cannot set spuse to zero address");
        else
            require(sp == address(0), "If not married the only spouse can be zero address");
        
        spouse = sp;
    }
    
    // I've added the view modifies because it is a read-only function. This is
    // also useful to declare the echidna test as a view function.
    function getSpouse() public view returns (address) {
        return spouse;
    }
    
    function updateSubsidy() public {
        if (isMarried)
            state_subsidy = DEFAULT_SUBSIDY * 70 / 100; 
        else
            state_subsidy = age < RETIREMENT_AGE ? 
                            DEFAULT_SUBSIDY : ELDERLY_SUBSIDY;
    }

    //#region ECHIDNA PROPERTIES / PART 1 --------------------------------------
    function echidna_symmetricMarriage() public view returns (bool) {
        if (!isMarried || spouse == address(0)) return true;
        return Person(spouse).getSpouse() == address(this);
    }
    function echidna_spouseAddressConsistency() public view returns (bool) {
        return isMarried? spouse != address(0) : spouse == address(0);
    }
    function echidna_notSelfMarried() public view returns (bool) {
        return spouse != address(this);
    }
    //#endregion ---------------------------------------------------------------
    //#region ECHIDNA PROPERTIES / PART 2 --------------------------------------
    function echidna_rightSubsidy() public view returns (bool) {
        if (isMarried) return state_subsidy == DEFAULT_SUBSIDY * 70 / 100;
        return state_subsidy == (age < RETIREMENT_AGE ? 
                                DEFAULT_SUBSIDY : ELDERLY_SUBSIDY);
    }
    function echidna_validAge() public view returns (bool) {
        return age >= 0;
    }
    //#endregion ---------------------------------------------------------------
}